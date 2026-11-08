import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/data/intervals_session.dart';
import 'package:triiq/data/oauth/intervals_oauth.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/onboarding/onboarding_screen.dart';
import 'package:triiq/onboarding/onboarding_settings.dart';
import 'package:triiq/screens/profile/profile_screen.dart';
import 'package:triiq/screens/settings/weekly_targets_settings.dart';
import 'package:triiq/widgets/intervals_login.dart';

Widget _app(Widget home, {Locale locale = const Locale('en')}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: locale,
  home: home,
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('IntervalsLoginButton', () {
    testWidgets('is not offered where the browser login does not exist', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const Scaffold(body: IntervalsLoginButton(available: false))),
      );
      expect(find.byKey(const ValueKey('login-intervals')), findsNothing);
    });

    testWidgets('logs in, reports busy, and calls back when connected', (
      tester,
    ) async {
      final busy = <bool>[];
      var connected = 0;
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: IntervalsLoginButton(
              available: true,
              login: () async {},
              onBusyChanged: busy.add,
              onConnected: () => connected++,
            ),
          ),
        ),
      );
      expect(find.text('Log in with Intervals.icu'), findsOneWidget);
      expect(find.text('or use an API key'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('login-intervals')));
      await tester.pumpAndSettle();
      expect(busy, [true, false]);
      expect(connected, 1);
    });

    testWidgets('says so while the browser is open', (tester) async {
      final browser = Completer0();
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: IntervalsLoginButton(
              available: true,
              login: () => browser.future,
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('login-intervals')));
      await tester.pump();
      expect(find.text('Finish logging in in your browser…'), findsOneWidget);
      browser.complete();
      await tester.pumpAndSettle();
      expect(find.textContaining('never sees your password'), findsOneWidget);
    });

    testWidgets('a failure is reported in words, a refusal is just cancelled', (
      tester,
    ) async {
      final errors = <String>[];
      var fail = const OAuthException('Intervals.icu sent no access token.');
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: IntervalsLoginButton(
              available: true,
              login: () async => throw fail,
              onError: errors.add,
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('login-intervals')));
      await tester.pumpAndSettle();
      expect(
        errors.single,
        'Could not log in: Intervals.icu sent no access token.',
      );

      fail = const OAuthException('access_denied', denied: true);
      await tester.tap(find.byKey(const ValueKey('login-intervals')));
      await tester.pumpAndSettle();
      expect(errors.last, 'Login cancelled.');
    });
  });

  group('Profile', () {
    testWidgets('offers the login above the API key, and shows how you are '
        'connected', (tester) async {
      final session = IntervalsSession.forTesting();
      session.isRestoring = false;
      await tester.pumpWidget(
        _app(
          ProfileScreen(
            session: session,
            loginAvailable: true,
            login: () async {
              session
                ..method = ConnectionMethod.oauth
                ..debugSetConnected(true);
            },
          ),
        ),
      );
      await tester.pump();
      final login = find.byKey(const ValueKey('login-intervals'));
      expect(login, findsOneWidget);
      expect(find.text('Intervals.icu API key'), findsOneWidget);
      // The login comes first.
      expect(
        tester.getTopLeft(login).dy,
        lessThan(tester.getTopLeft(find.text('Intervals.icu API key')).dy),
      );

      await tester.tap(login);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('connected-via')), findsOneWidget);
      expect(find.text('Signed in with Intervals.icu'), findsOneWidget);
      expect(find.text('Disconnect'), findsOneWidget);
    });

    testWidgets('an API-key connection says so', (tester) async {
      final session = IntervalsSession.forTesting(connected: true);
      session
        ..isRestoring = false
        ..method = ConnectionMethod.apiKey;
      await tester.pumpWidget(_app(ProfileScreen(session: session)));
      await tester.pump();
      expect(find.text('Connected with an API key'), findsOneWidget);
    });
  });

  group('Onboarding', () {
    testWidgets('the login connects and syncs the month like a key does', (
      tester,
    ) async {
      var loggedIn = 0;
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _app(
          OnboardingScreen(
            login: () async => loggedIn++,
            loginAvailable: true,
            syncMonth: () async => 7,
            athleteName: () => 'Alex',
            targets: WeeklyTargetsSettings.forTesting(),
            settings: OnboardingSettings.forTesting(),
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('onboarding-next')));
      await tester.pumpAndSettle();
      expect(find.text('Connect Intervals.icu'), findsOneWidget);
      expect(
        find.textContaining('Log in with Intervals.icu, or paste your API key'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('login-intervals')));
      await tester.pumpAndSettle();
      expect(loggedIn, 1);
      expect(find.text('Connected as Alex'), findsOneWidget);
      expect(find.byKey(const ValueKey('onboarding-synced')), findsOneWidget);
      // The login is gone once connected.
      expect(find.byKey(const ValueKey('login-intervals')), findsNothing);
    });
  });
}

/// A future the test completes by hand.
class Completer0 {
  final _c = Completer<void>();
  Future<void> get future => _c.future;
  void complete() => _c.complete();
}
