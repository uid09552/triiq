import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/client/intervalls/intervalls_client.dart';
import 'package:triiq/data/intervals_workout_service.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/plan/bodyweight_strength.dart';
import 'package:triiq/screens/calendar/add_strength_sheet.dart';
import 'package:triiq/screens/calendar/day_actions.dart';

class _RecordingWorkouts implements PlannedWorkoutWriter {
  final created = <PlannedWorkoutDraft>[];

  @override
  Future<Event> createPlannedWorkout(PlannedWorkoutDraft draft) async {
    created.add(draft);
    return Event(id: created.length, name: draft.name);
  }

  @override
  Future<void> updatePlannedWorkoutDate(String eventId, DateTime date) async {}

  @override
  Future<void> deletePlannedWorkout(String eventId) async {}
}

void main() {
  final day = DateTime(2026, 11, 24);

  Future<void> pump(WidgetTester t, Widget Function(BuildContext) onPress) =>
      t.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  key: const ValueKey('go'),
                  onPressed: () => onPress(context),
                  child: const Text('go'),
                ),
              ),
            ),
          ),
        ),
      );

  testWidgets('day actions offer strength training for a coming day', (
    t,
  ) async {
    final opened = <DateTime>[];
    await pump(t, (context) {
      showDayActions(
        context,
        day,
        const [],
        today: () => DateTime(2026, 11, 20),
        openAddStrength: (_, d) => opened.add(d),
      );
      return const SizedBox();
    });
    await t.tap(find.byKey(const ValueKey('go')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('day-add-strength')));
    await t.pumpAndSettle();
    expect(opened, [day]);
  });

  testWidgets('adding writes a bodyweight WeightTraining session', (t) async {
    final writer = _RecordingWorkouts();
    final synced = <DateTime>[];
    await pump(t, (context) {
      showAddStrengthSheet(
        context,
        day,
        writer: writer,
        connected: true,
        afterCreate: (d) async => synced.add(d),
      );
      return const SizedBox();
    });
    await t.tap(find.byKey(const ValueKey('go')));
    await t.pumpAndSettle();

    // Swim off, run off: ride only, 20 minutes.
    await t.tap(find.byKey(const ValueKey('strength-target-swim')));
    await t.pump();
    await t.tap(find.byKey(const ValueKey('strength-target-run')));
    await t.pump();
    await t.tap(find.text('20 min'));
    await t.pumpAndSettle();
    expect(find.text('Bodyweight squat'), findsOneWidget);
    expect(find.text('Push-ups'), findsNothing);

    await t.tap(find.byKey(const ValueKey('strength-add')));
    await t.pumpAndSettle();
    final draft = writer.created.single;
    expect(draft.sport, bodyweightStrengthSport);
    expect(draft.name, 'Bodyweight strength · Ride');
    expect(draft.durationSeconds, 20 * 60);
    expect(draft.date, day);
    expect(draft.description, contains('Wall sit'));
    expect(synced, [day]);
  });

  testWidgets('the last sport cannot be switched off', (t) async {
    await pump(t, (context) {
      showAddStrengthSheet(context, day, connected: true);
      return const SizedBox();
    });
    await t.tap(find.byKey(const ValueKey('go')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('strength-target-swim')));
    await t.pump();
    await t.tap(find.byKey(const ValueKey('strength-target-ride')));
    await t.pump();
    await t.tap(find.byKey(const ValueKey('strength-target-run')));
    await t.pump();
    await t.pumpAndSettle();
    final run = t.widget<FilterChip>(
      find.byKey(const ValueKey('strength-target-run')),
    );
    expect(run.selected, isTrue);
  });

  testWidgets('offline: adding is disabled, the trainer route still works', (
    t,
  ) async {
    Set<StrengthTarget>? asked;
    await pump(t, (context) {
      showAddStrengthSheet(
        context,
        day,
        connected: false,
        openTrainer: (_, _, targets, _) => asked = targets,
      );
      return const SizedBox();
    });
    await t.tap(find.byKey(const ValueKey('go')));
    await t.pumpAndSettle();
    final add = t.widget<ButtonStyleButton>(
      find.byKey(const ValueKey('strength-add')),
    );
    expect(add.onPressed, isNull);
    await t.tap(find.byKey(const ValueKey('strength-ask-trainer')));
    await t.pumpAndSettle();
    expect(asked, {...StrengthTarget.values});
  });
}
