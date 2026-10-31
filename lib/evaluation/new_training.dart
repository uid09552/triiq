import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/local_activity.dart';
import '../data/repositories/activities_repository.dart';
import '../util/dates.dart';

/// Which of today's sessions the athlete has already seen in the
/// new-training sheet (or opened). Only today is kept: a stored day other
/// than today counts as nothing seen, so ids never pile up and an older
/// session can't pop up at all.
class SeenSessionsStore {
  SeenSessionsStore({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  static const _key = 'insights.seen';

  String get _today => isoDate(_clock());

  Future<Set<String>> seenToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return {};
      final json = jsonDecode(raw) as Map<String, dynamic>;
      if (json['date'] != _today) return {};
      return {for (final id in json['ids'] as List) id as String};
    } catch (error) {
      debugPrint('SeenSessionsStore: cannot read: $error');
      return {};
    }
  }

  Future<void> markSeen(Iterable<String> ids) async {
    final seen = await seenToday()
      ..addAll(ids);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode({'date': _today, 'ids': seen.toList()..sort()}),
    );
  }
}

/// Today's completed sessions not yet seen, newest first.
class NewTrainingInsights {
  NewTrainingInsights({
    ActivitiesRepository? activities,
    SeenSessionsStore? seen,
    DateTime Function()? clock,
  }) : _activities = activities ?? ActivitiesRepository(),
       _clock = clock ?? DateTime.now,
       seen = seen ?? SeenSessionsStore(clock: clock);

  final ActivitiesRepository _activities;
  final DateTime Function() _clock;
  final SeenSessionsStore seen;

  Future<List<LocalActivity>> unseenToday() async {
    final today = isoDate(_clock());
    final done = await _activities.getByDate(today);
    final seenIds = await seen.seenToday();
    final fresh = [
      for (final a in done)
        if (!seenIds.contains(a.id)) a,
    ];
    String start(LocalActivity a) =>
        a.raw['start_date_local'] as String? ?? a.date;
    fresh.sort((a, b) => start(b).compareTo(start(a)));
    return fresh;
  }
}
