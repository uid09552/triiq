import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/plan/risk_forecast.dart';
import 'package:triiq/screens/calendar/agenda_view.dart';

LocalEvent ev(
  String date, {
  int load = 60,
  int secs = 3600,
  String cat = 'WORKOUT',
}) => LocalEvent(
  id: '$date-$load',
  date: date,
  category: cat,
  type: 'Ride',
  name: 'Session $date',
  description: null,
  plannedLoad: load,
  plannedTime: secs,
  plannedDistance: null,
  indoor: false,
  raw: const {},
  syncedAt: DateTime(2026),
);

void main() {
  final today = DateTime(2026, 11, 2);

  test('hard means a race or about 70 TSS per hour and up', () {
    expect(isHardEvent(ev('2026-11-03', load: 90)), isTrue);
    expect(isHardEvent(ev('2026-11-03', load: 50)), isFalse);
    expect(isHardEvent(ev('2026-11-03', load: 0, cat: 'RACE_A')), isTrue);
    expect(isHardEvent(ev('2026-11-03', load: 90, cat: 'NOTE')), isFalse);
  });

  test('two hard days in a row are caution, three are high', () {
    final risk = forecastRisk(
      ctl: 60,
      atl: 55,
      today: today,
      until: DateTime(2026, 11, 8),
      plannedByDate: {
        '2026-11-03': [ev('2026-11-03', load: 90)],
        '2026-11-04': [ev('2026-11-04', load: 90)],
        '2026-11-05': [ev('2026-11-05', load: 90)],
        '2026-11-07': [ev('2026-11-07', load: 40)],
      },
    );
    expect(risk.containsKey('2026-11-03'), isFalse);
    expect(risk['2026-11-04']!.level, DayRisk.caution);
    expect(risk['2026-11-05']!.level, DayRisk.high);
    expect(risk['2026-11-05']!.hardStreak, 3);
    expect(risk.containsKey('2026-11-07'), isFalse);
  });

  test('projected form in the high-risk zone is high', () {
    final risk = forecastRisk(
      ctl: 50,
      atl: 60,
      today: today,
      until: DateTime(2026, 11, 4),
      plannedByDate: {
        '2026-11-03': [ev('2026-11-03', load: 250, secs: 4 * 3600)],
      },
    );
    expect(risk['2026-11-03']!.highRiskForm, isTrue);
    expect(risk['2026-11-03']!.level, DayRisk.high);
  });

  testWidgets('the agenda explains a flagged day', (t) async {
    await t.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: AgendaView(
            month: DateTime(2026, 11),
            eventsByDate: {
              '2026-11-05': [ev('2026-11-05', load: 90)],
            },
            activitiesByDate: const {},
            onSelect: (_) {},
            riskByDate: const {
              '2026-11-05': DayRiskInfo(
                level: DayRisk.high,
                form: -32,
                hardStreak: 3,
                highRiskForm: true,
              ),
            },
          ),
        ),
      ),
    );
    expect(find.byKey(const ValueKey('risk-high')), findsOneWidget);
    expect(
      find.text('High load ahead: projected form -32; 3 hard days in a row'),
      findsOneWidget,
    );
  });
}
