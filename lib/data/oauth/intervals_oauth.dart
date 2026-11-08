import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'pkce.dart';

/// Everything that is specific to Intervals.icu's OAuth, in one place: the
/// endpoints, the client, the scopes and the redirect addresses.
///
/// TriIQ is a *public client*: it has no secret to keep, so the login uses
/// PKCE (RFC 7636) — a one-time verifier proves the app that asked for the
/// code is the one exchanging it.
///
/// The client id and the redirect URIs must match what is registered for the
/// app at Intervals.icu. Override them for a build with
/// `--dart-define=INTERVALS_CLIENT_ID=…` and
/// `--dart-define=INTERVALS_REDIRECT_URI=…`.
@immutable
class IntervalsOAuthConfig {
  const IntervalsOAuthConfig({
    this.clientId = _clientId,
    this.authorizeUrl = 'https://intervals.icu/oauth/authorize',
    this.tokenUrl = 'https://intervals.icu/api/oauth/token',
    this.scopes = defaultScopes,
    this.redirectOverride = _redirectOverride,
  });

  static const _clientId = String.fromEnvironment(
    'INTERVALS_CLIENT_ID',
    defaultValue: '1727',
  );
  static const _redirectOverride = String.fromEnvironment(
    'INTERVALS_REDIRECT_URI',
  );

  /// What the app reads and writes: activities and curves, wellness (and the
  /// fatigue/soreness it writes back), the calendar (planned workouts) and
  /// the athlete's settings (FTP, zones).
  static const defaultScopes = [
    'ACTIVITY:READ',
    'WELLNESS:READ',
    'WELLNESS:WRITE',
    'CALENDAR:READ',
    'CALENDAR:WRITE',
    'SETTINGS:READ',
  ];

  /// Android: Intervals.icu sends the browser back to this address and the
  /// manifest hands it to the app.
  static const androidRedirect = 'triiq://oauth/callback';

  /// Windows: the app listens on this loopback address while the login is
  /// open (RFC 8252 §7.3).
  static const desktopRedirect = 'http://127.0.0.1:53682/callback';

  final String clientId;
  final String authorizeUrl;
  final String tokenUrl;
  final List<String> scopes;
  final String redirectOverride;

  /// Comma-separated, the way Intervals.icu lists scopes.
  String get scope => scopes.join(',');
}

/// What a login returns: the bearer token, and the athlete if the token
/// response named one (the session reads the profile either way).
@immutable
class OAuthToken {
  const OAuthToken({
    required this.accessToken,
    this.athleteId,
    this.athleteName,
  });

  final String accessToken;
  final String? athleteId;
  final String? athleteName;
}

class OAuthException implements Exception {
  const OAuthException(this.message, {this.denied = false});

  final String message;

  /// The athlete said no on Intervals.icu's page (not an error).
  final bool denied;

  @override
  String toString() => message;
}

/// Where the browser lands after the athlete has agreed.
abstract class OAuthCallbackSource {
  /// The address to register and to send as `redirect_uri`.
  Uri get redirectUri;

  /// Starts listening. Call before the browser opens.
  Future<void> start();

  /// The full address the browser was sent to, with its query.
  Future<Uri> get callback;

  Future<void> close();
}

/// Windows: a one-shot HTTP server on the loopback address. It answers the
/// browser with a short "you can close this tab" page.
class LoopbackCallbackSource implements OAuthCallbackSource {
  LoopbackCallbackSource([Uri? redirect])
    : redirectUri = redirect ?? Uri.parse(IntervalsOAuthConfig.desktopRedirect);

  @override
  final Uri redirectUri;

  HttpServer? _server;
  final _completer = Completer<Uri>();

  @override
  Future<Uri> get callback => _completer.future;

  @override
  Future<void> start() async {
    final server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      redirectUri.port,
    );
    _server = server;
    server.listen((request) async {
      if (request.uri.path != redirectUri.path) {
        request.response
          ..statusCode = HttpStatus.notFound
          ..close();
        return;
      }
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.html
        ..write(_page);
      await request.response.close();
      if (!_completer.isCompleted) _completer.complete(request.requestedUri);
    });
  }

  @override
  Future<void> close() async {
    await _server?.close(force: true);
    _server = null;
  }

  static const _page =
      '<!doctype html><meta charset="utf-8">'
      '<meta name="viewport" content="width=device-width,initial-scale=1">'
      '<title>TriIQ</title>'
      '<body style="font-family:system-ui,sans-serif;text-align:center;'
      'padding:3rem 1rem"><h2>TriIQ</h2>'
      '<p>You can close this tab and go back to the app.</p></body>';
}

/// Android: the manifest routes `triiq://oauth/callback` to `MainActivity`,
/// which passes the address on over this channel.
class SchemeCallbackSource implements OAuthCallbackSource {
  SchemeCallbackSource([Uri? redirect])
    : redirectUri = redirect ?? Uri.parse(IntervalsOAuthConfig.androidRedirect);

  static const _channel = MethodChannel('triiq/oauth');

  @override
  final Uri redirectUri;

  final _completer = Completer<Uri>();

  @override
  Future<Uri> get callback => _completer.future;

  @override
  Future<void> start() async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'callback' && !_completer.isCompleted) {
        _completer.complete(Uri.parse(call.arguments as String));
      }
    });
  }

  @override
  Future<void> close() async => _channel.setMethodCallHandler(null);
}

