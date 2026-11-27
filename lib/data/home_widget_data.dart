import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../screens/activities/activity_icons.dart' show canonicalSport;
import '../screens/settings/home_widget_settings.dart';
import '../screens/settings/weekly_targets_settings.dart';
import 'models/local_activity.dart';
import 'models/local_event.dart';
import 'models/local_wellness.dart';
import 'planned_items.dart';
import 'repositories/activities_repository.dart';
import 'repositories/wellness_repository.dart';
import '../util/dates.dart';
import 'dart:ui' show Locale, PlatformDispatcher;
import '../evaluation/form_zone.dart';
import '../l10n/app_localizations.dart';
import '../locale_controller.dart';
import '../util/clock.dart';

/// What the Android home-screen widget shows, as plain strings and numbers
/// (the native side only lays them out).
class HomeWidgetData {
  const HomeWidgetData({
    required this.sessions,
    required this.extra,
    required this.doneLoad,
    required this.ctl,
    required this.atl,
    required this.updated,
    this.rings = const [],
  });

  /// One entry per sport with a weekly target (swim, cycle, run).
  final List<WidgetRing> rings;

  /// Up to two lines for today's planned training sessions.
  final List<String> sessions;

  /// Further planned sessions not listed.
  final int extra;

  /// TSS of what was completed today.
  final int doneLoad;
  final double? ctl;
  final double? atl;
  final DateTime updated;

  double? get form => ctl != null && atl != null ? ctl! - atl! : null;

  Map<String, String> _ringEntries(String sport) {
    final ring = rings.where((r) => r.sport == sport).firstOrNull;
    return {
      'w_${sport}_pct': ring == null ? '' : '${ring.percent}',
      'w_${sport}_val': ring == null
          ? ''
          : '${ring.doneHours.toStringAsFixed(1)} / '
                '${ring.targetHours.toStringAsFixed(1)} h',
    };
  }

  static String _minutes(int? seconds) =>
      seconds == null || seconds <= 0 ? '' : ' · ${(seconds / 60).round()} min';

  static String line(LocalEvent e) {
    final load = e.plannedLoad;
    return '${e.name ?? e.type ?? ''}${_minutes(e.plannedTime)}'
        '${load == null ? '' : ' · $load TSS'}';
  }

  /// The widget's storage entries. [show] picks the blocks to display
  /// (default: all): a hidden block's text is left empty and its
  /// `w_show_*` flag is `0`, which the native side uses to drop the view.
  ///
  /// [zoneName] names the Form zone after the number ("−12 · Optimal");
  /// without it only the number shows.
  Map<String, String> toEntries({
    HomeWidgetSettings? show,
    String Function(FormZone zone)? zoneName,
  }) {
    final zone = formZoneOf(ctl, atl);
    final sessionsOn = show?.showSessions ?? true;
    final doneOn = show?.showDone ?? true;
    final formOn = show?.showForm ?? true;
    final fitnessOn = show?.showFitness ?? true;
    final ringsOn = show?.showRings ?? true;
    final updatedOn = show?.showUpdated ?? true;
    String flag(bool on) => on ? '1' : '0';
    return {
      for (final sport in const ['swim', 'cycle', 'run'])
        if (ringsOn)
          ..._ringEntries(sport)
        else ...{
          'w_${sport}_pct': '',
          'w_${sport}_val': '',
        },
      'w_session1': sessionsOn && sessions.isNotEmpty ? sessions[0] : '',
      'w_session2': sessionsOn && sessions.length > 1 ? sessions[1] : '',
      'w_extra': sessionsOn && extra > 0 ? '+$extra' : '',
      'w_done': doneOn && doneLoad > 0 ? '$doneLoad TSS' : '',
      'w_form': formOn && form != null
          ? '${form! >= 0 ? '+' : ''}${form!.round()}'
                '${zone == null || zoneName == null ? '' : ' · ${zoneName(zone)}'}'
          : '',
      'w_fitness': fitnessOn && ctl != null && atl != null
          ? 'CTL ${ctl!.round()} · ATL ${atl!.round()}'
          : '',
      'w_updated': updatedOn
          ? '${updated.hour.toString().padLeft(2, '0')}:'
                '${updated.minute.toString().padLeft(2, '0')}'
          : '',
      'w_show_sessions': flag(sessionsOn),
      'w_show_form': flag(formOn),
      'w_show_fitness': flag(fitnessOn),
      'w_show_updated': flag(updatedOn),
      'w_show_rings': flag(ringsOn),
    };
  }
}

/// A weekly target and how far this week has got towards it.
class WidgetRing {
  const WidgetRing({
    required this.sport,
    required this.targetHours,
    required this.doneHours,
  });

  /// `swim`, `cycle` or `run`.
  final String sport;
  final double targetHours;
  final double doneHours;

  /// Whole percent of the target, not capped (the widget caps the ring).
  int get percent =>
      targetHours <= 0 ? 0 : (doneHours / targetHours * 100).round();
}

