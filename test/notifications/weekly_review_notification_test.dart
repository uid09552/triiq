import 'dart:ui';

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:langchain_core/chat_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/agent/llm_settings.dart';
import 'package:triiq/evaluation/weekly_review_summary.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/notifications/notification_service.dart';
import 'package:triiq/notifications/notification_settings.dart';
import 'package:triiq/notifications/notification_taps.dart';
import 'package:triiq/notifications/weekly_review_notification.dart';

WeeklyReviewSummary summary({
  DateTime? weekStart,
  DateTime? asOf,
  int activities = 4,
  int planned = 5,
  bool full = true,
}) {
  final monday = weekStart ?? DateTime(2026, 11, 2);
  return WeeklyReviewSummary(
    weekStart: monday,
    asOf: asOf ?? DateTime(2026, 11, 8, 19),
    activities: activities,
    load: 420,
    targetLoad: full ? 450 : null,
    sports: full
        ? const [
            SportProgress(
              sport: 'run',
              seconds: 3 * 3600,
              targetSeconds: 4 * 3600,
            ),
          ]
        : const [],
    plannedSessions: planned,
    completedSessions: planned == 0 ? 0 : planned - 1,
    missedSessions: planned == 0 ? 0 : 1,
    keySession: full
        ? KeySession(date: DateTime(2026, 11, 7), name: 'Long run', hit: true)
        : null,
    ctlChange: full ? 3.4 : null,
    ctlEnd: full ? 58.2 : null,
    formEnd: full ? -8.4 : null,
    usualCtlChange: 2,
    rampHigh: full,
    readyDays: full ? 4 : 0,
    cautionDays: full ? 2 : 0,
    backOffDays: full ? 1 : 0,
    hrv: full ? TrendDirection.up : null,
    restingHr: full ? TrendDirection.down : null,
    phase: full ? 'build' : null,
    next: full
        ? NextWeekOutlook(
            targetLoad: 480,
            phase: 'build',
            keySessions: [
              KeySession(date: DateTime(2026, 11, 10), name: 'Intervals'),
            ],
            events: [
              UpcomingEvent(
                date: DateTime(2026, 11, 15),
                name: 'City 10k',
                category: 'RACE_B',
              ),
            ],
          )
        : const NextWeekOutlook(),
  );
}

class _Notifications implements NotificationService {
  _Notifications({this.scheduled = true});

  final bool scheduled;
  DateTime? at;
  String? title;
  String? body;
  String? payload;
  bool cancelled = false;
  int shown = 0;

  @override
  bool get supportsScheduledReminder => scheduled;

  @override
  bool get showsMissedOnStart => !scheduled;

  @override
  Future<void> scheduleWeeklyReview({
    required DateTime at,
    required String title,
    required String body,
    required String payload,
  }) async {
    this.at = at;
    this.title = title;
    this.body = body;
    this.payload = payload;
  }

  @override
  Future<void> showWeeklyReview({
    required String title,
    required String body,
    required String payload,
  }) async {
    shown++;
    this.body = body;
    this.payload = payload;
  }

  @override
  Future<void> cancelWeeklyReview() async => cancelled = true;

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Loader implements WeeklyReviewSummaryLoader {
  _Loader(this.make);

  final WeeklyReviewSummary Function(DateTime week) make;
  final weeks = <DateTime>[];

  @override
  Future<WeeklyReviewSummary> load(DateTime anyDayOfWeek) async {
    weeks.add(anyDayOfWeek);
    return make(anyDayOfWeek);
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('de');
  });
  final en = lookupAppLocalizations(const Locale('en'));
  final de = lookupAppLocalizations(const Locale('de'));

