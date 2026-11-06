import 'package:flutter/material.dart';

import '../../data/models/local_activity.dart';
import '../../data/repositories/activities_repository.dart';
import '../../evaluation/activity_route.dart';
import '../../evaluation/compare.dart';
import '../../evaluation/session_evaluator.dart' show sportFamily;
import '../../evaluation/session_streams.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/chart_options.dart';
import '../../widgets/charts/line_chart.dart';
import '../../widgets/section_card.dart';
import '../activities/route_card.dart' show hasRouteMap;
import '../activities/session_analysis.dart' show streamLabel;
import 'activity_picker.dart';
import 'compare_format.dart';
import 'compare_route_map.dart';
import 'compare_table.dart';

/// Two runs or two rides overlaid: one chart per stream on a shared distance
/// or time axis, both courses on one map, and the headline figures side by
/// side. The chart and the map share one tracker — touching either moves a
/// marker on both, for both activities.
class CompareActivitiesTab extends StatefulWidget {
  CompareActivitiesTab({
    super.key,
    this.initialA,
    ActivitiesRepository? activities,
    ActivityStreamsRepository? streams,
    ActivityRouteRepository? routes,
    this.showTiles = true,
  }) : activities = activities ?? ActivitiesRepository(),
       streams = streams ?? ActivityStreamsRepository(),
       routes = routes ?? ActivityRouteRepository();

  final LocalActivity? initialA;
  final ActivitiesRepository activities;
  final ActivityStreamsRepository streams;
  final ActivityRouteRepository routes;
  final bool showTiles;

  @override
  State<CompareActivitiesTab> createState() => _CompareActivitiesTabState();
}

class _Loaded {
  const _Loaded({required this.streams, required this.route});
  final SessionStreams? streams;
  final ActivityRoute? route;
}

class _CompareActivitiesTabState extends State<CompareActivitiesTab> {
  static const _points = 240;

  LocalActivity? _a;
  LocalActivity? _b;
  _Loaded? _loadedA;
  _Loaded? _loadedB;
  bool _loading = false;

  CompareAxis _axis = CompareAxis.distance;
  String _metric = 'heartrate';

  /// The tracker: distance in metres or elapsed seconds, per [_axis].
  final _cursor = ValueNotifier<double?>(null);

  @override
  void initState() {
    super.initState();
    _a = widget.initialA;
    if (_a != null) _loadFor(_a!, first: true);
  }

  @override
  void dispose() {
    _cursor.dispose();
    super.dispose();
  }

  Future<_Loaded> _fetch(LocalActivity a) async {
    SessionStreams? streams;
    ActivityRoute? route;
    try {
      streams = await widget.streams.loadForCompare(a.id);
    } catch (_) {}
    if (hasRouteMap(a)) {
      try {
        route = await widget.routes.load(a.id);
      } catch (_) {}
    }
    return _Loaded(streams: streams, route: route);
  }

  Future<void> _loadFor(LocalActivity a, {required bool first}) async {
    setState(() => _loading = true);
    final loaded = await _fetch(a);
    if (!mounted) return;
    setState(() {
      if (first) {
        _loadedA = loaded;
      } else {
        _loadedB = loaded;
      }
      _loading = false;
      _cursor.value = null;
      _ensureValidChoices();
    });
  }

