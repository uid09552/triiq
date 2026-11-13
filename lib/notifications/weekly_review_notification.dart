import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:langchain_core/chat_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../agent/chat_model_factory.dart';
import '../agent/llm_settings.dart';
import '../data/privacy_settings.dart';
import '../evaluation/weekly_review_summary.dart';
import '../l10n/app_localizations.dart';
import '../screens/plan/plan_labels.dart' show phaseLabel;
import '../util/dates.dart';
import 'morning_briefing.dart' show BriefingContent, MorningBriefingScheduler;
import 'notification_service.dart';
import 'notification_settings.dart';
import 'notification_taps.dart';

String _signed(num v) {
  final r = v.round();
  return r > 0 ? '+$r' : '$r';
}

String _hours(int seconds) {
  final h = seconds / 3600;
  return h == h.roundToDouble() ? h.round().toString() : h.toStringAsFixed(1);
}

String _sport(AppLocalizations l10n, String sport) => switch (sport) {
  'swim' => l10n.sportSwim,
  'cycle' => l10n.sportRide,
  'run' => l10n.sportRun,
  _ => sport,
};

String _arrow(TrendDirection d) => switch (d) {
  TrendDirection.up => '↑',
  TrendDirection.down => '↓',
  TrendDirection.stable => '→',
};

/// Composes the weekly-review notification. Pure: the figures come from
/// [summary]; [comment] is the optional trainer sentence, appended last.
BriefingContent composeWeeklyReview({
  required AppLocalizations l10n,
  required String locale,
  required WeeklyReviewSummary summary,
  String? comment,
}) {
  final s = summary;
  final today = dateOnly(s.asOf);
  final range =
      '${DateFormat.MMMd(locale).format(s.weekStart)} – '
      '${DateFormat.MMMd(locale).format(s.weekEnd)}';

  final load = [
    s.targetLoad == null || s.targetLoad == 0
        ? l10n.weeklyReviewLoad(s.load)
        : l10n.weeklyReviewLoadOfTarget(
            s.load,
            s.targetLoad!,
            (100 * s.load / s.targetLoad!).round(),
          ),
    for (final p in s.sports)
      '${_sport(l10n, p.sport)} ${_hours(p.seconds)}/${_hours(p.targetSeconds)} h',
  ].join(' · ');

  final key = s.keySession;
  final sessions = s.plannedSessions == 0
      ? null
      : [
          l10n.weeklyReviewSessions(s.completedSessions, s.plannedSessions),
          if (s.missedSessions > 0) l10n.weeklyReviewMissed(s.missedSessions),
          if (key != null && key.hit == true)
            l10n.weeklyReviewKeyHit(key.name)
          else if (key != null && key.date.isBefore(today))
            l10n.weeklyReviewKeyMissed(key.name),
        ].join(' · ');

  final fitness = [
    if (s.ctlChange != null && s.ctlEnd != null)
      l10n.weeklyReviewCtl(_signed(s.ctlChange!), s.ctlEnd!.round().toString()),
    if (s.formEnd != null) l10n.weeklyReviewForm(_signed(s.formEnd!)),
    if (s.rampHigh) l10n.weeklyReviewRampHigh,
  ].join(' · ');

  final readinessDays = s.readyDays + s.cautionDays + s.backOffDays;
  final readiness = [
    if (readinessDays > 0)
      l10n.weeklyReviewReadiness(s.readyDays, s.cautionDays, s.backOffDays),
    if (s.hrv != null) l10n.weeklyReviewHrv(_arrow(s.hrv!)),
    if (s.restingHr != null) l10n.weeklyReviewRestingHr(_arrow(s.restingHr!)),
  ].join(' · ');

  final weekday = DateFormat.E(locale);
  final n = s.next;
  final next = n.isEmpty
      ? null
      : l10n.weeklyReviewNext(
          [
            if (n.targetLoad != null) '${n.targetLoad} TSS',
            if (n.phase != null) phaseLabel(l10n, n.phase!),
            for (final k in n.keySessions)
              '${weekday.format(k.date)} ${k.name}',
            for (final e in n.events)
              l10n.weeklyReviewRace(e.name, weekday.format(e.date)),
          ].join(' · '),
        );

  final lines = [
    load,
    ?sessions,
    if (fitness.isNotEmpty) fitness,
    if (readiness.isNotEmpty) readiness,
    ?next,
    if (comment != null && comment.trim().isNotEmpty) comment.trim(),
  ];
  return BriefingContent(
    title: l10n.weeklyReviewNotificationTitle(range),
    body: lines.join('\n'),
  );
}

