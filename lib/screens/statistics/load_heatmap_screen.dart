import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../data/models/local_activity.dart';
import '../../data/repositories/activities_repository.dart';
import '../../evaluation/load_heatmap.dart';
import '../../evaluation/training_analytics.dart' show LoadSport;
import '../../l10n/app_localizations.dart';
import '../../util/dates.dart';
import '../../widgets/chart_options.dart';
import '../../widgets/charts/chart_theme.dart';
import '../../widgets/section_card.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/status_message.dart';
import 'heatmap_views.dart';

enum _Period { last12Months, thisYear, lastYear }

/// A year of training load, one square per day coloured by TSS, in one of
/// three layouts ([HeatmapStyle]): the contribution-graph grid (a column per
/// week, or a row per week on a narrow phone), twelve small month calendars,
/// or a week × weekday table with totals. Layout and colour scale are kept
/// in shared_preferences. Tap a day for its load and sessions.
class LoadHeatmapScreen extends StatefulWidget {
  LoadHeatmapScreen({super.key, ActivitiesRepository? repository, this.today})
    : repository = repository ?? ActivitiesRepository();

  final ActivitiesRepository repository;
  final DateTime? today;

  @override
  State<LoadHeatmapScreen> createState() => _LoadHeatmapScreenState();
}

class _LoadHeatmapScreenState extends State<LoadHeatmapScreen> {
  static const _cell = 13.0;

  _Period _period = _Period.last12Months;
  LoadSport? _sport;
  bool _loading = true;
  List<LocalActivity> _activities = const [];
  DateTime? _selected;
  HeatmapPrefs _prefs = const HeatmapPrefs();

  DateTime get _today => dateOnly(widget.today ?? DateTime.now());

  (DateTime, DateTime) get _range => switch (_period) {
    _Period.last12Months => (
      DateTime(_today.year - 1, _today.month, _today.day + 1),
      _today,
    ),
    _Period.thisYear => (DateTime(_today.year, 1, 1), _today),
    _Period.lastYear => (
      DateTime(_today.year - 1, 1, 1),
      DateTime(_today.year - 1, 12, 31),
    ),
  };

  @override
  void initState() {
    super.initState();
    _load();
    HeatmapPrefs.load().then((p) {
      if (mounted) setState(() => _prefs = p);
    });
  }

  void _setPrefs(HeatmapPrefs p) {
    _prefs = p;
    p.save();
  }

  String _styleLabel(AppLocalizations l10n, HeatmapStyle s) => switch (s) {
    HeatmapStyle.grid => l10n.hmStyleGrid,
    HeatmapStyle.months => l10n.hmStyleMonths,
    HeatmapStyle.matrix => l10n.hmStyleMatrix,
  };

