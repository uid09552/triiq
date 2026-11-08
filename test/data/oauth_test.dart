import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/oauth/intervals_oauth.dart';
import 'package:triiq/data/oauth/pkce.dart';

/// A browser that "comes back" with whatever [respond] builds from the
/// authorize URL it was sent to.
class _FakeCallback implements OAuthCallbackSource {
  _FakeCallback(this.redirectUri);

  @override
  final Uri redirectUri;
  final _completer = Completer<Uri>();
  bool started = false, closed = false;

  @override
  Future<Uri> get callback => _completer.future;

  @override
  Future<void> start() async => started = true;

  @override
  Future<void> close() async => closed = true;

  void deliver(Uri uri) => _completer.complete(uri);
}

/// Records token requests and answers with [reply].
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.reply);

  final ResponseBody Function(RequestOptions) reply;
  final requests = <RequestOptions>[];
  final bodies = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final b = BytesBuilder();
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        b.add(chunk);
      }
    }
    bodies.add(utf8.decode(b.toBytes()));
    return reply(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, [int status = 200]) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

void main() {
  group('Pkce', () {
    test('the RFC 7636 appendix B example', () {
      expect(
        Pkce.challengeFor('dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk'),
        'E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM',
      );
    });

    test('a generated verifier is long, URL-safe and always different', () {
      final a = Pkce.generate(), b = Pkce.generate();
      expect(a.verifier.length, inInclusiveRange(43, 128));
      expect(RegExp(r'^[A-Za-z0-9\-_]+$').hasMatch(a.verifier), isTrue);
      expect(a.verifier, isNot(b.verifier));
      expect(a.challenge, Pkce.challengeFor(a.verifier));
      expect(a.challenge.contains('='), isFalse);
      expect(Pkce.method, 'S256');
    });
  });

  group('IntervalsOAuth', () {
    final redirect = Uri.parse('triiq://oauth/callback');

    late _FakeCallback source;
    late _FakeAdapter adapter;
    late List<Uri> launched;

    IntervalsOAuth make({
      ResponseBody Function(RequestOptions)? reply,
      Duration timeout = const Duration(seconds: 5),
      void Function(Uri url)? onLaunch,
      IntervalsOAuthConfig config = const IntervalsOAuthConfig(),
    }) {
      source = _FakeCallback(redirect);
      launched = [];
      adapter = _FakeAdapter(
        reply ??
            (_) => _json({
              'access_token': 'tok-123',
              'token_type': 'Bearer',
              'scope': 'ACTIVITY:READ',
              'athlete': {'id': 'i42', 'name': 'Alex'},
            }),
      );
      return IntervalsOAuth(
        config: config,
        dio: Dio()..httpClientAdapter = adapter,
        callbackSource: (_) => source,
        launch: (url) async {
          launched.add(url);
          onLaunch?.call(url);
          return true;
        },
        timeout: timeout,
        random: Random(7),
      );
    }

    test('the authorize URL carries client, redirect, scopes, state, PKCE', () {
      final oauth = make();
      final pkce = Pkce.fromVerifier('v' * 50);
      final url = oauth.authorizeUri(
        pkce: pkce,
        state: 'st',
        redirect: redirect,
      );
      expect(url.origin, 'https://intervals.icu');
      expect(url.path, '/oauth/authorize');
      final q = url.queryParameters;
      expect(q['client_id'], '1727');
      expect(q['redirect_uri'], 'triiq://oauth/callback');
      expect(q['state'], 'st');
      expect(q['code_challenge'], pkce.challenge);
      expect(q['code_challenge_method'], 'S256');
      expect(q['scope'], contains('ACTIVITY:READ'));
      expect(q['scope'], contains('CALENDAR:WRITE'));
      expect(q['scope']!.contains(' '), isFalse);
      expect(q.containsKey('client_secret'), isFalse);
    });

    test(
      'a full login: browser, state check, code for token with the verifier',
      () async {
        late final oauth = make(
          onLaunch: (url) => source.deliver(
            redirect.replace(
              queryParameters: {
                'code': 'the-code',
                'state': url.queryParameters['state']!,
              },
            ),
          ),
        );
        final token = await oauth.login();

        expect(token.accessToken, 'tok-123');
        expect(token.athleteId, 'i42');
        expect(token.athleteName, 'Alex');
        expect(source.started, isTrue);
        expect(source.closed, isTrue);

        // The token request: form-encoded, verifier instead of a secret.
        final req = adapter.requests.single;
        expect(req.uri.toString(), 'https://intervals.icu/api/oauth/token');
        expect(req.method, 'POST');
        expect(
          req.contentType,
          startsWith('application/x-www-form-urlencoded'),
        );
        final form = Uri.splitQueryString(adapter.bodies.single);
        expect(form['code'], 'the-code');
        expect(form['client_id'], '1727');
        expect(form['grant_type'], 'authorization_code');
        expect(form['redirect_uri'], 'triiq://oauth/callback');
        // The verifier hashes to the challenge sent to the browser.
        expect(
          Pkce.challengeFor(form['code_verifier']!),
          launched.single.queryParameters['code_challenge'],
        );
        expect(form.containsKey('client_secret'), isFalse);
      },
    );

    test(
      'a state that does not match is refused before any token request',
      () async {
        final oauth = make(
          onLaunch: (_) => source.deliver(
            redirect.replace(queryParameters: {'code': 'c', 'state': 'forged'}),
          ),
        );
        await expectLater(
          oauth.login(),
          throwsA(
            isA<OAuthException>().having(
              (e) => e.message,
              'message',
              contains('state'),
            ),
          ),
        );
        expect(adapter.requests, isEmpty);
        expect(source.closed, isTrue);
      },
    );

    test('saying no on Intervals.icu is a denial, not a failure', () async {
      final oauth = make(
        onLaunch: (url) => source.deliver(
          redirect.replace(
            queryParameters: {
              'error': 'access_denied',
              'state': url.queryParameters['state']!,
            },
          ),
        ),
      );
      await expectLater(
        oauth.login(),
        throwsA(
          isA<OAuthException>().having((e) => e.denied, 'denied', isTrue),
        ),
      );
      expect(adapter.requests, isEmpty);
    });

    test('a browser that never comes back times out and cleans up', () async {
      final oauth = make(timeout: const Duration(milliseconds: 50));
      await expectLater(
        oauth.login(),
        throwsA(
          isA<OAuthException>().having(
            (e) => e.message,
            'message',
            contains('timed out'),
          ),
        ),
      );
      expect(source.closed, isTrue);
    });

    test('a refused token request says why', () async {
      final oauth = make(
        reply: (_) => _json({'error': 'invalid_grant'}, 400),
        onLaunch: (url) => source.deliver(
          redirect.replace(
            queryParameters: {
              'code': 'old',
              'state': url.queryParameters['state']!,
            },
          ),
        ),
      );
      await expectLater(
        oauth.login(),
        throwsA(
          isA<OAuthException>()
              .having((e) => e.message, 'message', contains('HTTP 400'))
              .having((e) => e.message, 'message', contains('invalid_grant')),
        ),
      );
    });

    test('a response without an access token is an error', () async {
      final oauth = make(reply: (_) => _json({'scope': 'x'}));
      await expectLater(
        oauth.exchangeCode(code: 'c', verifier: 'v', redirect: redirect),
        throwsA(isA<OAuthException>()),
      );
    });

    test('the athlete in the token response is optional', () async {
      final oauth = make(reply: (_) => _json({'access_token': 'only'}));
      final t = await oauth.exchangeCode(
        code: 'c',
        verifier: 'v',
        redirect: redirect,
      );
      expect(t.accessToken, 'only');
      expect(t.athleteId, isNull);
    });
  });

  group('LoopbackCallbackSource', () {
    late int port;

    setUp(() async {
      final probe = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      port = probe.port;
      await probe.close();
    });

    test('catches the redirect and tells the browser it can close', () async {
      final source = LoopbackCallbackSource(
        Uri.parse('http://127.0.0.1:$port/callback'),
      );
      await source.start();

      final client = HttpClient();
      final stray = await (await client.getUrl(
        Uri.parse('http://127.0.0.1:$port/favicon.ico'),
      )).close();
      expect(stray.statusCode, 404);
      await stray.drain<void>();

      final response = await (await client.getUrl(
        Uri.parse('http://127.0.0.1:$port/callback?code=abc&state=xyz'),
      )).close();
      final page = await utf8.decodeStream(response);
      expect(response.statusCode, 200);
      expect(page, contains('close this tab'));

      final back = await source.callback;
      expect(back.queryParameters, {'code': 'abc', 'state': 'xyz'});
      client.close();
      await source.close();
    });
  });
}
