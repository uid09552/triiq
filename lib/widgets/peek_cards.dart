import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/models/local_activity.dart';
import '../data/models/local_event.dart';
import '../l10n/app_localizations.dart';
import '../plan/plan_models.dart';
import '../screens/activities/activity_icons.dart';
import '../screens/calendar/performance_trend_icon.dart';
import '../screens/events/event_labels.dart';
import 'peek_parts.dart';
import 'workout_steps.dart';

/// A peek's title line: an icon, a name and an optional muted second line.
class _PeekHeader extends StatelessWidget {
  const _PeekHeader({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty)
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 6), trailing!],
      ],
    );
  }
}

/// Key figures of a completed activity, from the cached row alone (no
/// streams, no network): distance, time, TSS, average heart rate and power
/// and climb when the activity has them, and the performance-trend arrow.
class ActivityPeek extends StatelessWidget {
  const ActivityPeek({super.key, required this.activity});

  final LocalActivity activity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final a = activity;
    double? number(String key) {
      final v = a.raw[key];
      return v is num && v > 0 ? v.toDouble() : null;
    }

    final hr = number('average_heartrate');
    final power = number('icu_average_watts');
    final climb = number('total_elevation_gain');
    final figures = [
      if (a.distance != null && a.distance! > 0)
        PeekFigure(l10n.peekDistance, formatDistanceMeters(a.distance!)),
      if ((a.movingTime ?? 0) > 0)
        PeekFigure(l10n.peekDuration, formatDurationSecs(a.movingTime!)),
      if (a.trainingLoad != null)
        PeekFigure(l10n.tssSuffix, '${a.trainingLoad}'),
      if (hr != null) PeekFigure(l10n.peekAvgHr, '${hr.round()}'),
      if (power != null) PeekFigure(l10n.peekAvgPower, '${power.round()} W'),
      if (climb != null) PeekFigure(l10n.peekClimb, '${climb.round()} m'),
    ];
    return Column(
      key: ValueKey('activity-peek-${a.id}'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PeekHeader(
          icon: activityTypeIcon(a.type),
          color: sportColor(a.type, scheme),
          title: a.name ?? a.type ?? l10n.activityFallback,
          subtitle: formatIsoDate(a.date),
          trailing: PerformanceTrendIcon(activity: a),
        ),
        const SizedBox(height: 10),
        if (figures.isEmpty)
          PeekHint(l10n.peekNoDetails)
        else
          PeekFigures(figures),
      ],
    );
  }
}

/// A calendar event (race, note, holiday, …): name, type, dates and the
/// start of its description.
class EventPeek extends StatelessWidget {
  const EventPeek({super.key, required this.event});

  final LocalEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final e = event;
    final start = DateTime.tryParse(e.date);
    final end = DateTime.tryParse(e.raw['end_date_local'] as String? ?? '');
    final fmt = DateFormat.yMMMEd(locale);
    final when = start == null
        ? e.date
        : end != null && end.isAfter(start)
        ? '${fmt.format(start)} – ${fmt.format(end)}'
        : fmt.format(start);
    final description = (e.description ?? '').trim();
    final theme = Theme.of(context);
    return Column(
      key: ValueKey('event-peek-${e.id}'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PeekHeader(
          icon: e.type == null
              ? Icons.event_outlined
              : activityTypeIcon(e.type),
          color: theme.colorScheme.primary,
          title: e.name ?? eventCategoryLabel(l10n, e.category),
          subtitle: eventCategoryLabel(l10n, e.category),
        ),
        const SizedBox(height: 8),
        Text(when, style: theme.textTheme.bodyMedium),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            description,
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// A plan session: sport, name, duration and TSS, then the first steps.
class PlanSessionPeek extends StatelessWidget {
  const PlanSessionPeek({super.key, required this.session});

  final PlanSession session;

  /// Lines of the workout shown before "…".
  static const maxLines = 12;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final s = session;
    final lines = s.description.trim().split('\n');
    final text = lines.length > maxLines
        ? '${lines.take(maxLines).join('\n')}\n…'
        : s.description.trim();
    return Column(
      key: ValueKey('plan-session-peek-${s.id ?? s.name}'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PeekHeader(
          icon: activityTypeIcon(s.sport),
          color: sportColor(s.sport, scheme),
          title: s.name,
          subtitle: l10n.planSessionMinutes(s.minutes, s.load),
        ),
        const SizedBox(height: 10),
        if (text.isEmpty)
          PeekHint(l10n.peekNoDetails)
        else
          WorkoutDescription(text: text),
      ],
    );
  }
}

/// A search result: where it lives and the passage of the app docs that
/// describes it, longer than the one line the result shows.
class TextPeek extends StatelessWidget {
  const TextPeek({
    super.key,
    required this.icon,
    required this.title,
    required this.path,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String path;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      key: const ValueKey('text-peek'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PeekHeader(
          icon: icon,
          color: theme.colorScheme.primary,
          title: title,
          subtitle: path,
        ),
        if (text.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            text,
            maxLines: 9,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
