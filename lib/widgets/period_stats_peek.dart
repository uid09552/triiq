import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../evaluation/period_stats.dart';
import '../evaluation/year_stats_service.dart';
import '../l10n/app_localizations.dart';
import '../screens/calendar/period_stats_loader.dart';
import '../screens/settings/year_goals_progress.dart';
import 'peek_parts.dart';
import 'peekable.dart';
import 'year_stats_text.dart';

/// Wraps a Calendar header crumb (the year or the month) so that pressing
/// and holding it peeks at the period's statistics — [PeriodStatsPeek] — while
/// a short tap still reaches [child] (it jumps up a level). Also gives screen
/// readers the "Show preview" action.
///
/// Deliberately a separate widget: the Calendar screen itself must stay free
/// of peeks (its day cells, week numbers and session cards have long-press
/// menus), and this keeps that rule checkable by `test/hold_peeks_test.dart`.
class PeriodStatsCrumb extends StatelessWidget {
  const PeriodStatsCrumb({
    super.key,
    required this.date,
    required this.child,
    this.includeMonth = true,
    this.today,
    this.loader,
  });

  /// Any day of the month (and year) to show.
  final DateTime date;
  final Widget child;

  /// Whether the month section is on (the year crumb of the Year level has
  /// no month to speak of).
  final bool includeMonth;

  /// Test seams.
  final DateTime Function()? today;
  final PeriodStatsLoader? loader;

  @override
  Widget build(BuildContext context) => Peekable(
    width: 340,
    estimatedHeight: 440,
    preview: (_) => PeriodStatsPeek(
      date: date,
      includeMonth: includeMonth,
      today: today,
      loader: loader,
    ),
    child: child,
  );
}

/// The month and the year (per sport) behind a Calendar header crumb, read
/// from the local cache: done against planned load, hours, sessions,
/// distance and CTL change for the month with its sports, then the year to
/// date per sport with the change against the same period last year.
class PeriodStatsPeek extends StatefulWidget {
  const PeriodStatsPeek({
    super.key,
    required this.date,
    this.includeMonth = true,
    this.today,
    this.loader,
  });

  final DateTime date;
  final bool includeMonth;
  final DateTime Function()? today;
  final PeriodStatsLoader? loader;

  @override
  State<PeriodStatsPeek> createState() => _PeriodStatsPeekState();
}

class _PeriodStatsPeekState extends State<PeriodStatsPeek> {
  late final Future<PeriodStatsData> _future = _load();

  DateTime get _today => (widget.today ?? DateTime.now)();

  Future<PeriodStatsData> _load() {
    final loader =
        widget.loader ??
        PeriodStatsLoader(
          clock: widget.today,
          years: widget.today == null
              ? null
              : YearStatsService(clock: widget.today),
        );
    return loader.load(widget.date, withMonth: widget.includeMonth);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<PeriodStatsData>(
      future: _future,
      builder: (context, snap) {
        if (snap.hasError) return PeekHint(l10n.peekNoDetails);
        final data = snap.data;
        if (data == null) {
          return const SizedBox(
            key: ValueKey('period-stats-loading'),
            height: 72,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          );
        }
        return PeriodStatsView(data: data, today: _today);
      },
    );
  }
}

/// The statistics card itself, for already loaded [data].
class PeriodStatsView extends StatelessWidget {
  const PeriodStatsView({super.key, required this.data, required this.today});

  final PeriodStatsData data;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final f = StatFormat(locale);
    final month = data.month;
    final year = data.year;
    final semantics = <String>[];

    final children = <Widget>[];

    if (month != null) {
      final monthName = DateFormat.yMMMM(locale).format(month.month);
      children.add(_SectionTitle(icon: Icons.calendar_month, title: monthName));
      children.add(const SizedBox(height: 8));
      final sem = <String>[];
      if (month.isEmpty) {
        children.add(PeekHint(l10n.psNoMonthData));
        sem.add(l10n.psNoMonthData);
      } else {
        final hours = f.hours(month.doneMinutes / 60);
        final total = month.total;
        final ctl = month.ctlChange;
        final ctlText = ctl == null
            ? null
            : '${ctl >= 0 ? '+' : '−'}${f.hours(ctl.abs())}';
        children.add(
          PeekFigures([
            PeekFigure(
              l10n.psTssDonePlanned,
              '${f.integer(month.doneTss)} / ${f.integer(month.plannedTss)}',
            ),
            PeekFigure(l10n.psHours, '$hours h'),
            PeekFigure(
              l10n.psSessions,
              '${month.doneCount} / ${month.plannedCount}',
            ),
            if (total.meters > 0)
              PeekFigure(l10n.peekDistance, '${f.km(total.km)} km'),
            if (ctlText != null) PeekFigure(l10n.psCtlChange, ctlText),
          ]),
        );
        sem.add(
          l10n.calSummary(
            month.doneTss,
            month.plannedTss,
            hours,
            month.doneCount,
            month.plannedCount,
          ),
        );
        if (ctlText != null) sem.add(l10n.calSummaryCtl(ctlText));
        children.add(const SizedBox(height: 8));
        for (final sport in statSportOrder) {
          final t = month.bySport[sport];
          if (t == null || t.isEmpty) continue;
          children.add(
            _MonthSportRow(
              sport: sport,
              label: statSportLabel(l10n, sport),
              values: totalsLine(l10n, f, t, tss: false),
            ),
          );
          sem.add(_semSport(l10n, f, sport, t));
        }
      }
      semantics.add(l10n.psSemMonth(monthName, sem.join('; ')));
      children.add(const Divider(height: 20));
    }

