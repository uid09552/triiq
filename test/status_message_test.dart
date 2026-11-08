import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_wellness.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/l10n/app_localizations_en.dart';
import 'package:triiq/screens/statistics/wellness_trends_screen.dart';
import 'package:triiq/widgets/status_message.dart';

class _FailingWellness extends WellnessRepository {
  var calls = 0;

  @override
  Future<List<LocalWellness>> getRange(String oldest, String newest) async {
    calls++;
    if (calls == 1) throw const SocketException('Failed host lookup');
    return const [];
  }
}

Widget _app(Widget home) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: home,
);

DioException _http(int status) => DioException(
  requestOptions: RequestOptions(path: '/x'),
  response: Response(
    requestOptions: RequestOptions(path: '/x'),
    statusCode: status,
  ),
);

void main() {
  final l10n = AppLocalizationsEn();

  group('describeError', () {
    test('maps the failures the app meets to plain language', () {
      expect(describeError(_http(401), l10n).title, l10n.smRefusedTitle);
      expect(describeError(_http(403), l10n).fix, ErrorFix.connect);
      expect(describeError(_http(429), l10n).title, l10n.smRateTitle);
      expect(describeError(_http(503), l10n).title, l10n.smServerTitle);
      expect(
        describeError(
          DioException.connectionError(
            requestOptions: RequestOptions(path: '/'),
            reason: 'no route',
          ),
          l10n,
        ).title,
        l10n.smOfflineTitle,
      );
      expect(
        describeError(const SocketException('x'), l10n).title,
        l10n.smOfflineTitle,
      );
      expect(
        describeError(StateError('Not connected to Intervals.icu.'), l10n).fix,
        ErrorFix.connect,
      );
      expect(describeError(Exception('?'), l10n).title, l10n.smGenericTitle);
    });
  });

  testWidgets('an error never shows the raw text up front; Details does', (
    tester,
  ) async {
    var retried = 0;
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: StatusMessage.error(
            error: StateError('Bad state: boom'),
            onRetry: () => retried++,
          ),
        ),
      ),
    );
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.textContaining('boom'), findsNothing);
    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();
    expect(find.textContaining('boom'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('status-action')));
    expect(retried, 1);
  });

  testWidgets('a refused key offers Profile instead of Retry', (tester) async {
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: StatusMessage.error(error: _http(401), onRetry: () {}),
        ),
      ),
    );
    expect(find.text('Intervals.icu refused the request'), findsOneWidget);
    expect(find.text('Open Profile'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('empty states say what is missing and offer Sync', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Scaffold(
            body: StatusMessage.needsSync(context, title: 'No efforts yet.'),
          ),
        ),
      ),
    );
    expect(find.text('No efforts yet.'), findsOneWidget);
    expect(find.text(l10n.smNeedHistory), findsOneWidget);
    expect(find.text('Open Sync'), findsOneWidget);
  });

  testWidgets('Wellness trends: offline, then Retry, then the empty state', (
    tester,
  ) async {
    final repo = _FailingWellness();
    await tester.pumpWidget(
      _app(
        WellnessTrendsScreen(repository: repo, today: DateTime(2026, 11, 8)),
      ),
    );
    await tester.pump();
    expect(find.text("You're offline"), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pump();
    expect(find.text(l10n.wtNoData), findsOneWidget);
    expect(find.text(l10n.wtNoDataReason), findsOneWidget);
    expect(find.text('Open Sync'), findsOneWidget);
  });
}
