import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/planned_items.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/plan/plan_models.dart';
import 'package:triiq/screens/calendar/calendar_day_detail.dart';

void main() {
  PlanSession session({required bool sent}) => PlanSession(
    id: 7,
    weekIndex: 0,
    date: DateTime(2026, 11, 7),
    slot: SessionSlot.long,
    templateId: 'long_distance.long',
    name: 'Long endurance',
    sport: 'Ride',
    minutes: 150,
    load: 145,
    lowMinutes: 120,
    description: '- 15m 55%\n- 125m 70%\n- 10m 50%',
    intervalsEventId: sent ? '501' : null,
    status: sent ? PlanSessionStatus.created : PlanSessionStatus.planned,
  );

  Future<void> pump(WidgetTester tester, PlanSession s) => tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: SingleChildScrollView(
          child: CalendarDayDetail(
            date: s.date,
            events: [PlannedItemsRepository.toLocalEvent(s)],
            activities: const [],
          ),
        ),
      ),
    ),
  );

  testWidgets('a local plan session is marked and opens its steps', (
    tester,
  ) async {
    await pump(tester, session(sent: false));

    expect(
      find.textContaining('TriIQ plan · 150 min · 145 TSS'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
    // A session that only lives in TriIQ can always be deleted.
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('plan-session-7')));
    await tester.pumpAndSettle();

    expect(find.text('Only in TriIQ'), findsOneWidget);
    expect(find.textContaining('125m 70%'), findsOneWidget);
  });

  testWidgets('a sent plan session says so', (tester) async {
    await pump(tester, session(sent: true));

    expect(find.byIcon(Icons.cloud_done_outlined), findsOneWidget);
    // Deleting a sent one removes it in Intervals.icu too, so it needs a
    // connection, which the test doesn't have.
    expect(find.byIcon(Icons.delete_outline), findsNothing);
    await tester.tap(find.byKey(const ValueKey('plan-session-7')));
    await tester.pumpAndSettle();
    expect(find.text('Sent to Intervals.icu'), findsOneWidget);
  });
}
