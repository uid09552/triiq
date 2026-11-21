import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/data/models/local_wellness.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/calendar/day_summary_card.dart';
import 'calendar_drilldown_test.dart' as d;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpCard(WidgetTester t, Widget card) async {
    await t.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [card]),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  testWidgets('done against planned load, time and sessions', (t) async {
    await pumpCard(
      t,
      DaySummaryCard(
        events: [d.workout('e1', '2026-11-13', load: 80, secs: 3600)],
        activities: [d.activity('a1', '2026-11-13', load: 60, secs: 3000)],
      ),
    );
    expect(find.text('60 / 80 TSS'), findsOneWidget);
    expect(find.text('50 / 60 min'), findsOneWidget);
    expect(find.text('1 / 1 '), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.byKey(const ValueKey('sport-bar')), findsOneWidget);
    // The bar is drawn, not 0 px tall.
    expect(
      t.getSize(find.byKey(const ValueKey('sport-bar'))).height,
      greaterThan(5),
    );
  });

  testWidgets('a rest day says so', (t) async {
    await pumpCard(t, const DaySummaryCard(events: [], activities: []));
    expect(find.byKey(const ValueKey('day-summary-rest')), findsOneWidget);
  });

  testWidgets('holding it floats the details', (t) async {
    final wellness = LocalWellness(
      date: '2026-11-13',
      ctl: 62,
      atl: 70,
      ctlLoad: null,
      atlLoad: null,
      rampRate: null,
      raw: const {'rampRate': 4.2},
      syncedAt: DateTime(2026),
    );
    await pumpCard(
      t,
      DaySummaryCard(
        events: [d.workout('e1', '2026-11-13', name: 'Tempo run')],
        activities: [d.activity('a1', '2026-11-13')],
        wellness: wellness,
      ),
    );
    final g = await t.startGesture(
      t.getCenter(find.byKey(const ValueKey('day-summary-load'))),
    );
    await t.pump(const Duration(milliseconds: 700));
    expect(find.byKey(const ValueKey('day-summary-details')), findsOneWidget);
    expect(find.textContaining('Tempo run'), findsWidgets);
    expect(find.textContaining('Morning Run'), findsWidgets);
    expect(find.text('CTL 62 · ATL 70 · Form −8'), findsOneWidget);
    expect(find.text('Ramp rate 4.2 / week'), findsOneWidget);
    await g.up();
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('day-summary-details')), findsNothing);
  });

  testWidgets('day view: the card sits right under the header, week shown', (
    t,
  ) async {
    await d.pumpCalendar(
      t,
      events: [
        d.workout('e1', '2026-11-13', load: 70),
        d.workout('e2', '2026-11-11', load: 40),
      ],
      activities: [d.activity('a1', '2026-11-13', load: 65)],
    );
    await t.tap(find.byKey(const ValueKey('level-day')));
    await t.pumpAndSettle();
    final summary = find.byKey(const ValueKey('day-summary'));
    expect(summary, findsOneWidget);
    // Not floating mid-screen: within 60 dp of the header's summary line.
    final header = t.getRect(find.byKey(const ValueKey('calendar-summary')));
    expect(t.getRect(summary).top - header.bottom, lessThan(60));
    expect(find.text('Week so far: 65 of 110 TSS · 1.0 h'), findsOneWidget);
  });
}
