import 'dart:ui';

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/data/models/local_wellness.dart';
import 'package:triiq/data/planned_items.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/evaluation/fatigue_warning.dart';
import 'package:triiq/evaluation/fatigue_warning_service.dart';
import 'package:triiq/evaluation/readiness.dart';
import 'package:triiq/evaluation/readiness_service.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/notifications/morning_briefing.dart';
import 'package:triiq/notifications/notification_service.dart';
import 'package:triiq/notifications/notification_settings.dart';
import 'package:triiq/season/illness_mode.dart';

LocalEvent workout(
  String name, {
  int? load,
  int? secs,
  String category = 'WORKOUT',
}) => LocalEvent(
  id: name,
  date: '2026-05-20',
  category: category,
  type: 'Run',
  name: name,
  description: null,
  plannedLoad: load,
  plannedTime: secs,
  plannedDistance: null,
  indoor: false,
  raw: const {},
  syncedAt: DateTime(2026),
);

Readiness readiness(ReadinessLevel l, ReadinessDataState s) =>
    Readiness(level: l, signals: const [], dataState: s);

class _Notifications implements NotificationService {
  DateTime? at;
  String? title;
  String? body;
  bool cancelled = false;

  @override
  bool get supportsScheduledReminder => true;

  @override
  Future<void> scheduleBriefing({
    required DateTime at,
    required String title,
    required String body,
  }) async {
    this.at = at;
    this.title = title;
    this.body = body;
  }

  @override
  Future<void> cancelBriefing() async => cancelled = true;

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Planned implements PlannedItemsRepository {
  _Planned(this.items);

  final List<LocalEvent> items;

  @override
  Future<List<LocalEvent>> getByDate(String date) async => items;

  @override
  Future<List<LocalEvent>> getRange(String a, String b) async => items;

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Readiness implements ReadinessService {
  _Readiness(this.r);

  final Readiness r;

  @override
  Future<ReadinessReport> load() async => ReadinessReport(r, const []);

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Fatigue implements FatigueWarningService {
  @override
  Future<FatigueWarning> load() async =>
      const FatigueWarning(level: FatigueLevel.watch, signals: [], window: 5);

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Wellness implements WellnessRepository {
  @override
  Future<List<LocalWellness>> getRange(String a, String b) async => [
    LocalWellness(
      date: '2026-05-19',
      ctl: 62.4,
      atl: 57.0,
      ctlLoad: null,
      atlLoad: null,
      rampRate: null,
      raw: const {},
      syncedAt: DateTime(2026),
    ),
  ];

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('de');
  });
  final en = lookupAppLocalizations(const Locale('en'));
  final de = lookupAppLocalizations(const Locale('de'));
  final day = DateTime(2026, 5, 20);

  test('nextDue is today when still ahead, else tomorrow', () {
    const t = TimeOfDay(hour: 7, minute: 0);
    expect(
      MorningBriefingScheduler.nextDue(DateTime(2026, 5, 20, 6, 30), t),
      DateTime(2026, 5, 20, 7),
    );
    expect(
      MorningBriefingScheduler.nextDue(DateTime(2026, 5, 20, 7, 0), t),
      DateTime(2026, 5, 21, 7),
    );
    expect(
      MorningBriefingScheduler.nextDue(DateTime(2026, 5, 20, 21), t),
      DateTime(2026, 5, 21, 7),
    );
  });

  test('sessions, readiness, fatigue and form in English', () {
    final c = composeBriefing(
      l10n: en,
      locale: 'en',
      day: day,
      planned: [
        workout('Easy run', load: 40, secs: 2700),
        workout('Strength', secs: 1800),
        workout('Swim', load: 30),
        workout('Note', category: 'NOTE'),
      ],
      readiness: readiness(ReadinessLevel.caution, ReadinessDataState.complete),
      fatigue: const FatigueWarning(
        level: FatigueLevel.warning,
        signals: [],
        window: 5,
      ),
      ctl: 62.4,
      atl: 57.0,
    );
    expect(c.title, contains('Wed'));
    expect(
      c.body,
      contains('Easy run · 45 min · 40 TSS | Strength · 30 min | +1 more'),
    );
    expect(c.body, contains('Readiness: caution'));
    expect(c.body, contains('Fatigue: warning'));
    expect(c.body, contains('Form +5 · CTL 62'));
  });

  test(
    'no session, readiness not in yet and no fatigue leave those lines out',
    () {
      final c = composeBriefing(
        l10n: en,
        locale: 'en',
        day: day,
        planned: const [],
        readiness: readiness(
          ReadinessLevel.ready,
          ReadinessDataState.waitingForToday,
        ),
        fatigue: const FatigueWarning(
          level: FatigueLevel.none,
          signals: [],
          window: 5,
        ),
      );
      expect(c.body, 'No session planned today.');
    },
  );

  test('German and an illness line', () {
    final c = composeBriefing(
      l10n: de,
      locale: 'de',
      day: day,
      planned: [workout('Lauf', load: 40, secs: 3600)],
      health: HealthKind.sick,
    );
    expect(c.title, startsWith('Heute'));
    expect(c.body, contains('Geplant: Lauf · 60 min · 40 TSS'));
    expect(c.body, contains('krank'));
  });

  group('scheduler', () {
    late NotificationSettings settings;
    late _Notifications notifications;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      settings = NotificationSettings.forTesting();
      notifications = _Notifications();
    });

    MorningBriefingScheduler scheduler(DateTime now, {Readiness? r}) =>
        MorningBriefingScheduler(
          settings: settings,
          notifications: notifications,
          planned: _Planned([workout('Easy run', load: 40, secs: 2700)]),
          readiness: _Readiness(
            r ??
                readiness(
                  ReadinessLevel.ready,
                  ReadinessDataState.waitingForToday,
                ),
          ),
          fatigue: _Fatigue(),
          wellness: _Wellness(),
          clock: () => now,
          l10n: () => en,
        );

    test('off: cancels instead of scheduling', () async {
      await settings.load();
      await scheduler(DateTime(2026, 5, 20, 6)).refresh();
      expect(notifications.cancelled, isTrue);
      expect(notifications.at, isNull);
    });

    test('on: schedules the next 07:00 with the snapshot text', () async {
      await settings.load();
      await settings.setEnabled(true);
      await settings.setMorningBriefingEnabled(true);
      await scheduler(DateTime(2026, 5, 20, 6)).refresh();
      expect(notifications.at, DateTime(2026, 5, 20, 7));
      expect(notifications.body, contains('Easy run'));
      expect(notifications.body, contains('Fatigue: building'));
      expect(
        notifications.body,
        isNot(contains('Readiness')),
      ); // watch not in yet
    });

    test(
      'after the time it targets tomorrow and omits today-only readiness',
      () async {
        await settings.load();
        await settings.setEnabled(true);
        await settings.setMorningBriefingEnabled(true);
        await scheduler(
          DateTime(2026, 5, 20, 9),
          r: readiness(ReadinessLevel.ready, ReadinessDataState.complete),
        ).refresh();
        expect(notifications.at, DateTime(2026, 5, 21, 7));
        expect(notifications.body, isNot(contains('Readiness')));
      },
    );

    test('readiness appears when today is due and the data is in', () async {
      await settings.load();
      await settings.setEnabled(true);
      await settings.setMorningBriefingEnabled(true);
      await scheduler(
        DateTime(2026, 5, 20, 6, 50),
        r: readiness(ReadinessLevel.backOff, ReadinessDataState.complete),
      ).refresh();
      expect(notifications.body, contains('Readiness: back off'));
    });
  });
}