/// One sentence on the week from the configured LLM provider, given only
/// the computed figures. Never on the main path: any failure, timeout or
/// empty reply yields `null`, and the notification goes out without it.
class WeeklyReviewComment {
  WeeklyReviewComment({
    LlmSettings? settings,
    Future<AIChatMessage> Function(LlmSettings settings, List<ChatMessage>)?
    chatCall,
    this.timeout = const Duration(seconds: 15),
  }) : _settings = settings ?? LlmSettings.instance,
       _chatCall =
           chatCall ??
           ((settings, messages) => createChatModel(settings).call(messages));

  final LlmSettings _settings;
  final Future<AIChatMessage> Function(LlmSettings, List<ChatMessage>)
  _chatCall;
  final Duration timeout;

  static const maxLength = 220;

  /// Replies by figures, so a re-arm with unchanged numbers asks no one.
  static final _cache = <String, String?>{};

  @visibleForTesting
  static void clearCache() => _cache.clear();

  Future<String?> sentence(WeeklyReviewSummary summary, String locale) async {
    if (!_settings.isLoaded) await _settings.load();
    if (!PrivacySettings.instance.isLoaded) {
      await PrivacySettings.instance.load();
    }
    if (!_settings.isConfigured) return null;
    final figures = jsonEncode(summary.toJson());
    final key = '$locale|$figures';
    if (_cache.containsKey(key)) return _cache[key];
    String? result;
    try {
      final reply = await _chatCall(_settings, [
        ChatMessage.system(
          'You are an endurance coach. Reply with exactly one short sentence '
          '(at most 25 words) on the athlete\'s training week, in the '
          'language with code "$locale". Use only the figures given; do not '
          'state any number that is not in them. No greeting, no markdown.',
        ),
        ChatMessage.humanText(figures),
      ]).timeout(timeout);
      result = _clean(reply.contentAsString);
    } catch (error) {
      debugPrint('WeeklyReviewComment: no sentence: $error');
      return null;
    }
    _cache[key] = result;
    return result;
  }

  static String? _clean(String raw) {
    var text = raw
        .split('\n')
        .map((l) => l.trim())
        .firstWhere((l) => l.isNotEmpty, orElse: () => '');
    text = text.replaceAll(RegExp(r'^["“„*_]+|["”*_]+$'), '').trim();
    if (text.isEmpty) return null;
    if (text.length > maxLength) {
      text = '${text.substring(0, maxLength - 1).trimRight()}…';
    }
    return text;
  }
}

/// Re-arms the weekly review: composes it from the cache for the next time
/// it is due and schedules it, or cancels it when switched off or when the
/// week has nothing in it. Run wherever [MorningBriefingScheduler] runs — at
/// start, after each sync, on plan changes and after the nightly sync.
///
/// Where nothing can be scheduled ([NotificationService.showsMissedOnStart],
/// Windows), a review whose time passed since it was last shown is shown
/// now instead.
class WeeklyReviewScheduler {
  WeeklyReviewScheduler({
    NotificationSettings? settings,
    NotificationService? notifications,
    WeeklyReviewSummaryLoader? loader,
    WeeklyReviewComment? comment,
    DateTime Function()? clock,
    AppLocalizations Function()? l10n,
  }) : _settings = settings ?? NotificationSettings.instance,
       _notifications = notifications ?? NotificationService.instance,
       _loaderOverride = loader,
       _comment = comment ?? WeeklyReviewComment(),
       _clock = clock ?? DateTime.now,
       _l10n = l10n ?? MorningBriefingScheduler.currentL10n;

  final NotificationSettings _settings;
  final NotificationService _notifications;
  final WeeklyReviewSummaryLoader? _loaderOverride;
  final WeeklyReviewComment _comment;
  final DateTime Function() _clock;
  final AppLocalizations Function() _l10n;

  late final WeeklyReviewSummaryLoader _loader =
      _loaderOverride ?? WeeklyReviewSummaryLoader(clock: _clock);

