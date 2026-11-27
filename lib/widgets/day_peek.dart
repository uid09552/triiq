import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/models/local_activity.dart';
import '../data/models/local_event.dart';
import '../data/planned_items.dart';
import '../data/repositories/activities_repository.dart';
import '../evaluation/readiness.dart';
import '../evaluation/readiness_service.dart';
import '../l10n/app_localizations.dart';
import '../screens/activities/activity_icons.dart';
import '../screens/calendar/performance_trend_icon.dart';
import '../screens/today/readiness_card.dart'
    show readinessColor, readinessLevelLabel;
import '../util/dates.dart';
import '../util/clock.dart';

/// Reads what a day holds from the local cache — never the network — for a
/// [DayPeek]. Planned items come from [PlannedItemsRepository], the same
/// place the calendar and Today read, so the peek always agrees with them.
class DayPeekSource {
  DayPeekSource({
    PlannedItemsRepository? planned,
    ActivitiesRepository? activities,
    DateTime Function()? clock,
  }) : _planned = planned,
       _activities = activities,
       _clock = clock ?? clockNow;

  final PlannedItemsRepository? _planned;
  final ActivitiesRepository? _activities;
  final DateTime Function() _clock;

  /// The planned sessions and completed activities of [day].
  Future<DayPeekData> load(DateTime day) async {
    final iso = isoDate(day);
    final planned = await (_planned ?? PlannedItemsRepository()).getByDate(iso);
    final done = await (_activities ?? ActivitiesRepository()).getByDate(iso);
    return DayPeekData(
      day: day,
      planned: [
        for (final e in planned)
          if (e.isTraining) e,
      ],
      activities: done,
    );
  }

  /// Readiness on [day] when it has wearable data; null for the future, an
  /// empty day or any trouble reading it.
  Future<Readiness?> readiness(DateTime day) async {
    if (dateOnly(day).isAfter(dateOnly(_clock()))) return null;
    try {
      final days = await ReadinessService(clock: _clock).loadDays(day, day);
      final r = days.isEmpty ? null : days.first;
      return r != null && r.dataState == ReadinessDataState.complete ? r : null;
    } catch (_) {
      return null;
    }
  }
}

/// One day's planned sessions and completed activities.
class DayPeekData {
  const DayPeekData({
    required this.day,
    this.planned = const [],
    this.activities = const [],
  });

  final DateTime day;

  /// Planned training only (no notes or holidays).
  final List<LocalEvent> planned;
  final List<LocalActivity> activities;

  int get plannedLoad => planned.fold(0, (s, e) => s + (e.plannedLoad ?? 0));
  int get doneLoad => activities.fold(0, (s, a) => s + (a.trainingLoad ?? 0));
  bool get isEmpty => planned.isEmpty && activities.isEmpty;
}

/// The card shown while a day is held (the Today week ribbon): the date,
/// what was planned, what was done, done-versus-planned TSS and — when the
/// day has wearable data — readiness. Everything is capped
/// ([maxRows] per list, "+N more") so it fits a small screen without
/// scrolling.
///
/// Reusable anywhere a day needs a quick look; give it [data] it already
/// holds (instant) or use [DayPeek.load] to read the cache first.
class DayPeek extends StatefulWidget {
  const DayPeek({
    super.key,
    required this.data,
    this.readinessLoader,
    this.showTrend = true,
  });

  /// Reads [day] from the cache, showing the date while it loads.
  static Widget load(DateTime day, {DayPeekSource? source, Key? key}) =>
      _DayPeekLoader(key: key, day: day, source: source ?? DayPeekSource());

  final DayPeekData data;

  /// Starts reading the day's readiness once, when the card appears; it is
  /// shown if and when it arrives and never awaited.
  final Future<Readiness?> Function()? readinessLoader;

  /// Whether completed activities carry their performance-trend arrow.
  final bool showTrend;

  /// Rows per list before "+N more".
  static const maxRows = 3;

  @override
  State<DayPeek> createState() => _DayPeekState();
}