    final isCurrent = year.year == today.year;
    children.add(
      _SectionTitle(
        icon: Icons.insights_outlined,
        title: isCurrent
            ? l10n.psYearToDate(year.year)
            : l10n.psYearFull(year.year),
      ),
    );
    children.add(const SizedBox(height: 6));
    final yearSem = <String>[];
    final sports = year.sports;
    if (sports.isEmpty) {
      children.add(PeekHint(l10n.psNoYearData(year.year)));
      yearSem.add(l10n.psNoYearData(year.year));
    } else {
      var shownChange = false;
      Widget row(
        String label,
        IconData icon,
        Color color,
        SportTotals t,
        SportTotals? last, {
        bool strength = false,
        bool bold = false,
      }) {
        final pct = last == null
            ? null
            : changePercent(t.seconds, last.seconds);
        if (pct != null) shownChange = true;
        return _YearRow(
          label: label,
          icon: icon,
          color: color,
          values: totalsLine(l10n, f, t, distance: !strength, tss: !strength),
          note: strength ? l10n.psNotInTotal : null,
          change: pct == null ? null : f.change(pct),
          bold: bold,
        );
      }

      final scheme = theme.colorScheme;
      for (final sport in sports) {
        if (sport == StatSport.strength) continue;
        children.add(
          row(
            statSportLabel(l10n, sport),
            statSportIcon(sport),
            statSportColor(sport, scheme),
            year.of(sport),
            year.lastOf(sport),
          ),
        );
        yearSem.add(_semSport(l10n, f, sport, year.of(sport)));
      }
      final hasEndurance = sports.any(inEnduranceTotal);
      if (hasEndurance) {
        children.add(
          row(
            l10n.psTotal,
            Icons.functions,
            scheme.onSurface,
            year.total,
            year.lastTotal,
            bold: true,
          ),
        );
        yearSem.add('${l10n.psTotal}: ${totalsLine(l10n, f, year.total)}');
      }
      if (sports.contains(StatSport.strength)) {
        children.add(
          row(
            statSportLabel(l10n, StatSport.strength),
            statSportIcon(StatSport.strength),
            statSportColor(StatSport.strength, scheme),
            year.of(StatSport.strength),
            year.lastOf(StatSport.strength),
            strength: true,
          ),
        );
        yearSem.add(
          '${statSportLabel(l10n, StatSport.strength)}: '
          '${totalsLine(l10n, f, year.of(StatSport.strength), distance: false, tss: false)}',
        );
      }
      final note = year.isPartial
          ? partialNote(l10n, f, year.partialSince!)
          : year.lastYear == null
          ? l10n.psNoLastYear(year.year - 1)
          : shownChange
          ? l10n.psChangeNote(year.year - 1)
          : null;
      if (note != null) {
        children.add(const SizedBox(height: 4));
        children.add(
          Text(
            note,
            key: const ValueKey('period-stats-note'),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
        yearSem.add(note);
      }
    }
    if (sports.isEmpty && year.isPartial) {
      // Nothing yet in the part that is synced; say why anyway.
      final note = partialNote(l10n, f, year.partialSince!);
      children.add(
        Text(
          note,
          key: const ValueKey('period-stats-note'),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
      yearSem.add(note);
    }
    semantics.add(l10n.psSemYear(year.year, yearSem.join('; ')));

    return Column(
      key: const ValueKey('period-stats-peek'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          container: true,
          label: semantics.join('. '),
          child: ExcludeSemantics(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
        if (isCurrent)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: YearGoalsProgress(compact: true, now: today),
          ),
      ],
    );
  }

  static String _semSport(
    AppLocalizations l10n,
    StatFormat f,
    StatSport sport,
    SportTotals t,
  ) => l10n.psSemSport(
    statSportLabel(l10n, sport),
    l10n.sessionsCount(t.sessions),
    f.hours(t.hours),
    f.km(t.km),
    f.integer(t.tss),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

/// A month's sport: icon, name, and its sessions, time and distance.
class _MonthSportRow extends StatelessWidget {
  const _MonthSportRow({
    required this.sport,
    required this.label,
    required this.values,
  });

  final StatSport sport;
  final String label;
  final String values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            statSportIcon(sport),
            size: 16,
            color: statSportColor(sport, theme.colorScheme),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              values,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A year row: sport (and the change against last year) over its figures.
class _YearRow extends StatelessWidget {
  const _YearRow({
    required this.label,
    required this.icon,
    required this.color,
    required this.values,
    this.note,
    this.change,
    this.bold = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final String values;
  final String? note;
  final String? change;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  note == null ? label : '$label · $note',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
              if (change != null) ...[
                const SizedBox(width: 6),
                Text(
                  change!,
                  key: ValueKey('change-$label'),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 22),
            child: Text(
              values,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ),
        ],
      ),
    );
  }
}
