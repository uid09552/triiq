import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../data/models/local_activity.dart';
import '../../data/repositories/activities_repository.dart';
import '../../evaluation/load_heatmap.dart';
import '../../evaluation/training_analytics.dart' show LoadSport;
import '../../l10n/app_localizations.dart';
import '../../util/dates.dart';
import '../../widgets/chart_options.dart';
import '../../widgets/section_card.dart';

enum _Period { last12Months, thisYear, lastYear }

/// A year of training load as a calendar grid — one square per day, one
/// column per week, coloured by TSS — in the style of a contribution graph.
/// Tap a day for its load and sessions.
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
  static const _gap = 3.0;
  static const _labelWidth = 26.0;

  _Period _period = _Period.last12Months;
  LoadSport? _sport;
  bool _loading = true;
  List<LocalActivity> _activities = const [];
  DateTime? _selected;

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
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final (from, to) = _range;
    final rows = await widget.repository.getRange(isoDate(from), isoDate(to));
    if (!mounted) return;
    setState(() {
      _activities = rows;
      _selected = null;
      _loading = false;
    });
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
                '${_periodLabel(l10n, _period)} · ${_sportLabel(l10n, _sport)}',
            onPressed: () => _openOptions(l10n),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SectionCard(
                  icon: Icons.grid_view_rounded,
                  title: l10n.hmTitle,
                  child: heatmap.totalTss == 0
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: Text(l10n.hmNoData)),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _readout(context, l10n, heatmap),
                            const SizedBox(height: 10),
                            _Grid(
                              heatmap: heatmap,
                              selected: _selected,
                              onSelect: (d) => setState(
                                () => _selected = _selected == d ? null : d,
                              ),
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
              color: heatColor(theme.colorScheme, level),
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
/// four strengths.
Color heatColor(ColorScheme scheme, int level) => level == 0
    ? scheme.surfaceContainerHighest
    : scheme.primary.withValues(
        alpha: const <double>[0, 0.30, 0.50, 0.75, 1.0][level],
      );

class _Grid extends StatefulWidget {
  const _Grid({
    required this.heatmap,
    required this.selected,
    required this.onSelect,
  });

  final LoadHeatmap heatmap;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelect;

  @override
  State<_Grid> createState() => _GridState();
}

class _GridState extends State<_Grid> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // Start at the latest week; the year scrolls back from there.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final weeks = widget.heatmap.weeks;
    const step = _LoadHeatmapScreenState._cell + _LoadHeatmapScreenState._gap;

    // A month label above the first column of each month.
    DateTime firstDayOf(int w) => weeks[w].firstWhere((d) => d.inRange).date;
    String? monthLabel(int w) {
      final first = firstDayOf(w);
      if (w > 0 && firstDayOf(w - 1).month == first.month) return null;
      return DateFormat.MMM(locale).format(first);
    }

    final weekdays = [
      for (var i = 0; i < 7; i++)
        i.isEven ? DateFormat.E(locale).format(DateTime(2026, 11, 2 + i)) : '',
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const SizedBox(height: 18),
            for (final label in weekdays)
              SizedBox(
                width: _LoadHeatmapScreenState._labelWidth,
                height: step,
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 9),
                ),
              ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var w = 0; w < weeks.length; w++)
                  Padding(
                    padding: const EdgeInsets.only(
                      right: _LoadHeatmapScreenState._gap,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 18,
                          width: _LoadHeatmapScreenState._cell,
                          child: OverflowBox(
                            maxWidth: 40,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              monthLabel(w) ?? '',
                              maxLines: 1,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ),
                        for (final day in weeks[w])
                          GestureDetector(
                            onTap: day.inRange
                                ? () => widget.onSelect(day.date)
                                : null,
                            child: Container(
                              key: day.inRange
                                  ? ValueKey('hm-${isoDate(day.date)}')
                                  : null,
                              width: _LoadHeatmapScreenState._cell,
                              height: _LoadHeatmapScreenState._cell,
                              margin: const EdgeInsets.only(
                                bottom: _LoadHeatmapScreenState._gap,
                              ),
                              decoration: BoxDecoration(
                                color: day.inRange
                                    ? heatColor(
                                        theme.colorScheme,
                                        widget.heatmap.levelOf(day.tss),
                                      )
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(3),
                                border: widget.selected == day.date
                                    ? Border.all(
                                        color: theme.colorScheme.onSurface,
                                        width: 1.5,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