class _DayPeekState extends State<DayPeek> {
  Readiness? _readiness;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  void _listen() {
    widget.readinessLoader?.call().then((r) {
      if (mounted) setState(() => _readiness = r);
    }, onError: (_) {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final data = widget.data;
    final r = _readiness;

    return Column(
      key: ValueKey('day-peek-${isoDate(data.day)}'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                DateFormat.MMMEd(locale).format(data.day),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (r != null) ...[
              const SizedBox(width: 8),
              Container(
                key: const ValueKey('day-peek-readiness'),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: readinessColor(scheme, r.level),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  l10n.dayPeekReadiness(readinessLevelLabel(l10n, r.level)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (data.isEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.hotel_outlined, size: 18, color: scheme.outline),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${l10n.dayPeekEmpty} · ${l10n.dayPeekEmptyHint}',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (data.planned.isNotEmpty) ...[
          _section(theme, l10n.dayPeekPlanned),
          ..._rows(l10n, theme, data.planned.length, (i) {
            final e = data.planned[i];
            final minutes = (e.plannedTime ?? 0) ~/ 60;
            return _Row(
              type: e.type,
              title: e.name ?? e.type ?? l10n.plannedSessionFallback,
              detail: [
                if (minutes > 0) l10n.minutesShort(minutes),
                if (e.plannedLoad != null) '${e.plannedLoad} ${l10n.tssSuffix}',
              ].join(' · '),
            );
          }, key: 'planned'),
        ],
        if (data.activities.isNotEmpty) ...[
          _section(theme, l10n.dayPeekCompleted),
          ..._rows(l10n, theme, data.activities.length, (i) {
            final a = data.activities[i];
            return _Row(
              type: a.type,
              title: a.name ?? a.type ?? l10n.activityFallback,
              detail: [
                if ((a.movingTime ?? 0) > 0) formatDurationSecs(a.movingTime!),
                if (a.trainingLoad != null)
                  '${a.trainingLoad} ${l10n.tssSuffix}',
              ].join(' · '),
              trailing: widget.showTrend
                  ? PerformanceTrendIcon(activity: a)
                  : null,
            );
          }, key: 'done'),
        ],
        if (data.plannedLoad > 0 || data.doneLoad > 0) ...[
          const SizedBox(height: 10),
          _LoadBar(done: data.doneLoad, planned: data.plannedLoad),
        ],
      ],
    );
  }

  Widget _section(ThemeData theme, String text) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 2),
    child: Text(
      text.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        letterSpacing: 1,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  List<Widget> _rows(
    AppLocalizations l10n,
    ThemeData theme,
    int count,
    Widget Function(int) row, {
    required String key,
  }) {
    final shown = count > DayPeek.maxRows ? DayPeek.maxRows : count;
    return [
      for (var i = 0; i < shown; i++) row(i),
      if (count > shown)
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            l10n.dayPeekMore(count - shown),
            key: ValueKey('day-peek-more-$key'),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
    ];
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.type,
    required this.title,
    required this.detail,
    this.trailing,
  });

  final String? type;
  final String title;
  final String detail;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            activityTypeIcon(type),
            size: 20,
            color: sportColor(type, scheme),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (detail.isNotEmpty)
                  Text(
                    detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 6), trailing!],
        ],
      ),
    );
  }
}

/// "85 of 120 TSS" over a thin progress bar; just the figure when nothing
/// was planned.
class _LoadBar extends StatelessWidget {
  const _LoadBar({required this.done, required this.planned});

  final int done;
  final int planned;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final text = planned > 0
        ? l10n.dayPeekLoad(done, planned)
        : l10n.dayPeekLoadDone(done);
    return Column(
      key: const ValueKey('day-peek-load'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (planned > 0) ...[
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              minHeight: 4,
              value: (done / planned).clamp(0.0, 1.0),
            ),
          ),
        ],
      ],
    );
  }
}

class _DayPeekLoader extends StatefulWidget {
  const _DayPeekLoader({super.key, required this.day, required this.source});

  final DateTime day;
  final DayPeekSource source;

  @override
  State<_DayPeekLoader> createState() => _DayPeekLoaderState();
}

class _DayPeekLoaderState extends State<_DayPeekLoader> {
  late final Future<DayPeekData> _data = widget.source.load(widget.day);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DayPeekData>(
      future: _data,
      builder: (context, snapshot) {
        // The date alone until the (local, quick) read lands: the hold is
        // never blocked on it.
        final data = snapshot.data ?? DayPeekData(day: widget.day);
        if (snapshot.data == null) {
          return Text(
            DateFormat.MMMEd(
              Localizations.localeOf(context).toString(),
            ).format(widget.day),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          );
        }
        return DayPeek(
          data: data,
          readinessLoader: () => widget.source.readiness(widget.day),
        );
      },
    );
  }
}