  /// When the review was last shown on the missed-on-start path.
  static const lastShownKey = 'notifications.weekly_review_last_shown';

  /// The trainer sentence is only asked for this close to the due time,
  /// so early-week re-arms cost no provider calls.
  static const commentWindow = Duration(hours: 48);

  /// The next [weekday] at [time] strictly after [now]. Built from calendar
  /// fields, so it stays on [time] across a DST change.
  static DateTime nextDue(DateTime now, int weekday, TimeOfDay time) {
    final ahead = (weekday - now.weekday) % 7;
    final candidate = DateTime(
      now.year,
      now.month,
      now.day + ahead,
      time.hour,
      time.minute,
    );
    return candidate.isAfter(now)
        ? candidate
        : DateTime(
            candidate.year,
            candidate.month,
            candidate.day + 7,
            time.hour,
            time.minute,
          );
  }

  /// The occurrence before [nextDue].
  static DateTime lastDue(DateTime now, int weekday, TimeOfDay time) {
    final next = nextDue(now, weekday, time);
    return DateTime(
      next.year,
      next.month,
      next.day - 7,
      time.hour,
      time.minute,
    );
  }

  /// The Monday of the week a review due at [due] covers: that week when it
  /// is due Friday to Sunday, else the week before (a Monday review looks
  /// back at the week just finished).
  static DateTime reviewedWeek(DateTime due) {
    final monday = startOfWeek(due);
    return due.weekday >= DateTime.friday
        ? monday
        : DateTime(monday.year, monday.month, monday.day - 7);
  }

  Future<void> refresh() async {
    try {
      final scheduled = _notifications.supportsScheduledReminder;
      if (!scheduled && !_notifications.showsMissedOnStart) return;
      if (!_settings.isLoaded) await _settings.load();
      final on = _settings.enabled && _settings.weeklyReviewEnabled;
      if (!scheduled) return await _catchUp(on);
      if (!on) {
        await _notifications.cancelWeeklyReview();
        return;
      }
      final now = _clock();
      final at = nextDue(
        now,
        _settings.weeklyReviewWeekday,
        _settings.weeklyReviewTime,
      );
      final content = await _compose(
        reviewedWeek(at),
        withComment: at.difference(now) <= commentWindow,
      );
      if (content == null) {
        await _notifications.cancelWeeklyReview();
        return;
      }
      await _notifications.scheduleWeeklyReview(
        at: at,
        title: content.$1.title,
        body: content.$1.body,
        payload: content.$2,
      );
    } catch (e) {
      debugPrint('WeeklyReviewScheduler: $e');
    }
  }

  Future<void> _catchUp(bool on) async {
    final prefs = await SharedPreferences.getInstance();
    if (!on) {
      await prefs.remove(lastShownKey);
      return;
    }
    final now = _clock();
    final shown = DateTime.tryParse(prefs.getString(lastShownKey) ?? '');
    if (shown == null) {
      // Just switched on: start counting from now, not from a review
      // that was due before it existed.
      await prefs.setString(lastShownKey, now.toIso8601String());
      return;
    }
    final due = lastDue(
      now,
      _settings.weeklyReviewWeekday,
      _settings.weeklyReviewTime,
    );
    if (!shown.isBefore(due)) return;
    final content = await _compose(reviewedWeek(due), withComment: true);
    await prefs.setString(lastShownKey, now.toIso8601String());
    if (content == null) return;
    await _notifications.showWeeklyReview(
      title: content.$1.title,
      body: content.$1.body,
      payload: content.$2,
    );
  }

  Future<(BriefingContent, String)?> _compose(
    DateTime week, {
    required bool withComment,
  }) async {
    final summary = await _loader.load(week);
    if (!summary.hasData) return null;
    final l10n = _l10n();
    // The background isolate has no MaterialApp that loads date data.
    await initializeDateFormatting(l10n.localeName);
    String? comment;
    if (withComment && _settings.weeklyReviewTrainerComment) {
      comment = await _comment.sentence(summary, l10n.localeName);
    }
    return (
      composeWeeklyReview(
        l10n: l10n,
        locale: l10n.localeName,
        summary: summary,
        comment: comment,
      ),
      weeklyReviewPayload(summary.weekStart),
    );
  }
}
