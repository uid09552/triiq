import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../data/models/local_event.dart';
import '../data/models/local_wellness.dart';
import '../data/planned_items.dart';
import '../data/repositories/wellness_repository.dart';
import '../evaluation/fatigue_warning.dart';
import '../evaluation/fatigue_warning_service.dart';
import '../evaluation/readiness.dart';
import '../evaluation/readiness_service.dart';
import '../l10n/app_localizations.dart';
import '../locale_controller.dart';
import '../season/illness_mode.dart';
import '../util/dates.dart';
import 'notification_service.dart';
import 'notification_settings.dart';

class BriefingContent {
  const BriefingContent({required this.title, required this.body});

  final String title;
  final String body;
}

/// Composes the morning notification. Pure: every input is passed in, and
/// the parts that aren't known yet (today's readiness before the watch has
/// synced) are simply left out.
BriefingContent composeBriefing({
  required AppLocalizations l10n,
  required String locale,
  required DateTime day,
  required List<LocalEvent> planned,
  Readiness? readiness,
  FatigueWarning? fatigue,
  double? ctl,
  double? atl,
  HealthKind? health,
}) {
  final workouts = [
    for (final e in planned)
      if (e.category == 'WORKOUT') e,
  ];
  String line(LocalEvent e) {
    final mins = e.plannedTime == null ? '' : ' · ${(e.plannedTime! / 60).round()} min';
    final load = e.plannedLoad == null ? '' : ' · ${e.plannedLoad} TSS';
    return '${e.name ?? e.type ?? ''}$mins$load';
  }

  final lines = <String>[
    if (workouts.isEmpty)
      l10n.briefingNoSession
    else
      l10n.briefingSessions(
        [
          ...workouts.take(2).map(line),
          if (workouts.length > 2) l10n.briefingMore(workouts.length - 2),
        ].join(' | '),
      ),
    ?switch (readiness?.dataState) {
      ReadinessDataState.complete => l10n.briefingReadiness(
        switch (readiness!.level) {
          ReadinessLevel.ready => l10n.briefingLevelReady,
          ReadinessLevel.caution => l10n.briefingLevelCaution,
          ReadinessLevel.backOff => l10n.briefingLevelBackOff,
        },
      ),
      _ => null,
    },
    if (fatigue != null && fatigue.level != FatigueLevel.none)
      l10n.briefingFatigue(
        fatigue.level == FatigueLevel.warning
            ? l10n.briefingLevelWarning
            : l10n.briefingLevelWatch,
      ),
    if (health != null)
      l10n.briefingHealth(
        health == HealthKind.sick ? l10n.briefingSick : l10n.briefingInjured,
      ),
    if (ctl != null && atl != null)
      l10n.briefingForm(
        '${ctl - atl >= 0 ? '+' : ''}${(ctl - atl).round()}',
        ctl.round().toString(),
      ),
  ];
  return BriefingContent(
    title: l10n.briefingTitle(DateFormat.MMMEd(locale).format(day)),
    body: lines.join('\n'),
  );
}

/// Re-arms the morning briefing: composes it from the cache for the next
/// time it is due and schedules it, or cancels it when switched off. Run at
/// start, after each sync, on plan changes and after the nightly sync — the
/// notification text is a snapshot of the last of those.
class MorningBriefingScheduler {
  MorningBriefingScheduler({
    NotificationSettings? settings,
    NotificationService? notifications,
    PlannedItemsRepository? planned,
    ReadinessService? readiness,
    FatigueWarningService? fatigue,
    WellnessRepository? wellness,
    DateTime Function()? clock,
    AppLocalizations Function()? l10n,
  }) : _settings = settings ?? NotificationSettings.instance,
       _notifications = notifications ?? NotificationService.instance,
       _planned = planned ?? PlannedItemsRepository(),
       _readiness = readiness ?? ReadinessService(),
       _fatigue = fatigue ?? FatigueWarningService(),
       _wellness = wellness ?? WellnessRepository(),
       _clock = clock ?? DateTime.now,
       _l10n = l10n ?? _currentL10n;

  final NotificationSettings _settings;
  final NotificationService _notifications;
  final PlannedItemsRepository _planned;
  final ReadinessService _readiness;
  final FatigueWarningService _fatigue;
  final WellnessRepository _wellness;
  final DateTime Function() _clock;
  final AppLocalizations Function() _l10n;

  static AppLocalizations _currentL10n() {
    final chosen = LocaleController.instance.locale ?? PlatformDispatcher.instance.locale;
    final code = LocaleController.supportedLocales.any(
          (l) => l.languageCode == chosen.languageCode,
        )
        ? chosen.languageCode
        : 'en';
    return lookupAppLocalizations(Locale(code));
  }

  /// The next moment the briefing is due: today at [time] if that is still
  /// ahead, else tomorrow.
  static DateTime nextDue(DateTime now, TimeOfDay time) {
    final today = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return today.isAfter(now) ? today : today.add(const Duration(days: 1));
  }

  Future<void> refresh() async {
    try {
      if (!_notifications.supportsScheduledReminder) return;
      if (!_settings.isLoaded) await _settings.load();
      if (!_settings.enabled || !_settings.morningBriefingEnabled) {
        await _notifications.cancelBriefing();
        return;
      }
      final now = _clock();
      final at = nextDue(now, _settings.morningBriefingTime);
      final day = dateOnly(at);
      final isToday = day == dateOnly(now);

      final planned = await _planned.getByDate(isoDate(day));

      Readiness? readiness;
      if (isToday) {
        try {
          readiness = (await _readiness.load()).readiness;
        } catch (_) {}
      }
      FatigueWarning? fatigue;
      try {
        fatigue = await _fatigue.load();
      } catch (_) {}

      LocalWellness? latest;
      final recent = await _wellness.getRange(
        isoDate(now.subtract(const Duration(days: 14))),
        isoDate(now),
      );
      for (final w in recent) {
        if (w.ctl != null &&
            w.atl != null &&
            (latest == null || w.date.compareTo(latest.date) > 0)) {
          latest = w;
        }
      }
      HealthKind? health;
      final events = await _planned.getRange(
        isoDate(day.subtract(const Duration(days: 60))),
        isoDate(day),
      );
      health = currentHealthIssue(events, day)?.issue.kind;

      final l10n = _l10n();
      // The background isolate has no MaterialApp that loads date data.
      await initializeDateFormatting(l10n.localeName);
      final content = composeBriefing(
        l10n: l10n,
        locale: l10n.localeName,
        day: day,
        planned: planned,
        readiness: readiness,
        fatigue: fatigue,
        ctl: latest?.ctl,
        atl: latest?.atl,
        health: health,
      );
      await _notifications.scheduleBriefing(
        at: at,
        title: content.title,
        body: content.body,
      );
    } catch (e) {
      debugPrint('MorningBriefingScheduler: $e');
    }
  }
}
