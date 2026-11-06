import 'package:flutter/material.dart';

import '../../evaluation/compare.dart';
import '../../l10n/app_localizations.dart';
import 'compare_format.dart';

class CompareRow {
  const CompareRow(this.label, this.a, this.b, this.change);

  final String label;
  final String a;
  final String b;

  /// Relative change from A to B (0.1 = +10 %); null when it isn't defined.
  final double? change;
}

/// The rows both tabs share: the same dimensions for an activity pair and a
/// block pair. [a] is the reference (first activity / previous block), [b]
/// what it is compared against; the change runs from [a] to [b].
List<CompareRow> compareRows(
  AppLocalizations l10n,
  BlockStats a,
  BlockStats b,
  String? sportType, {
  bool showSessions = false,
}) {
  String? dash(String? s) => s;
  CompareRow row(
    String label,
    double? va,
    double? vb,
    String Function(double) fmt,
  ) => CompareRow(
    label,
    va == null ? '–' : fmt(va),
    vb == null ? '–' : fmt(vb),
    relativeChange(va, vb),
  );
  double? easy(BlockStats s) {
    final share = s.split?.lowShare;
    return share == null ? null : share * 100;
  }

  return [
    if (showSessions)
      row(
        l10n.cmpSessions,
        a.count.toDouble(),
        b.count.toDouble(),
        (v) => v.round().toString(),
      ),
    row(
      l10n.cmpDistance,
      a.distance > 0 ? a.distance : null,
      b.distance > 0 ? b.distance : null,
      (v) => '${(v / 1000).toStringAsFixed(1)} km',
    ),
    row(
      l10n.cmpTime,
      a.seconds > 0 ? a.seconds.toDouble() : null,
      b.seconds > 0 ? b.seconds.toDouble() : null,
      (v) => durationLabel(v.round()),
    ),
    row(
      l10n.cmpElevation,
      a.elevation > 0 ? a.elevation : null,
      b.elevation > 0 ? b.elevation : null,
      (v) => '${v.round()} m',
    ),
    row(
      l10n.cmpLoad,
      a.load > 0 ? a.load.toDouble() : null,
      b.load > 0 ? b.load.toDouble() : null,
      (v) => v.round().toString(),
    ),
    row(
      l10n.cmpAvgSpeed,
      a.avgSpeed,
      b.avgSpeed,
      (v) => speedLabel(v, sportType),
    ),
    row(l10n.cmpAvgPower, a.avgWatts, b.avgWatts, (v) => '${v.round()} W'),
    row(
      l10n.cmpAvgHr,
      a.avgHeartrate,
      b.avgHeartrate,
      (v) => '${v.round()} bpm',
    ),
    row(
      l10n.cmpEf,
      a.efficiencyFactor,
      b.efficiencyFactor,
      (v) => v.toStringAsFixed(2),
    ),
    row(
      l10n.cmpDecoupling,
      a.decoupling,
      b.decoupling,
      (v) => '${v.toStringAsFixed(1)}%',
    ),
    row(l10n.cmpEasyShare, easy(a), easy(b), (v) => '${v.round()}%'),
  ].where((r) => dash(r.a) != '–' || dash(r.b) != '–').toList();
}

/// Label, the two values in the compare colours, and the change.
class CompareTable extends StatelessWidget {
  const CompareTable({
    super.key,
    required this.rows,
    required this.colorA,
    required this.colorB,
    required this.headerA,
    required this.headerB,
  });

  final List<CompareRow> rows;
  final Color colorA;
  final Color colorB;
  final String headerA;
  final String headerB;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    Widget cell(
      String text, {
      Color? color,
      bool bold = false,
      bool end = true,
    }) => Expanded(
      flex: 3,
      child: Text(
        text,
        textAlign: end ? TextAlign.end : TextAlign.start,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: color,
          fontWeight: bold ? FontWeight.w700 : null,
        ),
      ),
    );
    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 4, child: Text('', style: muted)),
            cell(headerA, color: colorA, bold: true),
            cell(headerB, color: colorB, bold: true),
            Expanded(
              flex: 2,
              child: Text('Δ', textAlign: TextAlign.end, style: muted),
            ),
          ],
        ),
        const Divider(height: 12),
        for (final r in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(r.label, style: theme.textTheme.bodySmall),
                ),
                cell(r.a),
                cell(r.b),
                Expanded(
                  flex: 2,
                  child: Text(
                    changeLabel(r.change) ?? '',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
