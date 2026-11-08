import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../widgets/skeleton.dart';

import '../../data/intervals_session.dart';
import '../../data/models/local_activity.dart';
import '../../data/repositories/activities_repository.dart';
import '../../l10n/app_localizations.dart';
import 'activity_detail_screen.dart';
import 'activity_filter.dart';
import 'activity_icons.dart';

/// Every cached activity, most recent first, with search by name, filters
/// (sport, dates, distance, duration, power, GPS) and sorting. Reachable from
/// Insights → Activities, and from a sport row on Insights — which arrives with
/// [initialType] set, so the list opens showing that sport alone. Reads
/// only from the local SQLite cache — use Sync to pull more history in
/// first.
class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key, this.initialType});

  /// Intervals.icu activity type to show on arrival (`Ride`, `Run`, …), or
  /// null for the unfiltered list. The filter is a starting point, not a
  /// fixed one: it shows as a chip the user can clear.
  final String? initialType;

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  final _repository = ActivitiesRepository();
  final _session = IntervalsSession.instance;
  final _search = TextEditingController();
  Timer? _debounce;

  bool _loading = true;
  String? _error;
  List<LocalActivity> _activities = const [];
  bool _searching = false;

  /// Search, filters and sort; the sport filter may arrive preset.
  ActivityFilter _filter = const ActivityFilter();

  /// What the list actually renders.
  List<LocalActivity> get _visible => _filter.apply(_activities);

  @override
  void initState() {
    super.initState();
    _filter = ActivityFilter(type: widget.initialType);
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final activities = await _repository.getAll();
      if (!mounted) return;
      setState(() {
        _activities = activities;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// Typing narrows the list once the athlete pauses for a moment.
  void _onQuery(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _filter = _filter.copyWith(query: text));
    });
  }

  void _clearQuery() {
    _debounce?.cancel();
    _search.clear();
    setState(() {
      _filter = _filter.copyWith(query: '');
      _searching = false;
    });
  }

  void _clearAll() {
    _debounce?.cancel();
    _search.clear();
    setState(() {
      _filter = const ActivityFilter();
      _searching = false;
    });
  }

  Future<void> _openFilters() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _FilterSheet(
        activities: _activities,
        filter: _filter,
        onChanged: (f) => setState(() => _filter = f),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activities = _visible;
    final chips = _chips(context, l10n);

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                key: const ValueKey('activity-search'),
                controller: _search,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.actSearchHint,
                  border: InputBorder.none,
                ),
                onChanged: _onQuery,
              )
            : Text(l10n.titleActivities),
        actions: [
          IconButton(
            key: const ValueKey('activity-search-toggle'),
            tooltip: l10n.actSearch,
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: _searching
                ? _clearQuery
                : () => setState(() => _searching = true),
          ),
          IconButton(
            key: const ValueKey('activity-filter'),
            tooltip: l10n.actFilterTitle,
            icon: Badge(
              isLabelVisible: _filter.isActive && _filter.query.isEmpty,
              smallSize: 8,
              child: const Icon(Icons.tune),
            ),
            onPressed: _openFilters,
          ),
        ],
        bottom: chips.isEmpty
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(52),
                child: SizedBox(
                  height: 52,
                  child: ListView(
                    key: const ValueKey('activity-filter-chips'),
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    children: [
                      Center(
                        child: Text(
                          l10n.actResultCount(activities.length),
                          key: const ValueKey('activity-count'),
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                      for (final chip in chips) ...[
                        const SizedBox(width: 8),
                        chip,
                      ],
                      const SizedBox(width: 8),
                      TextButton(
                        key: const ValueKey('activity-clear-filters'),
                        onPressed: _clearAll,
                        child: Text(l10n.actClearFilters),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const SkeletonList()
            : _error != null
            ? _EmptyState(connected: _session.isConnected, error: _error)
            : activities.isEmpty
            ? _EmptyState(
                connected: _session.isConnected,
                type: _filter.type,
                filtered: _filter.isActive && _activities.isNotEmpty,
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: activities.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) =>
                    _ActivityRow(activity: activities[index]),
              ),
      ),
    );
  }

  /// One removable chip per active filter (and a non-default sort).
  List<Widget> _chips(BuildContext context, AppLocalizations l10n) {
    final f = _filter;
    final locale = Localizations.localeOf(context).toString();
    Widget chip(
      String key,
      String label,
      VoidCallback onDeleted, {
      IconData? icon,
    }) => InputChip(
      key: ValueKey('chip-$key'),
      avatar: icon == null ? null : Icon(icon, size: 18),
      label: Text(label),
      onDeleted: onDeleted,
      deleteIcon: const Icon(Icons.close, size: 18),
      tooltip: key == 'type' ? l10n.showAllActivities : null,
    );
    final range = f.dateRange(DateTime.now());
    return [
      if (f.query.trim().isNotEmpty)
        chip('query', '“${f.query.trim()}”', _clearQuery, icon: Icons.search),
      if (f.type case final type?)
        chip(
          'type',
          type,
          () => setState(() => _filter = f.copyWith(type: null)),
          icon: activityTypeIcon(type),
        ),
      if (f.datePreset != null && range != null)
        chip(
          'date',
          switch (f.datePreset!) {
            DatePreset.thisWeek => l10n.actThisWeek,
            DatePreset.thisMonth => l10n.actThisMonth,
            DatePreset.last3Months => l10n.actLast3Months,
            DatePreset.custom =>
              '${DateFormat.MMMd(locale).format(range.start)} – '
                  '${DateFormat.MMMd(locale).format(range.end)}',
          },
          () => setState(
            () => _filter = f.copyWith(datePreset: null, customRange: null),
          ),
          icon: Icons.date_range,
        ),
      if (f.hasDistance)
        chip(
          'distance',
          '${_bound(f.minKm)}–${_bound(f.maxKm)} km',
          () => setState(() => _filter = f.copyWith(minKm: null, maxKm: null)),
          icon: Icons.straighten,
        ),
      if (f.hasDuration)
        chip(
          'duration',
          '${_bound(f.minMinutes)}–${_bound(f.maxMinutes)} min',
          () => setState(
            () => _filter = f.copyWith(minMinutes: null, maxMinutes: null),
          ),
          icon: Icons.timer_outlined,
        ),
      if (f.hasPower)
        chip(
          'power',
          l10n.actHasPower,
          () => setState(() => _filter = f.copyWith(hasPower: false)),
          icon: Icons.bolt,
        ),
      if (f.hasGps)
        chip(
          'gps',
          l10n.actHasGps,
          () => setState(() => _filter = f.copyWith(hasGps: false)),
          icon: Icons.place_outlined,
        ),
      if (f.sort != ActivitySort.date)
        chip(
          'sort',
          _sortLabel(l10n, f.sort),
          () => setState(() => _filter = f.copyWith(sort: ActivitySort.date)),
          icon: Icons.sort,
        ),
    ];
  }

  static String _bound(num? v) => v == null ? '' : '${v.round()}';
}

String _sortLabel(AppLocalizations l10n, ActivitySort sort) => switch (sort) {
  ActivitySort.date => l10n.actSortDate,
  ActivitySort.distance => l10n.actSortDistance,
  ActivitySort.duration => l10n.actSortDuration,
  ActivitySort.load => l10n.actSortLoad,
};

/// Filters and sort, applied live as they change.
class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.activities,
    required this.filter,
    required this.onChanged,
  });

  final List<LocalActivity> activities;
  final ActivityFilter filter;
  final ValueChanged<ActivityFilter> onChanged;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late ActivityFilter _f = widget.filter;

  void _set(ActivityFilter f) {
    setState(() => _f = f);
    widget.onChanged(f);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final types = {
      for (final a in widget.activities)
        if (a.type != null) a.type!,
    }.toList()..sort();
    final maxKm = _ceilTo(
      widget.activities.fold<double>(
        0,
        (m, a) => math.max(m, (a.distance ?? 0) / 1000),
      ),
      10,
    );
    final maxMin = _ceilTo(
      widget.activities.fold<double>(
        0,
        (m, a) => math.max(m, (a.movingTime ?? 0) / 60),
      ),
      30,
    );

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(text, style: theme.textTheme.titleSmall),
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.actFilterTitle, style: theme.textTheme.titleLarge),
            heading(l10n.actSortBy),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in ActivitySort.values)
                  ChoiceChip(
                    key: ValueKey('sort-${s.name}'),
                    label: Text(_sortLabel(l10n, s)),
                    selected: _f.sort == s,
                    onSelected: (_) => _set(_f.copyWith(sort: s)),
                  ),
              ],
            ),
            if (types.length > 1) ...[
              heading(l10n.actFilterSport),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(l10n.actAllSports),
                    selected: _f.type == null,
                    onSelected: (_) => _set(_f.copyWith(type: null)),
                  ),
                  for (final t in types)
                    ChoiceChip(
                      key: ValueKey('type-$t'),
                      avatar: Icon(activityTypeIcon(t), size: 18),
                      label: Text(t),
                      selected: _f.type == t,
                      onSelected: (_) => _set(_f.copyWith(type: t)),
                    ),
                ],
              ),
            ],
            heading(l10n.actFilterDate),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l10n.actAny),
                  selected: _f.datePreset == null,
                  onSelected: (_) =>
                      _set(_f.copyWith(datePreset: null, customRange: null)),
                ),
                for (final (preset, label) in [
                  (DatePreset.thisWeek, l10n.actThisWeek),
                  (DatePreset.thisMonth, l10n.actThisMonth),
                  (DatePreset.last3Months, l10n.actLast3Months),
                ])
                  ChoiceChip(
                    key: ValueKey('date-${preset.name}'),
                    label: Text(label),
                    selected: _f.datePreset == preset,
                    onSelected: (_) => _set(_f.copyWith(datePreset: preset)),
                  ),
                ChoiceChip(
                  key: const ValueKey('date-custom'),
                  label: Text(l10n.actCustomRange),
                  selected: _f.datePreset == DatePreset.custom,
                  onSelected: (_) async {
                    final now = DateTime.now();
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(now.year - 10),
                      lastDate: now,
                      initialDateRange: _f.customRange,
                    );
                    if (picked != null) {
                      _set(
                        _f.copyWith(
                          datePreset: DatePreset.custom,
                          customRange: picked,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            if (maxKm > 0) ...[
              heading(l10n.actFilterDistance),
              _Range(
                key: const ValueKey('distance-range'),
                max: maxKm,
                low: _f.minKm,
                high: _f.maxKm,
                onChanged: (lo, hi) => _set(_f.copyWith(minKm: lo, maxKm: hi)),
              ),
            ],
            if (maxMin > 0) ...[
              heading(l10n.actFilterDuration),
              _Range(
                key: const ValueKey('duration-range'),
                max: maxMin,
                low: _f.minMinutes?.toDouble(),
                high: _f.maxMinutes?.toDouble(),
                onChanged: (lo, hi) => _set(
                  _f.copyWith(minMinutes: lo?.round(), maxMinutes: hi?.round()),
                ),
              ),
            ],
            const SizedBox(height: 8),
            SwitchListTile(
              key: const ValueKey('filter-power'),
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.actHasPower),
              value: _f.hasPower,
              onChanged: (v) => _set(_f.copyWith(hasPower: v)),
            ),
            SwitchListTile(
              key: const ValueKey('filter-gps'),
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.actHasGps),
              value: _f.hasGps,
              onChanged: (v) => _set(_f.copyWith(hasGps: v)),
            ),
          ],
        ),
      ),
    );
  }

  static double _ceilTo(double v, double step) =>
      v <= 0 ? 0 : (v / step).ceil() * step;
}

