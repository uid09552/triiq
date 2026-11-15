import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/sync_state_repository.dart';
import 'package:triiq/data/sync/auto_sync_service.dart';
import 'package:triiq/evaluation/period_stats.dart';
import 'package:triiq/evaluation/year_stats_service.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/calendar/calendar_data.dart';
import 'package:triiq/screens/calendar/calendar_screen.dart';
import 'package:triiq/screens/calendar/period_stats_loader.dart';
import 'package:triiq/screens/settings/year_goals_settings.dart';
import 'package:triiq/widgets/period_stats_peek.dart';

final _today = DateTime(2026, 11, 13, 9);

LocalActivity _act(
  String id,
  String date,
  String type, {
  int minutes = 60,
  double km = 20,
  int tss = 50,
}) => LocalActivity(
  id: id,
  date: date,
  type: type,
  name: '$type $id',
  movingTime: minutes * 60,
  distance: km * 1000,
  trainingLoad: tss,
  raw: {'id': id},
  syncedAt: DateTime(2026, 11, 1),
);

class _Trigger extends ChangeNotifier {
  void fire() => notifyListeners();
}

class _NoSyncLoader extends CalendarLoader {
  @override
  Future<void> sync(DateTime a, DateTime b, CalendarFreshness f) async {}

  @override
  Future<CalendarData> read(DateTime oldest, DateTime newest) async =>
      const CalendarData();
}

Widget _app(
  Widget child, {
  Locale locale = const Locale('en'),
  ThemeData? theme,
}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: locale,
  theme: theme,
  home: Scaffold(body: child),
);

const _full = SyncCoverage(oldest: '2000-01-01', newest: '2026-11-13');

PeriodStatsData _data(
  List<LocalActivity> acts, {
  SyncCoverage? coverage = _full,
  bool withMonth = true,
  int doneTss = 412,
  int plannedTss = 520,
  double? ctl = 3.2,
}) {
  final rows = statRows(acts);
  final month = DateTime(2026, 11);
  final monthRows = totalsBySport(rows, from: '2026-11-01', to: '2026-11-30');
  final done = acts.where((a) => a.date.startsWith('2026-11')).length;
  return PeriodStatsData(
    date: DateTime(2026, 11, 13),
    month: withMonth
        ? MonthStats(
            month: month,
            doneTss: done == 0 ? 0 : doneTss,
            plannedTss: plannedTss,
            doneMinutes: 564,
            doneCount: done,
            plannedCount: done == 0 ? 0 : 17,
            ctlChange: ctl,
            bySport: monthRows,
          )
        : null,
    year: computeYearStats(rows, year: 2026, today: _today, coverage: coverage),
  );
}

final _sample = [
  _act('1', '2026-11-02', 'Swim', minutes: 45, km: 2, tss: 40),
  _act('2', '2026-11-05', 'Ride', minutes: 120, km: 60, tss: 120),
  _act('3', '2026-11-09', 'Run', minutes: 60, km: 12, tss: 70),
  _act('4', '2026-11-10', 'WeightTraining', minutes: 30, km: 0, tss: 20),
  _act('5', '2026-03-01', 'Ride', minutes: 180, km: 90, tss: 150),
  _act('6', '2025-03-01', 'Ride', minutes: 120, km: 60, tss: 100),
  _act('7', '2025-12-24', 'Run', minutes: 60, km: 10, tss: 60),
];

