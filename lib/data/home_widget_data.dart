import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import 'models/local_activity.dart';
import 'models/local_event.dart';
import 'models/local_wellness.dart';
import 'planned_items.dart';
import 'repositories/activities_repository.dart';
import 'repositories/wellness_repository.dart';
import '../util/dates.dart';

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
  });

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

  static String _minutes(int? seconds) =>
      seconds == null || seconds <= 0 ? '' : ' · ${(seconds / 60).round()} min';

  static String line(LocalEvent e) {
    final load = e.plannedLoad;
    return '${e.name ?? e.type ?? ''}${_minutes(e.plannedTime)}'
        '${load == null ? '' : ' · $load TSS'}';
  }

  /// The widget's storage entries.
  Map<String, String> toEntries() => {
    'w_session1': sessions.isNotEmpty ? sessions[0] : '',
    'w_session2': sessions.length > 1 ? sessions[1] : '',
    'w_extra': extra > 0 ? '+$extra' : '',
    'w_done': doneLoad > 0 ? '$doneLoad TSS' : '',
    'w_form': form == null
        ? ''
        : '${form! >= 0 ? '+' : ''}${form!.round()}',
    'w_fitness': ctl == null || atl == null
        ? ''
        : 'CTL ${ctl!.round()} · ATL ${atl!.round()}',
    'w_updated':
        '${updated.hour.toString().padLeft(2, '0')}:'
        '${updated.minute.toString().padLeft(2, '0')}',
  };
}

/// Builds the widget content from today's planned items, today's completed
/// activities and the latest wellness row that has CTL/ATL.
HomeWidgetData buildHomeWidgetData({
  required List<LocalEvent> planned,
  required List<LocalActivity> done,
  required LocalWellness? latest,
  required DateTime now,
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
  );
}

/// Pushes the current data to the Android widget. A no-op elsewhere, and
/// never throws: the widget is a convenience.
class HomeWidgetUpdater {
  HomeWidgetUpdater({
    PlannedItemsRepository? planned,
    ActivitiesRepository? activities,
    WellnessRepository? wellness,
    DateTime Function()? clock,
  }) : _planned = planned ?? PlannedItemsRepository(),
       _activities = activities ?? ActivitiesRepository(),
       _wellness = wellness ?? WellnessRepository(),
       _clock = clock ?? DateTime.now;

  static const androidName = 'TriiqWidgetProvider';

  final PlannedItemsRepository _planned;
  final ActivitiesRepository _activities;
  final WellnessRepository _wellness;
  final DateTime Function() _clock;

  static bool get supported => !kIsWeb && Platform.isAndroid;

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
    return buildHomeWidgetData(
      planned: planned,
      done: done,
      latest: latest,
      now: now,
    );
  }

  Future<void> update() async {
    if (!supported) return;
    try {
      final data = await load();
      for (final e in data.toEntries().entries) {
        await HomeWidget.saveWidgetData<String>(e.key, e.value);
      }
      await HomeWidget.updateWidget(androidName: androidName);
    } catch (e) {
      debugPrint('HomeWidgetUpdater: $e');
    }
  }
}
