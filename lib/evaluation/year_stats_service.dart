import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/repositories/activities_repository.dart';
import '../data/repositories/sync_state_repository.dart';
import '../data/sync/auto_sync_service.dart';
import '../util/dates.dart';
import 'period_stats.dart';
import '../util/clock.dart';

/// A year's per-sport statistics plus the rows to rank a session against.
class YearSnapshot {
  const YearSnapshot({required this.stats, required this.rows});

  final YearStats stats;

  /// The year's rows (this year only), for ranking a session.
  final List<StatRow> rows;
}

/// The single source of "this year per sport": reads the cached activities
/// and the sync coverage once per year and keeps the result in memory, so
/// opening several sessions in a row does not recompute it. Forgotten when
/// the cache changes ([AutoSyncService.notifyCacheChanged] or a sync) and
/// when the day changes. Listeners hear when that happens.
class YearStatsService extends ChangeNotifier {
  YearStatsService({
    ActivitiesRepository? activities,
    SyncStateRepository? syncState,
    Listenable? invalidation,
    DateTime Function()? clock,
  }) : _activities = activities,
       _syncState = syncState,
       _clock = clock ?? clockNow,
       _invalidation = invalidation {
    _invalidation?.addListener(invalidate);
  }

  /// The app-wide instance, invalidated by the auto-sync service.
  static final YearStatsService instance = YearStatsService(
    invalidation: AutoSyncService.instance,
  );

  ActivitiesRepository? _activities;
  SyncStateRepository? _syncState;
  final DateTime Function() _clock;
  final Listenable? _invalidation;

  ActivitiesRepository get _repo => _activities ??= ActivitiesRepository();
  SyncStateRepository get _state => _syncState ??= SyncStateRepository();

  final _cache = <String, Future<YearSnapshot>>{};

  /// How often the cache was really read (not served from memory) — for tests.
  @visibleForTesting
  int computeCount = 0;

  /// Forgets everything; the next [load] reads the cache again.
  void invalidate() {
    _cache.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _invalidation?.removeListener(invalidate);
    super.dispose();
  }

  /// The statistics of [year] as of today. [fresh] skips the memory copy
  /// (and refreshes it) — the peek asks for that, a session screen does not.
  Future<YearSnapshot> load(int year, {bool fresh = false}) {
    final today = dateOnly(_clock());
    final key = '$year@${isoDate(today)}';
    if (!fresh) {
      final hit = _cache[key];
      if (hit != null) return hit;
    }
    final future = _compute(year, today);
    _cache[key] = future;
    // A failed read is not worth remembering.
    unawaited(
      future.then<void>(
        (_) {},
        onError: (Object _) {
          if (identical(_cache[key], future)) _cache.remove(key);
        },
      ),
    );
    return future;
  }

  Future<YearSnapshot> _compute(int year, DateTime today) async {
    computeCount++;
    final from = '${(year - 1).toString().padLeft(4, '0')}-01-01';
    final to = '${year.toString().padLeft(4, '0')}-12-31';
    final records = await _repo.getRange(from, to);
    SyncCoverage? coverage;
    try {
      final state = await _state.get('activities');
      if (state != null) {
        coverage = SyncCoverage(oldest: state.oldest, newest: state.newest);
      }
    } catch (error) {
      debugPrint('YearStatsService: cannot read sync state: $error');
    }
    final rows = statRows(records);
    final stats = computeYearStats(
      rows,
      year: year,
      today: today,
      coverage: coverage,
    );
    return YearSnapshot(
      stats: stats,
      rows: [
        for (final r in rows)
          if (r.date.startsWith('$year')) r,
      ],
    );
  }
}
