import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../data/repositories/activities_repository.dart';
import '../../data/repositories/wellness_repository.dart';
import '../../evaluation/training_analytics.dart';
import '../../l10n/app_localizations.dart';
import '../../util/dates.dart';
import '../../widgets/charts/line_chart.dart';
import '../../widgets/charts/stacked_bar_chart.dart';
import '../../widgets/section_card.dart';

/// Training analytics read from the local cache: fitness and load split per
/// sport, intensity distribution, load-safety ratios and the aerobic base.
/// All maths lives in `lib/evaluation/training_analytics.dart`; this screen
/// only loads the cache and draws it.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

enum _SafetyMetric { acwr, ramp, monotony }

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  static const _rangeOptions = [90, 180, 365];

  /// History before the window so CTL, ACWR and monotony are warmed up.
  static const _warmUpDays = 180;

  final _activitiesRepository = ActivitiesRepository();
  final _wellnessRepository = WellnessRepository();

  int _days = 90;
  bool _loading = true;
  bool _atl = false;
  bool _monthly = false;
  _SafetyMetric _metric = _SafetyMetric.acwr;
  LoadSport _aerobicSport = LoadSport.ride;
  int _selectedLoadBucket = -1;
  int _selectedIntensityBucket = -1;

  List<SportFitnessDay> _fitness = const [];
  List<DateTime> _weekStarts = const [];
  List<Map<LoadSport, double>> _weekLoads = const [];
  List<IntensityBucket> _intensity = const [];
  IntensityBucket _intensityTotal = IntensityBucket(
    start: DateTime(2000),
    low: 0,
    moderate: 0,
    high: 0,
    sessionsWithoutZones: 0,
  );
  List<LoadSafetyDay> _safety = const [];
  List<AerobicSession> _aerobic = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final today = dateOnly(DateTime.now());
    final from = today.subtract(Duration(days: _days - 1));
    final warmFrom = from.subtract(const Duration(days: _warmUpDays));

    final activities = await _activitiesRepository.getRange(
      isoDate(warmFrom),
      isoDate(today),
    );
    final wellness = await _wellnessRepository.getRange(
      isoDate(from.subtract(const Duration(days: 7))),
      isoDate(today),
    );
    final ctlByDate = {
      for (final w in wellness)
        if (w.ctl != null) w.date: w.ctl!,
    };
    final inRange = activities
        .where((a) => a.date.compareTo(isoDate(from)) >= 0)
        .toList();

    final weekStarts = bucketStarts(from, today);
    final buckets = intensityBuckets(
      inRange,
      from: from,
      to: today,
      monthly: _monthly,
    );

    if (!mounted) return;
    setState(() {
      _fitness = sportFitness(activities, from: from, to: today);
      _weekStarts = weekStarts;
      _weekLoads = loadBySportPerBucket(inRange, weekStarts, today);
      _intensity = buckets;
      _intensityTotal = IntensityBucket(
        start: from,
        low: buckets.fold(0, (s, b) => s + b.low),
        moderate: buckets.fold(0, (s, b) => s + b.moderate),
        high: buckets.fold(0, (s, b) => s + b.high),
        sessionsWithoutZones: buckets.fold(
          0,
          (s, b) => s + b.sessionsWithoutZones,
        ),
      );
      _safety = loadSafety(
        activities,
        from: from,
        to: today,
        ctlByDate: ctlByDate,
      );
      _aerobic = aerobicSessions(inRange);
      _selectedLoadBucket = -1;
      _selectedIntensityBucket = -1;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.anTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<int>(
            segments: [
              for (final d in _rangeOptions)
                ButtonSegment(
                  value: d,
                  label: Text(
                    d == 365 ? l10n.rangeOneYear : l10n.rangeDaysShort(d),
                  ),
                ),
            ],
            selected: {_days},
            onSelectionChanged: _loading
                ? null
                : (s) {
                    setState(() => _days = s.first);
                    _load();
                  },
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 64),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            _fitnessCard(context, l10n),
            const SizedBox(height: 16),
            _loadSourceCard(context, l10n),
            const SizedBox(height: 16),
            _intensityCard(context, l10n),
            const SizedBox(height: 16),
            _safetyCard(context, l10n),
            const SizedBox(height: 16),
            _aerobicCard(context, l10n),
          ],
        ],
      ),
    );
  }

  // --- helpers -------------------------------------------------------------

  Color _sportColor(LoadSport s) {
    final scheme = Theme.of(context).colorScheme;
    return switch (s) {
      LoadSport.swim => scheme.primary,
      LoadSport.ride => scheme.tertiary,
      LoadSport.run => scheme.secondary,
      LoadSport.other => scheme.outline,
    };
  }

  String _sportName(AppLocalizations l10n, LoadSport s) => switch (s) {
    LoadSport.swim => l10n.anSportSwim,
    LoadSport.ride => l10n.anSportRide,
    LoadSport.run => l10n.anSportRun,
    LoadSport.other => l10n.anSportOther,
  };

  Color _riskColor(RiskLevel? r) {
    final scheme = Theme.of(context).colorScheme;
    return switch (r) {
      RiskLevel.safe => const Color(0xFF2E9E5B),
      RiskLevel.risky => const Color(0xFFE0A100),
      RiskLevel.high => scheme.error,
      null => scheme.onSurfaceVariant,
    };
  }

  String _riskLabel(
    AppLocalizations l10n,
    RiskLevel r, {
    bool uniform = false,
  }) => switch (r) {
    RiskLevel.safe => l10n.anRiskSafe,
    RiskLevel.risky => l10n.anRiskRisky,
    RiskLevel.high => uniform ? l10n.anRiskHighMonotony : l10n.anRiskHigh,
  };

  Widget _empty(String message) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ),
  );

  Widget _hint(String text) => Text(
    text,
    style: Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );

  // --- 1. fitness by sport -------------------------------------------------

  Widget _fitnessCard(BuildContext context, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).toString();
    final sports = [
      for (final s in LoadSport.values)
        if (_fitness.any((d) => (d.ctl[s] ?? 0) > 0)) s,
    ];
    final series = <ChartSeries>[
      for (final s in sports)
        ChartSeries(
          label: _sportName(l10n, s),
          color: _sportColor(s),
          values: [for (final d in _fitness) (_atl ? d.atl[s] : d.ctl[s]) ?? 0],
        ),
      if (sports.length > 1)
        ChartSeries(
          label: l10n.anTotalLabel,
          color: Theme.of(context).colorScheme.onSurface,
          strokeWidth: 1.4,
          opacity: 0.6,
          values: [for (final d in _fitness) _atl ? d.totalAtl : d.totalCtl],
        ),
    ];
    return SectionCard(
      icon: Icons.stacked_line_chart,
      title: l10n.anSportFitnessTitle,
      trailing: SegmentedButton<bool>(
        showSelectedIcon: false,
        segments: [
          ButtonSegment(value: false, label: Text(l10n.ctlLabel)),
          ButtonSegment(value: true, label: Text(l10n.atlLabel)),
        ],
        selected: {_atl},
        onSelectionChanged: (s) => setState(() => _atl = s.first),
      ),
      child: sports.isEmpty
          ? _empty(l10n.noDataCachedForRange)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 190,
                  child: MetricLineChart(
                    // Re-key so switching CTL/ATL refits the y-scale.
                    key: ValueKey('fitness-$_atl-$_days'),
                    series: series,
                    labels: [
                      for (final d in _fitness)
                        DateFormat.MMMd(locale).format(d.date),
                    ],
                    labelEvery: (_fitness.length / 4).ceil(),
                    showAverage: false,
                    formatValue: (v) => v.toStringAsFixed(0),
                  ),
                ),
                const SizedBox(height: 12),
                ChartLegend(series: series),
                const SizedBox(height: 8),
                _hint(l10n.anSportFitnessHint),
              ],
            ),
    );
  }

  // --- 2. where the load comes from ---------------------------------------

  Widget _loadSourceCard(BuildContext context, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).toString();
    final order = [
      LoadSport.swim,
      LoadSport.ride,
      LoadSport.run,
      LoadSport.other,
    ];
    final used = [
      for (final s in order)
        if (_weekLoads.any((w) => (w[s] ?? 0) > 0)) s,
    ];
    final totals = {
      for (final s in used)
        s: _weekLoads.fold<double>(0, (a, w) => a + (w[s] ?? 0)),
    };
    final grand = totals.values.fold<double>(0, (a, b) => a + b);

    String detail() {
      if (_selectedLoadBucket < 0) {
        return [
          for (final s in used)
            l10n.anShareEntry(
              _sportName(l10n, s),
              (totals[s]! / grand * 100).round(),
            ),
        ].join(' · ');
      }
      final w = _weekLoads[_selectedLoadBucket];
      final total = w.values.fold<double>(0, (a, b) => a + b);
      return '${l10n.anLoadWeekOf(DateFormat.MMMd(locale).format(_weekStarts[_selectedLoadBucket]), total.round())}\n'
          '${[for (final s in used)
            if ((w[s] ?? 0) > 0) '${_sportName(l10n, s)} ${w[s]!.round()}'].join(' · ')}';
    }

    return SectionCard(
      icon: Icons.donut_small_outlined,
      title: l10n.anLoadSourceTitle,
      child: used.isEmpty
          ? _empty(l10n.noDataCachedForRange)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(detail(), style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                _hint(l10n.anLoadSourceTap),
                const SizedBox(height: 12),
                StackedBarChart(
                  bars: [
                    for (var i = 0; i < _weekStarts.length; i++)
                      StackedBar(
                        label: DateFormat.Md(locale).format(_weekStarts[i]),
                        values: [for (final s in used) _weekLoads[i][s] ?? 0],
                      ),
                  ],
                  colors: [for (final s in used) _sportColor(s)],
                  selectedIndex: _selectedLoadBucket < 0
                      ? null
                      : _selectedLoadBucket,
                  onSelect: (i) => setState(
                    () =>
                        _selectedLoadBucket = _selectedLoadBucket == i ? -1 : i,
                  ),
                  labelEvery: (_weekStarts.length / 6).ceil().clamp(1, 12),
                ),
                const SizedBox(height: 12),
                StackedLegend(
                  labels: [for (final s in used) _sportName(l10n, s)],
                  colors: [for (final s in used) _sportColor(s)],
                ),
              ],
            ),
    );
  }

  // --- 3. intensity distribution ------------------------------------------

  String _modelName(AppLocalizations l10n, DistributionModel? m) => switch (m) {
    DistributionModel.polarized => l10n.anModelPolarized,
    DistributionModel.pyramidal => l10n.anModelPyramidal,
    DistributionModel.threshold => l10n.anModelThreshold,
    DistributionModel.highIntensity => l10n.anModelHigh,
    null => l10n.anModelUnknown,
  };

  Widget _intensityCard(BuildContext context, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).toString();
    final scheme = Theme.of(context).colorScheme;
    final colors = [scheme.primary, scheme.tertiary, scheme.error];

    // Over the whole range a few hours of zone data is enough to name a model.
    final selected = _selectedIntensityBucket < 0
        ? _intensityTotal
        : _intensity[_selectedIntensityBucket];
    const minSeconds = 3600;
    final model = selected.model(minSeconds: minSeconds);
    final pi = selected.polarizationIndex(minSeconds: minSeconds);
    String pct(int v) => selected.total == 0
        ? '0'
        : (v / selected.total * 100).round().toString();
    final period = _selectedIntensityBucket < 0
        ? l10n.anRangeOverall
        : DateFormat(
            _monthly ? 'MMM yyyy' : 'MMM d',
            locale,
          ).format(selected.start);

    return SectionCard(
      icon: Icons.stacked_bar_chart,
      title: l10n.anIntensityTitle,
      trailing: SegmentedButton<bool>(
        showSelectedIcon: false,
        segments: [
          ButtonSegment(value: false, label: Text(l10n.anWeekly)),
          ButtonSegment(value: true, label: Text(l10n.anMonthly)),
        ],
        selected: {_monthly},
        onSelectionChanged: (s) {
          setState(() => _monthly = s.first);
          _load();
        },
      ),
      child: _intensityTotal.isEmpty
          ? _empty(l10n.noDataCachedForRange)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.anIntensityPeriod(period, _modelName(l10n, model)),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (!selected.isEmpty)
                      l10n.anIntensitySplit(
                        int.parse(pct(selected.low)),
                        int.parse(pct(selected.moderate)),
                        int.parse(pct(selected.high)),
                      ),
                    if (pi != null)
                      l10n.anPolarizationIndex(pi.toStringAsFixed(2)),
                  ].join(' · '),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                StackedBarChart(
                  normalize: true,
                  bars: [
                    for (final b in _intensity)
                      StackedBar(
                        label: DateFormat(
                          _monthly ? 'MMM' : 'M/d',
                          locale,
                        ).format(b.start),
                        values: [
                          b.low.toDouble(),
                          b.moderate.toDouble(),
                          b.high.toDouble(),
                        ],
                      ),
                  ],
                  colors: colors,
                  selectedIndex: _selectedIntensityBucket < 0
                      ? null
                      : _selectedIntensityBucket,
                  onSelect: (i) => setState(
                    () => _selectedIntensityBucket =
                        _selectedIntensityBucket == i ? -1 : i,
                  ),
                  labelEvery: (_intensity.length / 6).ceil().clamp(1, 12),
                ),
                const SizedBox(height: 12),
                StackedLegend(
                  labels: [
                    l10n.anZoneEasy,
                    l10n.anZoneThreshold,
                    l10n.anZoneHard,
                  ],
                  colors: colors,
                ),
                const SizedBox(height: 8),
                _hint(l10n.anIntensityHint),
                if (selected.sessionsWithoutZones > 0) ...[
                  const SizedBox(height: 4),
                  _hint(l10n.anSessionsNoZones(selected.sessionsWithoutZones)),
                ],
              ],
            ),
    );
  }

  // --- 4. load safety ------------------------------------------------------

  Widget _safetyCard(BuildContext context, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).toString();
    LoadSafetyDay? last(double? Function(LoadSafetyDay) pick) {
      for (var i = _safety.length - 1; i >= 0; i--) {
        if (pick(_safety[i]) != null) return _safety[i];
      }
      return null;
    }

    final lastAcwr = last((d) => d.acwr)?.acwr;
    final lastRamp = last((d) => d.rampRate)?.rampRate;
    final lastMono = last((d) => d.monotony)?.monotony;
    final lastStrain = last((d) => d.strain)?.strain;

    Widget tile(
      String label,
      String value,
      RiskLevel? risk,
      _SafetyMetric? metric, {
      bool uniform = false,
    }) {
      final color = _riskColor(risk);
      final active = metric != null && metric == _metric;
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: metric == null ? null : () => setState(() => _metric = metric),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color.withValues(alpha: active ? 0.18 : 0.08),
              border: Border.all(
                color: active ? color : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (risk != null)
                  Text(
                    _riskLabel(l10n, risk, uniform: uniform),
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: color),
                    maxLines: 1,
                  ),
              ],
            ),
          ),
        ),
      );
    }

    String fmt(double? v, int digits) =>
        v == null ? '–' : v.toStringAsFixed(digits);

    final (values, band, bandText) = switch (_metric) {
      _SafetyMetric.acwr => (
        [for (final d in _safety) d.acwr],
        const ChartBand(low: 0.8, high: 1.3, color: Color(0x332E9E5B)),
        l10n.anAcwrBands,
      ),
      _SafetyMetric.ramp => (
        [for (final d in _safety) d.rampRate],
        const ChartBand(low: 0, high: 5, color: Color(0x332E9E5B)),
        l10n.anRampBands,
      ),
      _SafetyMetric.monotony => (
        [for (final d in _safety) d.monotony],
        const ChartBand(low: 0, high: 1.5, color: Color(0x332E9E5B)),
        l10n.anMonotonyBands,
      ),
    };
    final metricName = switch (_metric) {
      _SafetyMetric.acwr => l10n.anAcwr,
      _SafetyMetric.ramp => l10n.anRamp,
      _SafetyMetric.monotony => l10n.anMonotony,
    };
    final hasChart = values.any((v) => v != null);
    final scheme = Theme.of(context).colorScheme;

    return SectionCard(
      icon: Icons.health_and_safety_outlined,
      title: l10n.anSafetyTitle,
      child: _safety.isEmpty
          ? _empty(l10n.noDataCachedForRange)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    tile(
                      l10n.anAcwr,
                      fmt(lastAcwr, 2),
                      lastAcwr == null ? null : acwrRisk(lastAcwr),
                      _SafetyMetric.acwr,
                    ),
                    const SizedBox(width: 8),
                    tile(
                      l10n.anRamp,
                      fmt(lastRamp, 1),
                      lastRamp == null ? null : rampRisk(lastRamp),
                      _SafetyMetric.ramp,
                    ),
                    const SizedBox(width: 8),
                    tile(
                      l10n.anMonotony,
                      fmt(lastMono, 2),
                      lastMono == null ? null : monotonyRisk(lastMono),
                      _SafetyMetric.monotony,
                      uniform: true,
                    ),
                    const SizedBox(width: 8),
                    tile(l10n.anStrain, fmt(lastStrain, 0), null, null),
                  ],
                ),
                const SizedBox(height: 16),
                if (!hasChart)
                  _empty(
                    _metric == _SafetyMetric.acwr
                        ? l10n.anSafetyNeedHistory
                        : l10n.noDataCachedForRange,
                  )
                else
                  SizedBox(
                    height: 180,
                    child: MetricLineChart(
                      key: ValueKey('safety-$_metric-$_days'),
                      series: [
                        ChartSeries(
                          label: metricName,
                          color: scheme.primary,
                          values: values,
                          fill: true,
                        ),
                      ],
                      labels: [
                        for (final d in _safety)
                          DateFormat.MMMd(locale).format(d.date),
                      ],
                      labelEvery: (_safety.length / 4).ceil(),
                      showAverage: false,
                      zeroLine: _metric == _SafetyMetric.ramp,
                      band: band,
                      formatValue: (v) => v.toStringAsFixed(
                        _metric == _SafetyMetric.ramp ? 1 : 2,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                _hint(bandText),
              ],
            ),
    );
  }

  // --- 5. aerobic base -----------------------------------------------------

  Widget _aerobicCard(BuildContext context, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).toString();
    final scheme = Theme.of(context).colorScheme;
    final sessions = [
      for (final s in _aerobic)
        if (s.sport == _aerobicSport) s,
    ];
    final dates = [for (final s in sessions) s.date];
    final ef = [for (final s in sessions) s.efficiencyFactor];
    final dec = [for (final s in sessions) s.decoupling];
    final trend = linearTrend(dates, ef);
    final hasEf = ef.any((v) => v != null);
    final hasDec = dec.any((v) => v != null);

    String trendText() {
      if (trend == null) return '';
      final mean =
          ef.whereType<double>().fold<double>(0, (a, b) => a + b) /
          ef.whereType<double>().length;
      final pct = trend.slopePer30Days / mean * 100;
      if (pct.abs() < 0.5) return l10n.anEfTrendFlat;
      return l10n.anEfTrend('${pct > 0 ? '+' : ''}${pct.toStringAsFixed(1)}');
    }

    final latestDec = dec.lastWhere((v) => v != null, orElse: () => null);
    final labels = [for (final d in dates) DateFormat.MMMd(locale).format(d)];
    final present = [
      for (final s in [LoadSport.ride, LoadSport.run])
        if (_aerobic.any((a) => a.sport == s)) s,
    ];

    return SectionCard(
      icon: Icons.favorite_border,
      title: l10n.anAerobicTitle,
      trailing: present.length < 2
          ? null
          : SegmentedButton<LoadSport>(
              showSelectedIcon: false,
              segments: [
                for (final s in present)
                  ButtonSegment(value: s, label: Text(_sportName(l10n, s))),
              ],
              selected: {_aerobicSport},
              onSelectionChanged: (s) =>
                  setState(() => _aerobicSport = s.first),
            ),
      child: _aerobic.isEmpty
          ? _empty(l10n.anAerobicEmpty)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _hint(l10n.anAerobicHint),
                const SizedBox(height: 12),
                if (sessions.isEmpty)
                  _empty(l10n.anAerobicEmpty)
                else ...[
                  Text(
                    [
                      l10n.anAerobicSessions(sessions.length),
                      if (trend != null) trendText(),
                      if (latestDec != null)
                        l10n.anLatestDecoupling(latestDec.toStringAsFixed(1)),
                    ].join(' · '),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (hasEf) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n.anEfTitle,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 160,
                      child: MetricLineChart(
                        key: ValueKey('ef-$_aerobicSport-$_days'),
                        series: [
                          ChartSeries(
                            label: l10n.anEfTitle,
                            color: scheme.tertiary,
                            values: ef,
                            average: false,
                          ),
                          if (trend != null)
                            ChartSeries(
                              label: l10n.anEfTitle,
                              color: scheme.onSurfaceVariant,
                              strokeWidth: 1.4,
                              opacity: 0.7,
                              average: false,
                              values: [for (final d in dates) trend.at(d)],
                            ),
                        ],
                        labels: labels,
                        labelEvery: (labels.length / 4).ceil().clamp(1, 99),
                        showAverage: false,
                        smooth: false,
                        formatValue: (v) => v.toStringAsFixed(2),
                      ),
                    ),
                  ],
                  if (hasDec) ...[
                    const SizedBox(height: 16),
                    Text(
                      l10n.anDecouplingTitle,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 160,
                      child: MetricLineChart(
                        key: ValueKey('dec-$_aerobicSport-$_days'),
                        series: [
                          ChartSeries(
                            label: l10n.anDecouplingTitle,
                            color: _riskColor(
                              latestDec == null
                                  ? null
                                  : decouplingRisk(latestDec),
                            ),
                            values: dec,
                            average: false,
                          ),
                        ],
                        labels: labels,
                        labelEvery: (labels.length / 4).ceil().clamp(1, 99),
                        showAverage: false,
                        smooth: false,
                        zeroLine: true,
                        band: const ChartBand(
                          low: -5,
                          high: 5,
                          color: Color(0x332E9E5B),
                        ),
                        formatValue: (v) => '${v.toStringAsFixed(1)}%',
                      ),
                    ),
                    const SizedBox(height: 8),
                    _hint(l10n.anDecouplingBands),
                  ],
                ],
              ],
            ),
    );
  }
}
