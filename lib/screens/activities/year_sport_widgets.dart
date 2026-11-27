import 'package:flutter/material.dart';

import '../../data/models/local_activity.dart';
import '../../evaluation/period_stats.dart';
import '../../evaluation/year_stats_service.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/year_stats_text.dart';

/// Loads [YearSnapshot]s from [service] for one year and reloads when the
/// service forgets its copy (the cache changed). Shared by the widgets below.
mixin _YearSnapshotState<T extends StatefulWidget> on State<T> {
  YearStatsService get service;
  int? get year;

  YearSnapshot? snapshot;
  int _seq = 0;

  @override
  void initState() {
    super.initState();
    service.addListener(reload);
    reload();
  }

  @override
  void dispose() {
    service.removeListener(reload);
    super.dispose();
  }

  Future<void> reload() async {
    final y = year;
    if (y == null) return;
    final seq = ++_seq;
    try {
      final s = await service.load(y);
      if (mounted && seq == _seq) setState(() => snapshot = s);
    } catch (error) {
      debugPrint('YearStats: cannot read the cache: $error');
    }
  }
}

/// "This year · Ride" on a completed session: the sport's year to date —
/// sessions, hours, distance, TSS —, what share of the distance this session
/// is, where it ranks among the year's sessions and how the year compares
/// with the same date last year. Reads the local cache; renders nothing
/// while loading or when the year has nothing for the sport.
class YearSportCard extends StatefulWidget {
  YearSportCard({super.key, required this.activity, YearStatsService? service})
    : service = service ?? YearStatsService.instance;

  final LocalActivity activity;
  final YearStatsService service;

  @override
  State<YearSportCard> createState() => _YearSportCardState();
}

class _YearSportCardState extends State<YearSportCard>
    with _YearSnapshotState<YearSportCard> {
  @override
  YearStatsService get service => widget.service;

  @override
  int? get year => yearOfDay(widget.activity.date);

  @override
  Widget build(BuildContext context) {
    final snap = snapshot;
    if (snap == null) return const SizedBox.shrink();
    final row = StatRow.of(widget.activity);
    final ctx = sessionYearContext(row, snap.stats, snap.rows);
    if (ctx == null || ctx.total.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final f = StatFormat.of(context);
    final sport = ctx.sport;
    final strength = sport == StatSport.strength;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    final lines = <String>[];
    if (ctx.sharePercent != null) {
      final pct = ctx.sharePercent!;
      lines.add(
        l10n.yearCardShare(
          pct < 1 ? '<1' : f.percent(pct),
          ctx.shareByDistance
              ? '${f.km(ctx.total.km)} km'
              : '${f.hours(ctx.total.hours)} h',
        ),
      );
    }
    final rank = ctx.rank;
    if (rank != null && ctx.rankOf >= 3 && rank <= 10) {
      lines.add(
        ctx.rankByDistance
            ? l10n.yearCardRankDistance(rank, ctx.rankOf)
            : l10n.yearCardRankTss(rank, ctx.rankOf),
      );
    }
    final change = ctx.hoursChange;
    if (change != null) {
      lines.add(l10n.yearCardVsLast(f.change(change), ctx.year.year - 1));
    }
    final totals = totalsLine(
      l10n,
      f,
      ctx.total,
      distance: !strength,
      tss: !strength,
    );
    final title = l10n.yearCardTitle(statSportLabel(l10n, sport));

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Semantics(
        container: true,
        label: [title, totals, ...lines].join('. '),
        child: ExcludeSemantics(
          child: Card(
            key: const ValueKey('year-sport-card'),
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        statSportIcon(sport),
                        size: 16,
                        color: statSportColor(sport, scheme),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(totals, key: const ValueKey('year-card-totals')),
                  for (final line in lines) Text(line, style: muted),
                  if (ctx.partialSince != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        partialNote(l10n, f, ctx.partialSince!),
                        key: const ValueKey('year-card-note'),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
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

/// One muted line for a session's sport and year — "Run this year: 82 h ·
/// 1,034 km" — on planned sessions and in the activity peek. Renders nothing
/// while loading, when the sport has no session that year, and, with
/// [hideWhenPartial], when the cache does not cover the whole year (a
/// peek has no room for the caveat).
class YearContextLine extends StatefulWidget {
  YearContextLine({
    super.key,
    required this.type,
    required this.date,
    this.hideWhenPartial = false,
    this.padding = EdgeInsets.zero,
    YearStatsService? service,
  }) : service = service ?? YearStatsService.instance;

  /// The Intervals.icu type of the session.
  final String? type;

  /// `yyyy-MM-dd` — its year is the year shown.
  final String date;
  final bool hideWhenPartial;
  final EdgeInsetsGeometry padding;
  final YearStatsService service;

  @override
  State<YearContextLine> createState() => _YearContextLineState();
}

class _YearContextLineState extends State<YearContextLine>
    with _YearSnapshotState<YearContextLine> {
  @override
  YearStatsService get service => widget.service;

  @override
  int? get year => yearOfDay(widget.date);

  @override
  Widget build(BuildContext context) {
    final stats = snapshot?.stats;
    if (stats == null) return const SizedBox.shrink();
    final sport = statSportOf(widget.type);
    final t = stats.of(sport);
    if (t.isEmpty || (widget.hideWhenPartial && stats.isPartial)) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final f = StatFormat.of(context);
    final label = statSportLabel(l10n, sport);
    final text = t.meters > 0 && sport != StatSport.strength
        ? l10n.yearContextLine(label, f.hours(t.hours), f.km(t.km))
        : l10n.yearContextLineNoDistance(label, f.hours(t.hours));
    final style = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            key: const ValueKey('year-context-line'),
            maxLines: widget.hideWhenPartial ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
          if (stats.isPartial)
            Text(
              partialNote(l10n, f, stats.partialSince!),
              key: const ValueKey('year-context-note'),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}