/// "Log in with Intervals.icu": opens the authorize page in the browser,
/// waits for the redirect back, checks `state`, and trades the code for an
/// access token with the PKCE verifier.
class IntervalsOAuth {
  IntervalsOAuth({
    this.config = const IntervalsOAuthConfig(),
    Dio? dio,
    OAuthCallbackSource Function(Uri? redirect)? callbackSource,
    Future<bool> Function(Uri url)? launch,
    this.timeout = const Duration(minutes: 5),
    Random? random,
  }) : _dio = dio ?? Dio(),
       _callbackSource = callbackSource ?? _platformSource,
       _launch = launch ?? _launchInBrowser,
       _random = random;

  final IntervalsOAuthConfig config;
  final Dio _dio;
  final OAuthCallbackSource Function(Uri? redirect) _callbackSource;
  final Future<bool> Function(Uri url) _launch;
  final Duration timeout;
  final Random? _random;

  /// Browser login exists on Android and Windows; on the web preview and iOS
  /// the API key is the way in.
  static bool get isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isWindows);

  static OAuthCallbackSource _platformSource(Uri? redirect) =>
      Platform.isAndroid
      ? SchemeCallbackSource(redirect)
      : LoopbackCallbackSource(redirect);

  static Future<bool> _launchInBrowser(Uri url) =>
      launchUrl(url, mode: LaunchMode.externalApplication);

  /// The page the athlete agrees on.
  Uri authorizeUri({
    required Pkce pkce,
    required String state,
    required Uri redirect,
  }) => Uri.parse(config.authorizeUrl).replace(
    queryParameters: {
      'client_id': config.clientId,
      'redirect_uri': redirect.toString(),
      'scope': config.scope,
      'state': state,
      'code_challenge': pkce.challenge,
      'code_challenge_method': Pkce.method,
    },
  );

  /// The whole login. Throws [OAuthException] when the athlete says no, the
  /// browser never comes back, `state` does not match, or the token request
  /// is refused.
  Future<OAuthToken> login() async {
    final override = config.redirectOverride;
    final source = _callbackSource(
      override.isEmpty ? null : Uri.parse(override),
    );
    final pkce = Pkce.generate(_random);
    final state = randomUrlSafe(16, _random);

    try {
      await source.start();
    } catch (error) {
      throw OAuthException('Could not listen for the login: $error');
    }
    try {
      final url = authorizeUri(
        pkce: pkce,
        state: state,
        redirect: source.redirectUri,
      );
      if (!await _launch(url)) {
        throw const OAuthException('Could not open the browser.');
      }
      final Uri back;
      try {
        back = await source.callback.timeout(timeout);
      } on TimeoutException {
        throw const OAuthException('The login timed out.');
      }

      final q = back.queryParameters;
      if (q['error'] != null) {
        throw OAuthException(
          q['error_description'] ?? q['error']!,
          denied: q['error'] == 'access_denied',
        );
      }
      if (q['state'] != state) {
        throw const OAuthException(
          'The login response did not match the request (state).',
        );
      }
      final code = q['code'];
      if (code == null || code.isEmpty) {
        throw const OAuthException('Intervals.icu sent no authorization code.');
      }
      return await exchangeCode(
        code: code,
        verifier: pkce.verifier,
        redirect: source.redirectUri,
      );
    } finally {
      await source.close();
    }
  }

  /// Trades the one-time [code] for an access token. A public client sends
  /// the PKCE [verifier] instead of a secret.
  Future<OAuthToken> exchangeCode({
    required String code,
    required String verifier,
    required Uri redirect,
  }) async {
    final Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>(
        config.tokenUrl,
        data: {
          'grant_type': 'authorization_code',
          'client_id': config.clientId,
          'code': code,
          'code_verifier': verifier,
          'redirect_uri': redirect.toString(),
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.json,
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == null) {
        throw OAuthException('Could not reach Intervals.icu: ${error.message}');
      }
      throw OAuthException(
        'Intervals.icu refused the token request (HTTP $status)'
        '${_reason(error.response?.data)}.',
      );
    }

    var body = response.data;
    if (body is String) {
      try {
        body = jsonDecode(body);
      } catch (_) {
        body = null;
      }
    }
    final token = body is Map ? body['access_token'] : null;
    if (token is! String || token.isEmpty) {
      throw const OAuthException('Intervals.icu sent no access token.');
    }
    final athlete = body is Map ? body['athlete'] : null;
    return OAuthToken(
      accessToken: token,
      athleteId: athlete is Map ? '${athlete['id'] ?? ''}'.nullIfEmpty : null,
      athleteName: athlete is Map
          ? '${athlete['name'] ?? ''}'.nullIfEmpty
          : null,
    );
  }

  static String _reason(Object? data) {
    Object? body = data;
    if (body is String) {
      final text = body;
      try {
        body = jsonDecode(text);
      } catch (_) {
        if (text.isEmpty) return '';
        return ': ${text.length > 120 ? text.substring(0, 120) : text}';
      }
    }
    if (body is Map) {
      final text =
          body['error_description'] ?? body['error'] ?? body['message'];
      if (text != null) return ': $text';
    }
    return '';
  }
}

extension on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}
