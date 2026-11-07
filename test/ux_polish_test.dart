import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/client/intervalls/intervalls_client.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/intervals_session.dart';
import 'package:triiq/data/intervals_workout_service.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/data/pending_deletes.dart';
import 'package:triiq/data/pending_writes.dart';
import 'package:triiq/data/planned_items.dart';
import 'package:triiq/data/repositories/events_repository.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/data/repositories/sync_state_repository.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/activities/planned_workout_actions.dart';
import 'package:triiq/widgets/skeleton.dart';
import 'package:triiq/widgets/sync_status_chip.dart';

Widget _app(Widget home) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: Scaffold(body: home),
);

Future<AppLocalizations> _l10n(WidgetTester tester) async {
  late AppLocalizations l10n;
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Builder(
        builder: (c) {
          l10n = AppLocalizations.of(c)!;
          return const SizedBox();
        },
      ),
    ),
  );
  return l10n;
}

void main() {
  group('sync status', () {
    final now = DateTime(2026, 11, 7, 12, 0);

    test('age is just now / minutes / hours / days', () {
      expect(
        syncAge(now.subtract(const Duration(seconds: 20)), now).unit,
        SyncAgeUnit.now,
      );
      final m = syncAge(now.subtract(const Duration(minutes: 5)), now);
      expect((m.unit, m.value), (SyncAgeUnit.minutes, 5));
      final h = syncAge(
        now.subtract(const Duration(hours: 3, minutes: 10)),
        now,
      );
      expect((h.unit, h.value), (SyncAgeUnit.hours, 3));
      final d = syncAge(now.subtract(const Duration(days: 2, hours: 1)), now);
      expect((d.unit, d.value), (SyncAgeUnit.days, 2));
    });

    testWidgets(
      'failed writes outrank waiting, then not connected, then freshness',
      (tester) async {
        final l10n = await _l10n(tester);
        SyncStatus status({
          bool connected = true,
          int pending = 0,
          int failed = 0,
          DateTime? last,
        }) => syncStatusFor(
          l10n,
          connected: connected,
          pending: pending,
          failed: failed,
          lastSyncedAt: last,
          now: now,
        );

        expect(status(failed: 2, pending: 3).text, '2 failed to send');
        expect(status(failed: 2).health, SyncHealth.attention);
        expect(status(pending: 3, connected: false).text, '3 waiting to send');
        expect(status(connected: false).text, 'Not connected');
        expect(status(connected: false).health, SyncHealth.offline);
        expect(status().text, 'Not synced yet');
        expect(status().health, SyncHealth.stale);
        expect(status(last: now).text, 'Synced just now');
        expect(
          status(last: now.subtract(const Duration(minutes: 12))).text,
          'Synced 12 min ago',
        );
        expect(
          status(last: now.subtract(const Duration(hours: 5))).text,
          'Synced 5 h ago',
        );
        final old = status(last: now.subtract(const Duration(days: 3)));
        expect(old.text, 'Synced 3 d ago');
        expect(old.health, SyncHealth.stale);
      },
    );

    testWidgets(
      'the chip shows the newest sync and opens the Sync screen on tap',
      (tester) async {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
        // Real I/O has to run outside the test's fake-async zone.
      final dir = (await tester.runAsync(
        () => Directory.systemTemp.createTemp('triiq_chip'),
      ))!;
        final db = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
        addTearDown(() async {
          await db.close();
          await dir.delete(recursive: true);
        });
        final state = SyncStateRepository(database: db);
        await tester.runAsync(() async {
          await state.recordSync(
            'activities',
            oldest: '2026-11-01',
            newest: '2026-11-07',
          );
        });

        var opened = 0;
        final queue = PendingWritesService(
          repository: PendingWritesRepository(database: db),
          athleteId: () async => 'i1',
          connectedAthleteId: () => 'i1',
        );
        await tester.pumpWidget(
          _app(
            SyncStatusChip(
              state: state,
              queue: queue,
              session: IntervalsSession.instance,
              // Just after the sync was recorded (it stamps the real clock).
              now: () => DateTime.now().add(const Duration(minutes: 7)),
              onTap: () => opened++,
            ),
          ),
        );
        for (var i = 0; i < 10; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 20)),
          );
          await tester.pump();
        }

        // Not connected in the test session, so that is what it says.
        expect(find.byKey(const ValueKey('sync-status-text')), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('sync-status')));
        expect(opened, 1);
      },
    );
  });

  group('skeletons', () {
    testWidgets('a block, a card, a screen and a list build', (tester) async {
      await tester.pumpWidget(
        _app(
          const SizedBox(
            height: 900,
            child: Column(
              children: [
                Skeleton(width: 100, height: 14),
                SkeletonCard(lines: 2),
                Expanded(child: SkeletonList(rows: 3)),
              ],
            ),
          ),
        ),
      );
      expect(find.byKey(const ValueKey('skeleton')), findsWidgets);
      expect(find.byKey(const ValueKey('skeleton-list')), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(_app(const SkeletonScreen(cards: 2)));
      expect(find.byType(SkeletonCard), findsNWidgets(2));
    });

    testWidgets('it does not animate when reduced motion is on', (
      tester,
    ) async {
      // The MediaQuery goes inside the app: MaterialApp replaces an outer one.
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: const Skeleton(width: 80, height: 12),
            ),
          ),
        ),
      );
      // With no running animation, the tree settles at once.
      await tester.pumpAndSettle(const Duration(milliseconds: 50));
      expect(find.byKey(const ValueKey('skeleton')), findsOneWidget);
    });
  });

  group('delete with undo', () {
    late Directory dir;
    late AppDatabase database;
    late EventsRepository events;
    late PlansRepository plans;
    late _Writer writer;
    final day = DateTime(2026, 11, 8);

    LocalEvent event() => LocalEvent(
      id: '501',
      date: '2026-11-08',
      category: 'WORKOUT',
      type: 'Ride',
      name: 'Coach ride',
      description: '- 60m 65%',
      plannedLoad: 60,
      plannedTime: 3600,
      plannedDistance: null,
      indoor: false,
      raw: const {},
      syncedAt: day,
    );

    setUp(() async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      dir = await Directory.systemTemp.createTemp('triiq_undo');
      database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
      events = EventsRepository(database: database);
      plans = PlansRepository(database: database);
      writer = _Writer();
      await events.replaceRange('2026-11-08', '2026-11-08', [event()]);
    });

    tearDown(() async {
      PendingDeletes.instance.restore('501');
      await database.close();
      await dir.delete(recursive: true);
    });

    Future<PendingDeletes> pumpDeleteButton(WidgetTester tester) async {
      final hidden = PendingDeletes.forTesting();
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => TextButton(
              key: const ValueKey('delete'),
              onPressed: () => deletePlannedWorkoutWithUndo(
                context,
                event(),
                workoutService: writer,
                eventsRepository: events,
                plansRepository: plans,
                pendingDeletes: hidden,
              ),
              child: const Text('delete'),
            ),
          ),
        ),
      );
      return hidden;
    }

    testWidgets(
      'it vanishes at once, and Undo brings it back without deleting',
      (tester) async {
        final hidden = await pumpDeleteButton(tester);

        await tester.tap(find.byKey(const ValueKey('delete')));
        await tester.pump();
        expect(hidden.isHidden('501'), isTrue);
        expect(find.text('“Coach ride” deleted'), findsOneWidget);
        expect(find.text('Undo'), findsOneWidget);
        expect(writer.deleted, isEmpty); // nothing written yet

        // Let the snackbar finish sliding in before pressing its action.
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Undo'));
      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(milliseconds: 400));
      }
        expect(hidden.isHidden('501'), isFalse);
        expect(writer.deleted, isEmpty);
        expect(
          await tester.runAsync(() => events.getByDate('2026-11-08')),
          hasLength(1),
        );
      },
    );

    testWidgets(
      'when the window ends it is deleted upstream and from the cache',
      (tester) async {
        final hidden = await pumpDeleteButton(tester);
        await tester.tap(find.byKey(const ValueKey('delete')));
        await tester.pump();

        // Step the clock: the dismiss timer starts after the entrance animation.
        for (var i = 0; i < 9; i++) {
          await tester.pump(const Duration(seconds: 1));
        }
        for (var i = 0; i < 10; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 20)),
          );
          await tester.pump();
        }

        expect(writer.deleted, ['501']);
        expect(
          await tester.runAsync(() => events.getByDate('2026-11-08')),
          isEmpty,
        );
        expect(hidden.isHidden('501'), isFalse);
      },
    );

    testWidgets('a failed delete brings the session back and says why', (
      tester,
    ) async {
      writer.error = StateError('server said no');
      final hidden = await pumpDeleteButton(tester);
      await tester.tap(find.byKey(const ValueKey('delete')));
      await tester.pump();

      // Step the clock: the dismiss timer starts after the entrance animation.
      for (var i = 0; i < 9; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      for (var i = 0; i < 10; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }

      expect(hidden.isHidden('501'), isFalse);
      expect(
        await tester.runAsync(() => events.getByDate('2026-11-08')),
        hasLength(1),
      );
      expect(find.textContaining('server said no'), findsOneWidget);
    });

    test('calendar lists skip a hidden entry until it is restored', () async {
      final items = PlannedItemsRepository(
        events: events,
        plans: plans,
        copyEvents: () async => true,
      );
      expect(await items.getByDate('2026-11-08'), hasLength(1));

      PendingDeletes.instance.hide('501');
      expect(await items.getByDate('2026-11-08'), isEmpty);

      PendingDeletes.instance.restore('501');
      expect(await items.getByDate('2026-11-08'), hasLength(1));
    });

    test('hiding and restoring notify listeners once each', () {
      final hidden = PendingDeletes.forTesting();
      var n = 0;
      hidden.addListener(() => n++);
      hidden.hide('a');
      hidden.hide('a');
      hidden.restore('a');
      hidden.restore('a');
      expect(n, 2);
      expect(hidden.isEmpty, isTrue);
    });
  });
}

class _Writer implements PlannedWorkoutWriter {
  final deleted = <String>[];
  Object? error;

  @override
  Future<Event> createPlannedWorkout(PlannedWorkoutDraft draft) async =>
      Event(id: 900);

  @override
  Future<void> updatePlannedWorkoutDate(String eventId, DateTime date) async {}

  @override
  Future<void> deletePlannedWorkout(String eventId) async {
    if (error != null) throw error!;
    deleted.add(eventId);
  }
}