/// A range slider from 0 to [max]; the full span reads as "no limit".
class _Range extends StatelessWidget {
  const _Range({
    super.key,
    required this.max,
    required this.low,
    required this.high,
    required this.onChanged,
  });

  final double max;
  final double? low, high;
  final void Function(double? low, double? high) onChanged;

  @override
  Widget build(BuildContext context) {
    final values = RangeValues(
      (low ?? 0).clamp(0, max),
      (high ?? max).clamp(0, max),
    );
    return RangeSlider(
      values: values,
      max: max,
      divisions: math.max(1, max ~/ (max > 100 ? 10 : 1)),
      labels: RangeLabels('${values.start.round()}', '${values.end.round()}'),
      onChanged: (v) =>
          onChanged(v.start <= 0 ? null : v.start, v.end >= max ? null : v.end),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity});

  final LocalActivity activity;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final details = <String>[
      formatIsoDate(activity.date),
      if (activity.distance != null && activity.distance! > 0)
        formatDistanceMeters(activity.distance!),
      if (activity.movingTime != null && activity.movingTime! > 0)
        formatDurationSecs(activity.movingTime!),
    ];

    return Card(
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ActivityDetailScreen(activity: activity),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            activityTypeIcon(activity.type),
            color: colorScheme.primary,
          ),
        ),
        title: Text(
          activity.name ?? activity.type ?? l10n.activityFallback,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(details.join(' · ')),
        trailing: activity.trainingLoad == null
            ? const Icon(Icons.chevron_right)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${activity.trainingLoad}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.primary,
                    ),
                  ),
                  Text(
                    l10n.tssSuffix,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.connected,
    this.error,
    this.type,
    this.filtered = false,
  });

  /// Activities are cached, the filters just leave none.
  final bool filtered;

  final bool connected;
  final String? error;

  /// Set when the list is empty only because a sport filter is on — "no
  /// rides cached" is a different problem from "nothing cached at all".
  final String? type;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    error != null
                        ? Icons.error_outline
                        : Icons.event_busy_outlined,
                    size: 40,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    error ??
                        (filtered
                            ? l10n.actNoMatch
                            : type != null
                            ? l10n.noActivitiesOfType(type!)
                            : connected
                            ? l10n.noActivitiesCachedConnected
                            : l10n.noActivitiesCachedDisconnected),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