  Future<void> _pick({required bool first}) async {
    final other = first ? _b : _a;
    final picked = await pickActivity(
      context,
      repository: widget.activities,
      family: other == null ? null : sportFamily(other.type),
      excludeId: other?.id,
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (first) {
        _a = picked;
        _loadedA = null;
        // A new first pick of another sport invalidates the second.
        if (_b != null && sportFamily(_b!.type) != sportFamily(picked.type)) {
          _b = null;
          _loadedB = null;
        }
      } else {
        _b = picked;
        _loadedB = null;
      }
    });
    await _loadFor(picked, first: first);
  }

  bool get _canDistance =>
      _loadedA?.streams != null &&
      _loadedB?.streams != null &&
      axisLength(_loadedA!.streams!, CompareAxis.distance) != null &&
      axisLength(_loadedB!.streams!, CompareAxis.distance) != null;

  List<String> get _metrics => [
    for (final m in compareMetrics)
      if ((_loadedA?.streams?.series[m]?.any((v) => v != null) ?? false) ||
          (_loadedB?.streams?.series[m]?.any((v) => v != null) ?? false))
        m,
  ];

  void _ensureValidChoices() {
    if (!_canDistance && _loadedA != null && _loadedB != null) {
      _axis = CompareAxis.time;
    }
    final metrics = _metrics;
    if (metrics.isNotEmpty && !metrics.contains(_metric)) {
      _metric = metrics.first;
    }
  }

  double? get _xMax {
    final sa = _loadedA?.streams, sb = _loadedB?.streams;
    if (sa == null || sb == null) return null;
    final la = axisLength(sa, _axis), lb = axisLength(sb, _axis);
    if (la == null || lb == null) return null;
    return la > lb ? la : lb;
  }

  void _setAxis(CompareAxis axis) {
    // Keep the tracker on the same moment of activity A when switching.
    final x = _cursor.value;
    double? moved;
    final sa = _loadedA?.streams;
    if (x != null && sa != null) {
      final t = timeAtX(sa, _axis, x);
      moved = t == null ? null : xAtTime(sa, axis, t);
    }
    _axis = axis;
    _cursor.value = moved;
  }

  RoutePoint? _markerFor(_Loaded? l, double x) {
    final route = l?.route, streams = l?.streams;
    if (route == null || streams == null || route.isEmpty) return null;
    return routePointAtX(route, streams, _axis, x);
  }

  void _onMapTap(double lat, double lng) {
    // Whichever course passes closest to the tap drives the tracker.
    final tap = RoutePoint(lat, lng);
    _Loaded? nearest;
    var bestD = double.infinity;
    for (final l in [_loadedA, _loadedB]) {
      final route = l?.route;
      if (route == null || l?.streams == null || !route.hasTimes) continue;
      for (final p in route.points) {
        final d = routeMetres(tap, p);
        if (d < bestD) {
          bestD = d;
          nearest = l;
        }
      }
    }
    if (nearest == null) return;
    final x = xAtNearestPoint(
      nearest.route!,
      nearest.streams!,
      _axis,
      lat,
      lng,
    );
    if (x != null) _cursor.value = x;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ready =
        _a != null && _b != null && _loadedA != null && _loadedB != null;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _pickerTile(l10n, first: true),
        const SizedBox(height: 8),
        _pickerTile(l10n, first: false),
        const SizedBox(height: 16),
        if (_loading) const LinearProgressIndicator(),
        if (_a == null || _b == null)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.cmpChooseTwo,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else if (ready) ...[
          _chartCard(context, l10n),
          const SizedBox(height: 16),
          _mapCard(context, l10n),
          _statsCard(context, l10n),
        ],
      ],
    );
  }

  Widget _pickerTile(AppLocalizations l10n, {required bool first}) {
    final a = first ? _a : _b;
    final color = first ? compareColorA : compareColorB;
    return Card(
      child: ListTile(
        key: ValueKey(first ? 'pick-first' : 'pick-second'),
        leading: CircleAvatar(
          radius: 14,
          backgroundColor: color,
          child: Text(
            first ? l10n.cmpFirst : l10n.cmpSecond,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        title: Text(
          a == null
              ? (first ? l10n.cmpPickFirst : l10n.cmpPickSecond)
              : (a.name ?? a.type ?? ''),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: a == null
            ? null
            : Text(
                [
                  a.date,
                  if (a.distance != null && a.distance! > 0)
                    '${(a.distance! / 1000).toStringAsFixed(1)} km',
                  if (a.movingTime != null) durationLabel(a.movingTime!),
                ].join(' · '),
              ),
        trailing: const Icon(Icons.expand_more),
        onTap: () => _pick(first: first),
      ),
    );
  }

  Widget _chartCard(BuildContext context, AppLocalizations l10n) {
    final sa = _loadedA!.streams, sb = _loadedB!.streams;
    final metrics = _metrics;
    if (sa == null || sb == null || metrics.isEmpty || _xMax == null) {
      return SectionCard(
        icon: Icons.show_chart,
        title: l10n.sessionDiagramTitle,
        child: Text(l10n.cmpNoStreams),
      );
    }
    final grid = axisGrid(_xMax!, count: _points);
    final a = resampleMetric(sa, _metric, _axis, grid);
    final b = resampleMetric(sb, _metric, _axis, grid);
    final distance = _axis == CompareAxis.distance;
    final labels = [
      for (final x in grid) shortAxisLabel(x, distance: distance),
    ];
    final type = _a!.type;

    int? selectedIndex(double? x) {
      if (x == null || grid.last <= 0) return null;
      return (x / grid.last * (_points - 1)).round().clamp(0, _points - 1);
    }

    return SectionCard(
      icon: Icons.show_chart,
      title: l10n.sessionDiagramTitle,
      onLongPress: () => _openChartOptions(context, l10n, metrics),
      trailing: ChartOptionsButton(
        summary:
            '${streamLabel(l10n, _metric)} · '
            '${_axis == CompareAxis.distance ? l10n.cmpAxisDistance : l10n.cmpAxisTime}',
        onPressed: () => _openChartOptions(context, l10n, metrics),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          if (a.every((v) => v == null) && b.every((v) => v == null))
            Text(l10n.cmpNoMetric)
          else
            ValueListenableBuilder<double?>(
              valueListenable: _cursor,
              builder: (context, x, _) {
                final i = selectedIndex(x);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i == null
                          ? l10n.cmpTrackerHint
                          : '${axisLabel(grid[i], distance: distance)}   '
                                '${l10n.cmpFirst} ${a[i] == null ? '–' : metricValue(_metric, a[i]!, type)}'
                                ' · ${l10n.cmpSecond} ${b[i] == null ? '–' : metricValue(_metric, b[i]!, type)}',
                      key: const ValueKey('cmp-readout'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: MetricLineChart(
                        key: ValueKey(
                          'cmp-chart-$_metric-$_axis-${_a!.id}-${_b!.id}',
                        ),
                        series: [
                          ChartSeries(
                            label: l10n.cmpFirst,
                            color: compareColorA,
                            values: a,
                            strokeWidth: 2.4,
                            average: false,
                          ),
                          ChartSeries(
                            label: l10n.cmpSecond,
                            color: compareColorB,
                            values: b,
                            strokeWidth: 2.4,
                            average: false,
                          ),
                        ],
                        labels: labels,
                        labelEvery: (_points / 5).ceil(),
                        showAverage: false,
                        smooth: false,
                        selectedIndex: i,
                        onSelect: (index) => _cursor.value = grid[index],
                        formatValue: (v) => metricValue(_metric, v, type),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  /// Stream and axis choices, out of the way until asked for.
  void _openChartOptions(
    BuildContext context,
    AppLocalizations l10n,
    List<String> metrics,
  ) {
    showChartOptions(
      context,
      title: l10n.sessionDiagramTitle,
      ownerSetState: setState,
      builder: (sheet, apply) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OptionGroup(
            label: l10n.chartOptionsStreams,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final m in metrics)
                  ChoiceChip(
                    key: ValueKey('cmp-metric-$m'),
                    label: Text(streamLabel(l10n, m)),
                    selected: _metric == m,
                    onSelected: (_) => apply(() => _metric = m),
                  ),
              ],
            ),
          ),
          OptionGroup(
            label: l10n.chartOptionsAxis,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<CompareAxis>(
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                  segments: [
                    ButtonSegment(
                      value: CompareAxis.distance,
                      label: Text(l10n.cmpAxisDistance),
                      enabled: _canDistance,
                    ),
                    ButtonSegment(
                      value: CompareAxis.time,
                      label: Text(l10n.cmpAxisTime),
                    ),
                  ],
                  selected: {_axis},
                  onSelectionChanged: (s) => apply(() => _setAxis(s.first)),
                ),
                if (!_canDistance) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.cmpNoDistance,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapCard(BuildContext context, AppLocalizations l10n) {
    final ra = _loadedA!.route, rb = _loadedB!.route;
    final hasA = ra != null && !ra.isEmpty;
    final hasB = rb != null && !rb.isEmpty;
    if (!hasA && !hasB) return const SizedBox.shrink();
    CompareRouteMap build({required bool interactive, bool full = false}) =>
        CompareRouteMap(
          routeA: ra,
          routeB: rb,
          cursor: _cursor,
          markerA: (x) => _markerFor(_loadedA, x),
          markerB: (x) => _markerFor(_loadedB, x),
          onTap: _onMapTap,
          interactive: interactive,
          showTiles: widget.showTiles,
          padding: full ? 48 : 28,
        );
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SectionCard(
        key: const ValueKey('compare-map-card'),
        icon: Icons.map_outlined,
        title: l10n.cmpCourseTitle,
        trailing: IconButton(
          key: const ValueKey('compare-map-open'),
          tooltip: l10n.cmpCourseOpen,
          icon: const Icon(Icons.open_in_full, size: 20),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CompareRouteScreen(
                title: l10n.cmpCourseTitle,
                map: build(interactive: true, full: true),
              ),
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(height: 260, child: build(interactive: false)),
        ),
      ),
    );
  }

  Widget _statsCard(BuildContext context, AppLocalizations l10n) {
    final rows = compareRows(
      l10n,
      blockStats([_a!]),
      blockStats([_b!]),
      _a!.type,
    );
    return SectionCard(
      icon: Icons.table_rows_outlined,
      title: l10n.cmpStatsTitle,
      child: CompareTable(
        rows: rows,
        colorA: compareColorA,
        colorB: compareColorB,
        headerA: l10n.cmpFirst,
        headerB: l10n.cmpSecond,
      ),
    );
  }
}
