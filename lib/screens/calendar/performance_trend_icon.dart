import 'package:flutter/material.dart';

import '../../data/models/local_activity.dart';
import '../../data/repositories/activities_repository.dart';
import '../../evaluation/performance_trend.dart';
import '../../l10n/app_localizations.dart';

/// A small trending-up/down icon for a completed activity: efficiency
/// better or worse than the athlete's recent norm for that sport. Renders
/// nothing when there's no clear change or too little data.
class PerformanceTrendIcon extends StatefulWidget {
  const PerformanceTrendIcon({super.key, required this.activity});

  final LocalActivity activity;

  @override
  State<PerformanceTrendIcon> createState() => _PerformanceTrendIconState();
}

class _PerformanceTrendIconState extends State<PerformanceTrendIcon> {
  late Future<PerformanceTrend?> _trend = _compute();

  @override
  void didUpdateWidget(PerformanceTrendIcon old) {
    super.didUpdateWidget(old);
    if (old.activity.id != widget.activity.id) _trend = _compute();
  }

  Future<PerformanceTrend?> _compute() async {
    final day = DateTime.tryParse(widget.activity.date);
    if (day == null) return null;
    try {
      final history = await ActivitiesRepository().getRange(
        _fmt(day.subtract(const Duration(days: 42))),
        widget.activity.date,
      );
      return performanceTrend(widget.activity, history);
    } catch (_) {
      return null;
    }
  }

  static String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PerformanceTrend?>(
      future: _trend,
      builder: (context, snapshot) {
        final trend = snapshot.data;
        if (trend == null) return const SizedBox.shrink();
        final l10n = AppLocalizations.of(context)!;
        final scheme = Theme.of(context).colorScheme;
        final up = trend == PerformanceTrend.up;
        return Tooltip(
          message: up ? l10n.performanceUpTooltip : l10n.performanceDownTooltip,
          child: Icon(
            up ? Icons.trending_up : Icons.trending_down,
            key: ValueKey(up ? 'performance-up' : 'performance-down'),
            size: 20,
            color: up ? scheme.primary : scheme.error,
          ),
        );
      },
    );
  }
}