/// The rings for the sports that have a weekly target: [targets] maps
/// `swim` / `cycle` / `run` to hours (null = no target), [weekActivities]
/// are this week's activities.
List<WidgetRing> buildWidgetRings(
  Map<String, double?> targets,
  List<LocalActivity> weekActivities,
) {
  final seconds = <String, int>{};
  for (final a in weekActivities) {
    final sport = canonicalSport(a.type);
    if (sport == null) continue;
    seconds[sport] = (seconds[sport] ?? 0) + (a.movingTime ?? 0);
  }
  return [
    for (final sport in const ['swim', 'cycle', 'run'])
      if (targets[sport] case final t? when t > 0)
        WidgetRing(
          sport: sport,
          targetHours: t,
          doneHours: (seconds[sport] ?? 0) / 3600,
        ),
  ];
}

/// Builds the widget content from today's planned items, today's completed
/// activities and the latest wellness row that has CTL/ATL.
HomeWidgetData buildHomeWidgetData({
  required List<LocalEvent> planned,
  required List<LocalActivity> done,
  required LocalWellness? latest,
  required DateTime now,
  List<WidgetRing> rings = const [],
}) {
  final today = [
    for (final e in planned)
      if (e.category == 'WORKOUT') e,
  ];
  return HomeWidgetData(
    sessions: [for (final e in today.take(2)) HomeWidgetData.line(e)],
    extra: today.length > 2 ? today.length - 2 : 0,
    doneLoad: done.fold(0, (s, a) => s + (a.trainingLoad ?? 0)),
    ctl: latest?.ctl,
    atl: latest?.atl,
    updated: now,
    rings: rings,
  );
}

/// Pushes the current data to the Android widget. A no-op elsewhere, and
/// never throws: the widget is a convenience.
class HomeWidgetUpdater {
  HomeWidgetUpdater({
    PlannedItemsRepository? planned,
    ActivitiesRepository? activities,
    WellnessRepository? wellness,
    WeeklyTargetsSettings? targets,
    HomeWidgetSettings? settings,
    DateTime Function()? clock,
  }) : _settings = settings ?? HomeWidgetSettings.instance,
       _targets = targets ?? WeeklyTargetsSettings.instance,
       _planned = planned ?? PlannedItemsRepository(hidePendingDeletes: false),
       _activities = activities ?? ActivitiesRepository(),
       _wellness = wellness ?? WellnessRepository(),
       _clock = clock ?? clockNow;

  static const androidName = 'TriiqWidgetProvider';

  final PlannedItemsRepository _planned;
  final ActivitiesRepository _activities;
  final WellnessRepository _wellness;
  final WeeklyTargetsSettings _targets;
  final HomeWidgetSettings _settings;
  final DateTime Function() _clock;

  static bool get supported => !kIsWeb && Platform.isAndroid;

  /// The app's language, also from a background isolate; `null` if it
  /// can't be read (then the widget shows the number only).
  static Future<AppLocalizations?> _l10n() async {
    try {
      final controller = LocaleController.instance;
      await controller.load();
      final locale = controller.locale ?? PlatformDispatcher.instance.locale;
      return lookupAppLocalizations(
        AppLocalizations.supportedLocales.firstWhere(
          (l) => l.languageCode == locale.languageCode,
          orElse: () => const Locale('en'),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<HomeWidgetData> load() async {
    final now = _clock();
    final day = isoDate(now);
    final planned = await _planned.getByDate(day);
    final done = await _activities.getByDate(day);
    final week = await _wellness.getRange(
      isoDate(now.subtract(const Duration(days: 14))),
      day,
    );
    LocalWellness? latest;
    for (final w in week) {
      if (w.ctl != null &&
          w.atl != null &&
          (latest == null || w.date.compareTo(latest.date) > 0)) {
        latest = w;
      }
    }
    if (!_targets.isLoaded) await _targets.load();
    final weekActivities = await _activities.getRange(
      isoDate(startOfWeek(now)),
      day,
    );
    return buildHomeWidgetData(
      planned: planned,
      done: done,
      latest: latest,
      now: now,
      rings: buildWidgetRings({
        'swim': _targets.swimHours,
        'cycle': _targets.cycleHours,
        'run': _targets.runHours,
      }, weekActivities),
    );
  }

  Future<void> update() async {
    if (!supported) return;
    try {
      final data = await load();
      if (!_settings.isLoaded) await _settings.load();
      final l10n = await _l10n();
      for (final e
          in data
              .toEntries(
                show: _settings,
                zoneName: l10n == null ? null : (z) => formZoneName(l10n, z),
              )
              .entries) {
        await HomeWidget.saveWidgetData<String>(e.key, e.value);
      }
      await HomeWidget.updateWidget(androidName: androidName);
    } catch (e) {
      debugPrint('HomeWidgetUpdater: $e');
    }
  }
}

/// The Form zone's name as Today shows it.
String formZoneName(AppLocalizations l10n, FormZone zone) => switch (zone) {
  FormZone.transition => l10n.formStateTransition,
  FormZone.fresh => l10n.formStateFresh,
  FormZone.grey => l10n.formStateGrey,
  FormZone.optimal => l10n.formStateOptimal,
  FormZone.highRisk => l10n.formStateHighRisk,
};