  group('nextDue', () {
    const t = TimeOfDay(hour: 19, minute: 0);

    test('later the same day, else the same weekday next week', () {
      // Sunday 8 Nov 2026.
      expect(
        WeeklyReviewScheduler.nextDue(DateTime(2026, 11, 8, 18), 7, t),
        DateTime(2026, 11, 8, 19),
      );
      expect(
        WeeklyReviewScheduler.nextDue(DateTime(2026, 11, 8, 19), 7, t),
        DateTime(2026, 11, 15, 19),
      );
    });

    test('the coming weekday, across a month end', () {
      // Wednesday 28 Oct → Sunday 1 Nov; Monday review → Monday 2 Nov.
      expect(
        WeeklyReviewScheduler.nextDue(DateTime(2026, 10, 28, 9), 7, t),
        DateTime(2026, 11, 1, 19),
      );
      expect(
        WeeklyReviewScheduler.nextDue(
          DateTime(2026, 10, 28, 9),
          1,
          const TimeOfDay(hour: 8, minute: 30),
        ),
        DateTime(2026, 11, 2, 8, 30),
      );
    });

    test('keeps the wall-clock time across a DST change', () {
      // Europe's clocks go back on 25 Oct 2026: a week of 7×24 h would land
      // an hour off; calendar arithmetic does not.
      final at = WeeklyReviewScheduler.nextDue(
        DateTime(2026, 10, 19, 12),
        7,
        t,
      );
      expect(
        (at.year, at.month, at.day, at.hour, at.minute),
        (2026, 10, 25, 19, 0),
      );
      final last = WeeklyReviewScheduler.lastDue(
        DateTime(2026, 10, 26, 12),
        7,
        t,
      );
      expect((last.day, last.hour), (25, 19));
    });

    test(
      'Friday to Sunday reviews that week, earlier days the week before',
      () {
        expect(
          WeeklyReviewScheduler.reviewedWeek(DateTime(2026, 11, 8, 19)),
          DateTime(2026, 11, 2),
        );
        expect(
          WeeklyReviewScheduler.reviewedWeek(DateTime(2026, 11, 6, 19)),
          DateTime(2026, 11, 2),
        );
        expect(
          WeeklyReviewScheduler.reviewedWeek(DateTime(2026, 11, 9, 8)),
          DateTime(2026, 11, 2),
        );
      },
    );
  });

  group('compose', () {
    test('full week in English', () {
      final c = composeWeeklyReview(l10n: en, locale: 'en', summary: summary());
      expect(c.title, 'Your week · Nov 2 – Nov 8');
      final lines = c.body.split('\n');
      expect(lines[0], 'Load 420 of 450 TSS (93%) · Run 3/4 h');
      expect(
        lines[1],
        'Sessions 4/5 done · 1 missed · key session done: Long run',
      );
      expect(lines[2], 'CTL +3 → 58 · Form -8 · ramp above usual');
      expect(
        lines[3],
        'Readiness: 4 ready, 2 caution, 1 back off · HRV ↑ · Resting HR ↓',
      );
      expect(lines[4], startsWith('Next week: 480 TSS · '));
      expect(lines[4], contains('Tue Intervals'));
      expect(lines[4], contains('Race City 10k (Sun)'));
      expect(lines, hasLength(5));
    });

    test('a week without plan or wellness keeps only the load line', () {
      final c = composeWeeklyReview(
        l10n: en,
        locale: 'en',
        summary: summary(full: false, planned: 0),
      );
      expect(c.body, 'Load 420 TSS');
    });

    test('German, with the trainer sentence last', () {
      final c = composeWeeklyReview(
        l10n: de,
        locale: 'de',
        summary: summary(),
        comment: ' Solide Woche. ',
      );
      expect(c.title, startsWith('Deine Woche'));
      expect(c.body, contains('Belastung 420 von 450 TSS'));
      expect(c.body, contains('Ruhepuls ↓'));
      expect(c.body.split('\n').last, 'Solide Woche.');
    });
  });