Future<void> _pumpView(
  WidgetTester tester,
  PeriodStatsData data, {
  Size size = const Size(360, 800),
  Locale locale = const Locale('en'),
  ThemeData? theme,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    _app(
      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: PeriodStatsView(data: data, today: _today),
      ),
      locale: locale,
      theme: theme,
    ),
  );
  // YearGoalsProgress reads the cache once.
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pump();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    YearStatsService.instance.invalidate();
    final g = YearGoalsSettings.instance;
    g.swimKm = null;
    g.cycleKm = null;
    g.runKm = null;
  });

  group('PeriodStatsView content', () {
    testWidgets('full data: month on top, year per sport, changes', (
      tester,
    ) async {
      await _pumpView(tester, _data(_sample));
      expect(find.text('November 2026'), findsOneWidget);
      expect(find.text('412 / 520'), findsOneWidget);
      expect(find.text('9.4 h'), findsOneWidget);
      expect(find.text('4 / 17'), findsOneWidget);
      // Distance of the endurance sports only: 2 + 60 + 12 km.
      expect(find.text('74 km'), findsOneWidget);
      expect(find.text('+3.2'), findsOneWidget);
      // Month sports.
      expect(find.text('1 session · 0.8 h · 2 km'), findsOneWidget);

      expect(find.text('2026 so far'), findsOneWidget);
      // Year ride: 2 sessions, 5 h, 150 km, 270 TSS.
      expect(
        find.text('2 sessions · 5.0 h · 150 km · 270 TSS'),
        findsOneWidget,
      );
      // Ride time vs the same period last year: 5 h against 2 h.
      expect(find.byKey(const ValueKey('change-Ride')), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('change-Ride'))).data,
        '↑ 150 %',
      );
      // Run had no session in the comparison period (only 24 Dec 2025).
      expect(find.byKey(const ValueKey('change-Run')), findsNothing);
      expect(find.text('Total'), findsOneWidget);
      // Strength shows time and count but is not in the total.
      expect(find.textContaining('not in total'), findsOneWidget);
      expect(
        find.text('Change in time vs. the same period in 2025'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('no data says so for the month and the year', (tester) async {
      await _pumpView(tester, _data(const []));
      expect(find.text('No sessions this month.'), findsOneWidget);
      expect(find.text('No training synced for 2026.'), findsOneWidget);
    });

    testWidgets('a partly synced year says since when, never compares', (
      tester,
    ) async {
      await _pumpView(
        tester,
        _data(
          _sample,
          coverage: const SyncCoverage(
            oldest: '2026-09-01',
            newest: '2026-11-13',
          ),
        ),
      );
      final note = tester.widget<Text>(
        find.byKey(const ValueKey('period-stats-note')),
      );
      expect(note.data, contains('Based on synced data since Sep 1, 2026'));
      expect(note.data, contains('Settings → Data & privacy → Sync'));
      expect(find.byKey(const ValueKey('change-Ride')), findsNothing);
      expect(
        find.text('Change in time vs. the same period in 2025'),
        findsNothing,
      );
    });

    testWidgets('last year not synced: no comparison, with the reason', (
      tester,
    ) async {
      await _pumpView(
        tester,
        _data(
          _sample,
          coverage: const SyncCoverage(
            oldest: '2026-01-01',
            newest: '2026-11-13',
          ),
        ),
      );
      expect(
        find.text("No comparison: 2025 isn't fully synced."),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('change-Ride')), findsNothing);
    });

    testWidgets('last year synced but empty: no invented percentages', (
      tester,
    ) async {
      await _pumpView(
        tester,
        _data([_act('1', '2026-11-02', 'Run'), _act('2', '2026-02-02', 'Run')]),
      );
      expect(find.byKey(const ValueKey('change-Run')), findsNothing);
      expect(find.byKey(const ValueKey('change-Total')), findsNothing);
    });

    testWidgets('a past year is the full year', (tester) async {
      final past = PeriodStatsData(
        date: DateTime(2025, 12, 1),
        year: computeYearStats(
          statRows(_sample),
          year: 2025,
          today: _today,
          coverage: _full,
        ),
      );
      await _pumpView(tester, past);
      expect(find.text('Full year 2025'), findsOneWidget);
      expect(find.text('2026 so far'), findsNothing);
      // The year alone: no month section.
      expect(find.text('November 2026'), findsNothing);
    });

    testWidgets('year goals show as one line for the current year', (
      tester,
    ) async {
      YearGoalsSettings.instance.swimKm = 50;
      YearGoalsSettings.instance.runKm = 500;
      await _pumpView(tester, _data(_sample));
      final line = find.byKey(const ValueKey('year-goals-line'));
      expect(line, findsOneWidget);
      expect(
        find.descendant(of: line, matching: find.textContaining('Swim')),
        findsOneWidget,
      );
    });

    testWidgets('without goals there is no goals line', (tester) async {
      await _pumpView(tester, _data(_sample));
      expect(find.byKey(const ValueKey('year-goals-line')), findsNothing);
    });

    testWidgets('reads as one summary to a screen reader', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpView(tester, _data(_sample));
      final node = tester.getSemantics(
        find.byKey(const ValueKey('period-stats-peek')).first,
      );
      expect(node, isNotNull);
      expect(
        find.bySemanticsLabel(RegExp(r'Month November 2026: 412 / 520 TSS')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          RegExp(r'Year 2026 per sport: .*Ride: 2 sessions'),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('German', (tester) async {
      await _pumpView(tester, _data(_sample), locale: const Locale('de'));
      expect(find.text('November 2026'), findsOneWidget);
      expect(find.text('2026 bis heute'), findsOneWidget);
      expect(find.text('Gesamt'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    for (final (name, theme, size, scale) in [
      ('light, 360 dp, 2x text', ThemeData.light(), const Size(360, 800), 2.0),
      ('dark, 360 dp, 2x text', ThemeData.dark(), const Size(360, 800), 2.0),
      (
        'dark, 320 dp, 1.5x text',
        ThemeData.dark(useMaterial3: true),
        const Size(320, 700),
        1.5,
      ),
    ]) {
      testWidgets('no overflow: $name', (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        for (final locale in const [Locale('en'), Locale('de')]) {
          await _pumpView(
            tester,
            _data(_sample, coverage: const SyncCoverage(oldest: '2026-09-01')),
            size: size,
            theme: theme,
            locale: locale,
          );
          expect(tester.takeException(), isNull);
        }
      });
    }
  });

  group('YearStatsService', () {
    test(
      'serves repeat loads from memory and forgets on a cache change',
      () async {
        await ActivitiesRepository().upsertAll([
          _act('1', '2026-02-02', 'Run'),
        ]);
        await SyncStateRepository().recordSync(
          'activities',
          oldest: '2025-01-01',
          newest: '2026-11-13',
        );
        final trigger = _Trigger();
        final service = YearStatsService(
          invalidation: trigger,
          clock: () => _today,
        );
        addTearDown(() {
          service.dispose();
          trigger.dispose();
        });
        final a = await service.load(2026);
        final b = await service.load(2026);
        expect(identical(a, b), isTrue);
        expect(service.computeCount, 1);
        expect(a.stats.of(StatSport.run).sessions, 1);
        expect(a.stats.isPartial, isFalse);

        await ActivitiesRepository().upsertAll([
          _act('2', '2026-02-03', 'Run'),
        ]);
        // Still the copy in memory until the cache is announced as changed.
        expect((await service.load(2026)).stats.of(StatSport.run).sessions, 1);
        var notified = 0;
        service.addListener(() => notified++);
        trigger.fire();
        expect(notified, 1);
        expect((await service.load(2026)).stats.of(StatSport.run).sessions, 2);
        expect(service.computeCount, 2);
        // A different year is its own entry.
        await service.load(2025);
        expect(service.computeCount, 3);
        // `fresh` always rereads.
        await service.load(2025, fresh: true);
        expect(service.computeCount, 4);
      },
    );

    test(
      'the app-wide instance follows AutoSyncService.notifyCacheChanged',
      () async {
        final service = YearStatsService.instance;
        await service.load(2026);
        final before = service.computeCount;
        await service.load(2026);
        expect(service.computeCount, before);
        AutoSyncService.instance.notifyCacheChanged();
        await service.load(2026);
        expect(service.computeCount, before + 1);
      },
    );
  });

  group('PeriodStatsLoader', () {
    test('month and year from the cache', () async {
      await ActivitiesRepository().upsertAll([
        _act('1', '2026-11-02', 'Swim', minutes: 45, km: 2, tss: 40),
        _act('2', '2026-11-05', 'Ride', minutes: 120, km: 60, tss: 120),
        _act('3', '2026-10-05', 'Ride', minutes: 60, km: 30, tss: 60),
        _act('4', '2025-11-05', 'Ride', minutes: 60, km: 30, tss: 60),
      ]);
      await SyncStateRepository().recordSync(
        'activities',
        oldest: '2025-01-01',
        newest: '2026-11-13',
      );
      final loader = PeriodStatsLoader(
        clock: () => _today,
        years: YearStatsService(clock: () => _today),
      );
      final data = await loader.load(DateTime(2026, 11, 13));
      final m = data.month!;
      expect(m.doneCount, 2);
      expect(m.doneTss, 160);
      expect(m.bySport[StatSport.ride]!.km, 60);
      expect(m.total.sessions, 2);
      expect(data.year.of(StatSport.ride).sessions, 2);
      expect(data.year.lastOf(StatSport.ride)!.sessions, 1);

      final yearOnly = await loader.load(
        DateTime(2026, 11, 13),
        withMonth: false,
      );
      expect(yearOnly.month, isNull);
    });
  });

  group('Calendar header crumbs', () {
    Future<void> pumpCalendar(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.7;
      addTearDown(tester.view.reset);
      await tester.runAsync(() async {
        await ActivitiesRepository().upsertAll([
          _act('1', '2026-11-02', 'Ride', minutes: 120, km: 60, tss: 120),
          _act('2', '2026-03-02', 'Run', minutes: 60, km: 12, tss: 70),
        ]);
        await SyncStateRepository().recordSync(
          'activities',
          oldest: '2026-01-01',
          newest: '2026-11-13',
        );
      });
      await tester.pumpWidget(
        _app(CalendarScreen(loader: _NoSyncLoader(), today: () => _today)),
      );
      await tester.pumpAndSettle();
    }

    Future<TestGesture> hold(WidgetTester tester, String crumb) async {
      final g = await tester.startGesture(
        tester.getCenter(find.byKey(ValueKey('crumb-$crumb'))),
      );
      await tester.pump(const Duration(milliseconds: 700));
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }
      return g;
    }

    const overlay = ValueKey('hold-preview');

    testWidgets('holding the month crumb shows the overlay, release hides it', (
      tester,
    ) async {
      await pumpCalendar(tester);
      final g = await hold(tester, 'month');
      expect(find.byKey(overlay), findsOneWidget);
      expect(find.byKey(const ValueKey('period-stats-peek')), findsOneWidget);
      expect(find.text('November 2026'), findsWidgets);
      expect(find.text('2026 so far'), findsOneWidget);
      await g.up();
      await tester.pump();
      expect(find.byKey(overlay), findsNothing);
    });

    testWidgets('holding the year crumb works too', (tester) async {
      await pumpCalendar(tester);
      final g = await hold(tester, 'year');
      expect(find.byKey(const ValueKey('period-stats-peek')), findsOneWidget);
      await g.up();
      await tester.pump();
      expect(find.byKey(overlay), findsNothing);
    });

    testWidgets('a short tap on the year crumb still jumps up a level', (
      tester,
    ) async {
      await pumpCalendar(tester);
      await tester.tap(find.byKey(const ValueKey('crumb-year')));
      await tester.pumpAndSettle();
      expect(find.byKey(overlay), findsNothing);
      // At the year level the month crumb is gone.
      expect(find.byKey(const ValueKey('crumb-month')), findsNothing);
    });

    testWidgets('on the year level the peek is the year alone', (tester) async {
      await pumpCalendar(tester);
      await tester.tap(find.byKey(const ValueKey('crumb-year')));
      await tester.pumpAndSettle();
      final g = await hold(tester, 'year');
      expect(find.byKey(const ValueKey('period-stats-peek')), findsOneWidget);
      expect(find.text('November 2026'), findsNothing);
      await g.up();
      await tester.pump();
    });

    testWidgets('screen readers get a "Show preview" action on the crumb', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpCalendar(tester);
      final node = tester.getSemantics(
        find.byKey(const ValueKey('crumb-month')),
      );
      final labels = [
        for (final id in node.getSemanticsData().customSemanticsActionIds ?? [])
          CustomSemanticsAction.getAction(id)!.label,
      ];
      expect(labels, contains('Show preview'));
      handle.dispose();
    });
  });
}
