import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/app.dart';
import 'package:triiq/data/feel_settings.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/evaluation/session_streams.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/activities/activity_detail_screen.dart';
import 'package:triiq/widgets/chart_options.dart';
import 'package:triiq/widgets/charts/bar_chart.dart';
import 'package:triiq/widgets/charts/line_chart.dart';
import 'package:triiq/widgets/gauge_ring.dart';
import 'package:triiq/widgets/progress_ring.dart';

Widget _app(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: Scaffold(body: child),
);

/// Every overflow or other layout error collected while [body] runs.
Future<List<String>> _layoutErrors(Future<void> Function() body) async {
  final errors = <String>[];
  final previous = FlutterError.onError;
  FlutterError.onError = (d) => errors.add(d.exceptionAsString());
  try {
    await body();
  } finally {
    FlutterError.onError = previous;
  }
  return errors;
}

void main() {
  group('screen-reader summaries', () {
    testWidgets('a line chart says what each series did', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          SizedBox(
            height: 200,
            child: MetricLineChart(
              series: const [
                ChartSeries(
                  label: 'CTL',
                  color: Colors.blue,
                  values: [61, 62, 64],
                ),
              ],
              labels: const ['1', '2', '3'],
            ),
          ),
        ),
      );
      expect(
        find.bySemanticsLabel(
          RegExp(r'CTL: latest 64\.0, \+3\.0 over the range'),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('a bar chart names the latest and the highest bar', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          const SizedBox(
            height: 160,
            child: SimpleBarChart(
              bars: [
                ChartBar(label: 'W1', value: 300),
                ChartBar(label: 'W2', value: 420),
                ChartBar(label: 'W3', value: 380),
              ],
            ),
          ),
        ),
      );
      expect(
        find.bySemanticsLabel(
          'Bar chart, 3 bars. Latest W3: 380. Highest W2: 420.',
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('gauges and target rings read as one phrase', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          const Column(
            children: [
              GaugeRing(
                progress: 0.72,
                color: Colors.green,
                size: 76,
                semanticsLabel: 'Readiness 72 of 100',
                child: Text('72'),
              ),
              ProgressRing(
                label: 'Swim',
                percentLabel: '60%',
                valueLabel: '1.2 / 2.0 h',
                progress: 0.6,
                color: Colors.blue,
                doneColor: Colors.green,
              ),
            ],
          ),
        ),
      );
      expect(find.bySemanticsLabel('Readiness 72 of 100'), findsOneWidget);
      expect(find.bySemanticsLabel('Swim: 1.2 / 2.0 h, 60%'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a dashed series shows dashes in the legend too', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const ChartLegend(
            series: [
              ChartSeries(label: 'A', color: Colors.blue, values: []),
              ChartSeries(
                label: 'B',
                color: Colors.orange,
                values: [],
                dashed: true,
              ),
            ],
          ),
        ),
      );
      expect(find.byKey(const ValueKey('legend-dashed')), findsOneWidget);
    });
  });

  testWidgets('chart options meet the 48 dp touch target', (tester) async {
    await tester.pumpWidget(
      _app(
        Center(
          child: ChartOptionsButton(summary: 'x', onPressed: () {}),
        ),
      ),
    );
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  });

  // The full app once (it shares one database per file), both sizes.
  testWidgets('Today and Insights do not overflow at 1.3 and 2.0', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final errors = await _layoutErrors(() async {
      await tester.pumpWidget(const TriiqApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
      for (final scale in const [1.3, 2.0]) {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Today'),
          ),
        );
        await tester.pump(const Duration(milliseconds: 800));
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Insights'),
          ),
        );
        await tester.pump(const Duration(milliseconds: 800));
      }
    });
    expect(errors, isEmpty);
  });

  for (final scale in const [1.3, 2.0]) {
    group('large text ($scale)', () {
      testWidgets('the activity page does not overflow', (tester) async {
        tester.view.physicalSize = const Size(412, 915);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        SharedPreferences.setMockInitialValues({
          'feel.prompt_on_new_activity': false,
        });
        final ride = LocalActivity(
          id: 'i9',
          date: '2026-11-03',
          type: 'Ride',
          name: 'A rather long ride name for big text',
          movingTime: 5400,
          distance: 45000,
          trainingLoad: 80,
          raw: const {'id': 'i9', 'icu_average_watts': 190},
          syncedAt: DateTime(2026, 11, 3),
        );
        final errors = await _layoutErrors(() async {
          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('en'),
              home: ActivityDetailScreen(
                activity: ride,
                feelSettings: FeelSettings.forTesting(),
                streams: ActivityStreamsRepository(
                  fetch: (_) async =>
                      const SessionStreams(series: {'time': []}),
                ),
              ),
            ),
          );
          for (var i = 0; i < 6; i++) {
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 30)),
            );
            await tester.pump();
          }
        });
        expect(errors, isEmpty);
      });
    });
  }
}