  group('settings', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('defaults: off, Sunday 19:00, no trainer comment', () async {
      final s = NotificationSettings.forTesting();
      await s.load();
      expect(s.weeklyReviewEnabled, isFalse);
      expect(s.weeklyReviewWeekday, DateTime.sunday);
      expect(s.weeklyReviewTime, const TimeOfDay(hour: 19, minute: 0));
      expect(s.weeklyReviewTrainerComment, isFalse);
    });

    test('persist and reload', () async {
      final s = NotificationSettings.forTesting();
      await s.load();
      await s.setWeeklyReviewEnabled(true);
      await s.setWeeklyReviewWeekday(DateTime.monday);
      await s.setWeeklyReviewTime(const TimeOfDay(hour: 7, minute: 45));
      await s.setWeeklyReviewTrainerComment(true);
      await s.setWeeklyReviewWeekday(9); // ignored
      final again = NotificationSettings.forTesting();
      await again.load();
      expect(again.weeklyReviewEnabled, isTrue);
      expect(again.weeklyReviewWeekday, DateTime.monday);
      expect(again.weeklyReviewTime, const TimeOfDay(hour: 7, minute: 45));
      expect(again.weeklyReviewTrainerComment, isTrue);
    });
  });

  group('trainer comment', () {
    late LlmSettings configured;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      WeeklyReviewComment.clearCache();
      configured = LlmSettings.forTesting();
      await configured.load();
      await configured.setClaudeApiKey('sk-ant-test');
    });

    test('one cleaned sentence, cached for the same figures', () async {
      var calls = 0;
      final c = WeeklyReviewComment(
        settings: configured,
        chatCall: (_, _) async {
          calls++;
          return AIChatMessage.text('"Solid week — keep Sunday easy."\nMore');
        },
      );
      expect(
        await c.sentence(summary(), 'en'),
        'Solid week — keep Sunday easy.',
      );
      expect(
        await c.sentence(summary(), 'en'),
        'Solid week — keep Sunday easy.',
      );
      expect(calls, 1);
    });

    test('an error or a timeout gives no sentence', () async {
      final failing = WeeklyReviewComment(
        settings: configured,
        chatCall: (_, _) async => throw Exception('offline'),
      );
      expect(await failing.sentence(summary(), 'en'), isNull);
      final slow = WeeklyReviewComment(
        settings: configured,
        timeout: const Duration(milliseconds: 20),
        chatCall: (_, _) async {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          return AIChatMessage.text('Too late.');
        },
      );
      expect(
        await slow.sentence(summary(asOf: DateTime(2026, 11, 8)), 'en'),
        isNull,
      );
    });

    test('no provider: no call', () async {
      SharedPreferences.setMockInitialValues({});
      final none = LlmSettings.forTesting();
      await none.load();
      var called = false;
      final c = WeeklyReviewComment(
        settings: none,
        chatCall: (_, _) async {
          called = true;
          return AIChatMessage.text('x');
        },
      );
      expect(await c.sentence(summary(), 'en'), isNull);
      expect(called, isFalse);
    });
  });

  group('scheduler', () {
    late NotificationSettings settings;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      WeeklyReviewComment.clearCache();
      settings = NotificationSettings.forTesting();
      await settings.load();
    });

    WeeklyReviewScheduler scheduler(
      _Notifications n,
      DateTime now, {
      _Loader? loader,
      WeeklyReviewComment? comment,
    }) => WeeklyReviewScheduler(
      settings: settings,
      notifications: n,
      loader: loader ?? _Loader((w) => summary(weekStart: w, asOf: now)),
      comment: comment,
      clock: () => now,
      l10n: () => en,
    );

    test('off, or notifications off: cancels', () async {
      final n = _Notifications();
      await scheduler(n, DateTime(2026, 11, 4, 9)).refresh();
      expect(n.cancelled, isTrue);
      await settings.setWeeklyReviewEnabled(true); // master still off
      final m = _Notifications();
      await scheduler(m, DateTime(2026, 11, 4, 9)).refresh();
      expect(m.cancelled, isTrue);
      expect(m.at, isNull);
    });

    test(
      'on: schedules Sunday 19:00 for this week with a tap payload',
      () async {
        await settings.setEnabled(true);
        await settings.setWeeklyReviewEnabled(true);
        final n = _Notifications();
        final loader = _Loader((w) => summary(weekStart: w));
        await scheduler(n, DateTime(2026, 11, 4, 9), loader: loader).refresh();
        expect(n.at, DateTime(2026, 11, 8, 19));
        expect(loader.weeks.single, DateTime(2026, 11, 2));
        expect(n.body, contains('Load 420 of 450 TSS'));
        expect(n.payload, 'weekly_review:2026-11-02');
        expect(weeklyReviewWeekOf(n.payload!), DateTime(2026, 11, 2));
      },
    );

    test('a week with no data: cancels instead of scheduling', () async {
      await settings.setEnabled(true);
      await settings.setWeeklyReviewEnabled(true);
      final n = _Notifications();
      await scheduler(
        n,
        DateTime(2026, 11, 4, 9),
        loader: _Loader(
          (w) => summary(weekStart: w, activities: 0, planned: 0),
        ),
      ).refresh();
      expect(n.cancelled, isTrue);
      expect(n.at, isNull);
    });

    test(
      'trainer sentence only when switched on and the review is near',
      () async {
        await settings.setEnabled(true);
        await settings.setWeeklyReviewEnabled(true);
        await settings.setWeeklyReviewTrainerComment(true);
        final llm = LlmSettings.forTesting();
        await llm.load();
        await llm.setClaudeApiKey('sk-ant-test');
        var calls = 0;
        final comment = WeeklyReviewComment(
          settings: llm,
          chatCall: (_, _) async {
            calls++;
            return AIChatMessage.text('Good consistency.');
          },
        );
        // Wednesday: four days out — no provider call.
        final early = _Notifications();
        await scheduler(
          early,
          DateTime(2026, 11, 4, 9),
          comment: comment,
        ).refresh();
        expect(calls, 0);
        expect(early.body, isNot(contains('Good consistency.')));
        // Saturday: within the window.
        final late = _Notifications();
        await scheduler(
          late,
          DateTime(2026, 11, 7, 20),
          comment: comment,
        ).refresh();
        expect(calls, 1);
        expect(late.body!.split('\n').last, 'Good consistency.');

        // A failing provider: same numbers, no sentence.
        WeeklyReviewComment.clearCache();
        final failing = _Notifications();
        await scheduler(
          failing,
          DateTime(2026, 11, 7, 20),
          comment: WeeklyReviewComment(
            settings: llm,
            chatCall: (_, _) async => throw Exception('down'),
          ),
        ).refresh();
        expect(failing.at, DateTime(2026, 11, 8, 19));
        expect(failing.body, isNot(contains('Good consistency.')));
      },
    );

    test('missed-on-start: shows once after the due time, not on first '
        'enable', () async {
      await settings.setEnabled(true);
      await settings.setWeeklyReviewEnabled(true);
      final n = _Notifications(scheduled: false);
      // First run after switching on: only records the moment.
      await scheduler(n, DateTime(2026, 11, 4, 9)).refresh();
      expect(n.shown, 0);
      // Before Sunday 19:00 nothing is due.
      await scheduler(n, DateTime(2026, 11, 8, 18)).refresh();
      expect(n.shown, 0);
      // Monday morning: Sunday's review was missed — show it, once.
      final loader = _Loader((w) => summary(weekStart: w));
      await scheduler(n, DateTime(2026, 11, 9, 8), loader: loader).refresh();
      expect(n.shown, 1);
      expect(loader.weeks.single, DateTime(2026, 11, 2));
      expect(n.payload, 'weekly_review:2026-11-02');
      await scheduler(n, DateTime(2026, 11, 9, 10)).refresh();
      expect(n.shown, 1);
    });
  });
}