  Object? _error;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final (from, to) = _range;
    try {
      final rows = await widget.repository.getRange(isoDate(from), isoDate(to));
      if (!mounted) return;
      setState(() {
        _activities = rows;
        _selected = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  String _periodLabel(AppLocalizations l10n, _Period p) => switch (p) {
    _Period.last12Months => l10n.hmPeriod12m,
    _Period.thisYear => l10n.hmPeriodYear,
    _Period.lastYear => l10n.hmPeriodLastYear,
  };

  String _sportLabel(AppLocalizations l10n, LoadSport? s) => switch (s) {
    null => l10n.analysisSportAll,
    LoadSport.swim => l10n.sportSwim,
    LoadSport.ride => l10n.sportRide,
    LoadSport.run => l10n.sportRun,
    LoadSport.other => l10n.anSportOther,
  };

  void _openOptions(AppLocalizations l10n) {
    showChartOptions(
      context,
      title: l10n.hmTitle,
      ownerSetState: setState,
      builder: (sheet, apply) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OptionGroup(
            label: l10n.chartOptionsRange,
            child: SegmentedButton<_Period>(
              showSelectedIcon: false,
              segments: [
                for (final p in _Period.values)
                  ButtonSegment(value: p, label: Text(_periodLabel(l10n, p))),
              ],
              selected: {_period},
              onSelectionChanged: (s) {
                apply(() => _period = s.first);
                _load();
              },
            ),
          ),
          OptionGroup(
            label: l10n.hmStyle,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final s in HeatmapStyle.values)
                  ChoiceChip(
                    key: ValueKey('hm-style-${s.name}'),
                    label: Text(_styleLabel(l10n, s)),
                    selected: _prefs.style == s,
                    onSelected: (_) => apply(
                      () => _setPrefs(
                        HeatmapPrefs(style: s, scale: _prefs.scale),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          OptionGroup(
            label: l10n.hmScale,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final s in HeatScale.values)
                  ChoiceChip(
                    key: ValueKey('hm-scale-${s.name}'),
                    label: Text(
                      s == HeatScale.theme
                          ? l10n.hmScaleTheme
                          : l10n.hmScaleViridis,
                    ),
                    selected: _prefs.scale == s,
                    onSelected: (_) => apply(
                      () => _setPrefs(
                        HeatmapPrefs(style: _prefs.style, scale: s),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          OptionGroup(
            label: l10n.chartOptionsSport,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final s in [
                  null,
                  LoadSport.swim,
                  LoadSport.ride,
                  LoadSport.run,
                ])
                  ChoiceChip(
                    key: ValueKey('hm-sport-${s?.name ?? 'all'}'),
                    label: Text(_sportLabel(l10n, s)),
                    selected: _sport == s,
                    onSelected: (_) => apply(() {
                      _sport = s;
                      _selected = null;
                    }),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (from, to) = _range;
    final heatmap = buildLoadHeatmap(
      _activities,
      from: from,
      to: to,
      sport: _sport,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.hmTitle),
        actions: [
          ChartOptionsButton(
            summary:
                '${_periodLabel(l10n, _period)} · ${_sportLabel(l10n, _sport)}'
                ' · ${_styleLabel(l10n, _prefs.style)}',
            onPressed: () => _openOptions(l10n),
          ),
        ],
      ),
      body: _loading
          ? const SkeletonScreen(cards: 3)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_error != null)
                  StatusMessage.error(error: _error!, onRetry: _load)
                else
                  SectionCard(
                    icon: Icons.grid_view_rounded,
                    title: l10n.hmTitle,
                    child: heatmap.totalTss == 0
                        ? StatusMessage.needsSync(
                            context,
                            title: l10n.hmNoData,
                            icon: Icons.grid_view_rounded,
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _readout(context, l10n, heatmap),
                              const SizedBox(height: 10),
                              Semantics(
                                container: true,
                                label: _semantics(context, l10n, heatmap),
                                child: _view(l10n, heatmap),
                              ),
                              const SizedBox(height: 10),
                              _legend(context, l10n),
                            ],
                          ),
                  ),
                if (heatmap.totalTss > 0) ...[
                  const SizedBox(height: 16),
                  _stats(context, l10n, heatmap),
                ],
              ],
            ),
    );
  }

  Widget _view(AppLocalizations l10n, LoadHeatmap heatmap) {
    void select(DateTime d) =>
        setState(() => _selected = _selected == d ? null : d);
    return switch (_prefs.style) {
      HeatmapStyle.grid => HeatmapGridView(
        heatmap: heatmap,
        selected: _selected,
        onSelect: select,
        scale: _prefs.scale,
      ),
      HeatmapStyle.months => HeatmapMonthsView(
        heatmap: heatmap,
        selected: _selected,
        onSelect: select,
        scale: _prefs.scale,
      ),
      HeatmapStyle.matrix => HeatmapMatrixView(
        heatmap: heatmap,
        selected: _selected,
        onSelect: select,
        scale: _prefs.scale,
        weekLabel: l10n.hmWeekCol,
      ),
    };
  }

  /// The screen-reader summary: the year's figures, the layout, and for the
  /// table the busiest weekday.
  String _semantics(
    BuildContext context,
    AppLocalizations l10n,
    LoadHeatmap heatmap,
  ) {
    final parts = [
      l10n.a11yHeatmap(
        heatmap.activeDays,
        heatmap.totalTss,
        heatmap.longestStreak,
      ),
      _styleLabel(l10n, _prefs.style),
    ];
    if (_prefs.style == HeatmapStyle.matrix) {
      final totals = HeatmapMatrixView.weekdayTotals(heatmap);
      var best = 0;
      for (var i = 1; i < 7; i++) {
        if (totals[i] > totals[best]) best = i;
      }
      final locale = Localizations.localeOf(context).toString();
      parts.add(
        l10n.a11yHeatmapMatrix(
          DateFormat.EEEE(locale).format(DateTime(2026, 11, 2 + best)),
          totals[best],
        ),
      );
    }
    return parts.join('. ');
  }

  Widget _readout(BuildContext context, AppLocalizations l10n, LoadHeatmap h) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final d = _selected == null ? null : h.dayOn(_selected!);
    final text = d == null
        ? l10n.hmTap
        : d.tss == 0 && d.sessions == 0
        ? l10n.hmRest(DateFormat.yMMMEd(locale).format(d.date))
        : l10n.hmDay(
            DateFormat.yMMMEd(locale).format(d.date),
            d.tss,
            d.sessions,
          );
    return Text(
      text,
      key: const ValueKey('hm-readout'),
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _legend(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(l10n.hmLess, style: theme.textTheme.labelSmall),
        const SizedBox(width: 6),
        for (var level = 0; level <= 4; level++)
          Container(
            width: _cell,
            height: _cell,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              color: ChartTheme.of(context).heatColorOf(level, _prefs.scale),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        const SizedBox(width: 4),
        Text(l10n.hmMore, style: theme.textTheme.labelSmall),
      ],
    );
  }

  Widget _stats(BuildContext context, AppLocalizations l10n, LoadHeatmap h) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    Widget stat(String label, String value) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: stat(l10n.hmTotal, '${h.totalTss} TSS')),
                Expanded(child: stat(l10n.hmActiveDays, '${h.activeDays}')),
                Expanded(
                  child: stat(
                    l10n.hmLongestStreak,
                    l10n.hmDays(h.longestStreak),
                  ),
                ),
              ],
            ),
            if (h.busiestWeekStart != null) ...[
              const SizedBox(height: 12),
              stat(
                l10n.hmBusiestWeek,
                l10n.hmWeekOf(
                  h.busiestWeekTss,
                  DateFormat.MMMd(locale).format(h.busiestWeekStart!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The colour of a heatmap step: the rest colour, then the theme colour at
/// four strengths. See [ChartTheme.heatColorOf] for the other scales.
Color heatColor(ColorScheme scheme, int level) =>
    ChartTheme.fromColorScheme(scheme).heatColorOf(level);
