import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../data/models/local_activity.dart';
import '../../data/models/local_event.dart';
import '../../evaluation/readiness.dart';
import '../../evaluation/readiness_service.dart';
import '../../evaluation/session_evaluator.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/peek_cards.dart';
import '../../widgets/peekable.dart';
import '../../season/illness_mode.dart'
    show HealthIssue, HealthKind, HealthPhase;
import '../activities/activity_icons.dart';
import '../calendar/performance_trend_icon.dart';
import 'readiness_card.dart';

/// The one thing the hero card's main button does, chosen from the day.
enum HeroAction {
  /// A session is planned and readiness doesn't object: open its steps.
  start,

  /// Readiness says Caution or Back off and a hard session is planned:
  /// Train now's "Find alternative" for it.
  swapEasier,

  /// Today's sessions are done (or the athlete is sick): fatigue/soreness.
  logFeel,

  /// Nothing planned: Train now proposes one.
  propose,
}

/// Today's planned sessions not yet matched by an activity (same sport,
/// one to one — [matchAll]).
List<LocalEvent> remainingSessions(
  List<LocalEvent> planned,
  List<LocalActivity> activities,
) {
  final done = matchAll(activities, planned).values.toSet();
  return [
    for (final e in planned)
      if (!done.contains(e)) e,
  ];
}

/// The hero's primary action for the day.
HeroAction heroActionFor({
  required List<LocalEvent> remaining,
  required bool doneSomething,
  ReadinessLevel? level,
  bool sick = false,
}) {
  if (sick) return HeroAction.logFeel;
  if (remaining.isNotEmpty) {
    final cautious = level != null && level != ReadinessLevel.ready;
    return cautious && remaining.any(isHardSession)
        ? HeroAction.swapEasier
        : HeroAction.start;
  }
  return doneSomething ? HeroAction.logFeel : HeroAction.propose;
}

String _minutes(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  return h > 0 ? '${h}h ${m.toString().padLeft(2, '0')}m' : '$m min';
}

/// "VO2 intervals · 65 min · 78 TSS".
String describePlanned(AppLocalizations l10n, LocalEvent e) => [
  e.name ?? e.type ?? l10n.plannedSessionFallback,
  if ((e.plannedTime ?? 0) > 0) _minutes(e.plannedTime!),
  if (e.plannedLoad != null) '${e.plannedLoad} ${l10n.tssSuffix}',
].join(' · ');

/// Today on one card: the date, the status (readiness-aware), the readiness
/// ring, today's session(s) — or, once done, how they went — one primary
/// action that fits the day, "Ask the trainer about today", and a strip for
/// tomorrow. Pure: everything comes in from [TodayScreen].
class TodayHeroCard extends StatelessWidget {
  const TodayHeroCard({
    super.key,
    required this.date,
    required this.connected,
    required this.loading,
    required this.readiness,
    required this.todaysPlan,
    required this.activities,
    required this.tomorrowsPlan,
    required this.onRefresh,
    required this.onTrainNow,
    required this.onFeel,
    required this.onCustomize,
    required this.onOpenPlanned,
    required this.onOpenActivity,
    required this.onAskTrainer,
    required this.onOpenTomorrow,
    this.onSwapEasier,
    this.onMoveToTomorrow,
    this.onOpenIntervals,
    this.onExplainReadiness,
    this.nextKeySession,
    this.health,
    this.fatigue,
    this.soreness,
    this.statusChip,
  });

  final DateTime date;
  final bool connected;
  final bool loading;
  final ReadinessReport? readiness;
  final List<LocalEvent> todaysPlan;
  final List<LocalActivity> activities;
  final List<LocalEvent> tomorrowsPlan;

  /// On a day with nothing planned: the next hard session this week.
  final LocalEvent? nextKeySession;

  /// An illness or injury that is still on: the card says so and offers
  /// no training.
  final ({HealthIssue issue, HealthPhase phase})? health;

  /// Today's logged fatigue / soreness (1–4), for the result view.
  final int? fatigue;
  final int? soreness;

  final Widget? statusChip;
  final VoidCallback onRefresh;
  final VoidCallback onTrainNow;
  final ValueChanged<LocalEvent>? onSwapEasier;
  final VoidCallback onFeel;
  final VoidCallback onCustomize;
  final ValueChanged<LocalEvent> onOpenPlanned;

  /// Tap on a completed session in the result view: open its page.
  final ValueChanged<LocalActivity> onOpenActivity;

  /// Null when the session can't be moved (e.g. on a sick day).
  final ValueChanged<LocalEvent>? onMoveToTomorrow;
  final VoidCallback onAskTrainer;
  final VoidCallback onOpenTomorrow;
  final VoidCallback? onOpenIntervals;
  final VoidCallback? onExplainReadiness;

  bool get _sick => health?.phase == HealthPhase.affected;

  List<LocalEvent> get _remaining => remainingSessions(todaysPlan, activities);

  ReadinessLevel? get _level {
    final r = readiness?.readiness;
    if (r == null || r.dataState == ReadinessDataState.noData) return null;
    return r.level;
  }

  HeroAction get action => heroActionFor(
    remaining: _remaining,
    doneSomething: activities.isNotEmpty,
    level: _level,
    sick: _sick,
  );

  /// The day's primary action is to log how it felt, and that is done.
  bool get _feelDone =>
      action == HeroAction.logFeel && (fatigue != null || soreness != null);

  String _title(AppLocalizations l10n) {
    if (_sick) {
      return health!.issue.kind == HealthKind.sick
          ? l10n.healthSickTitle
          : l10n.healthInjuredTitle;
    }
    if (activities.isEmpty) {
      switch (_level) {
        case ReadinessLevel.caution:
          return l10n.heroTitleCaution;
        case ReadinessLevel.backOff:
          return l10n.heroTitleBackOff;
        case ReadinessLevel.ready || null:
          break;
      }
    }
    return l10n.heroActivitiesStatus(activities.length);
  }

  Color? _titleColor(ColorScheme scheme) {
    if (_sick) return scheme.tertiary;
    final level = _level;
    return activities.isEmpty && level != null && level != ReadinessLevel.ready
        ? readinessColor(scheme, level)
        : null;
  }

  /// The line under the title: readiness reasons, or the waiting state.
  String? _readinessLine(AppLocalizations l10n) {
    final r = readiness?.readiness;
    if (r == null || _sick) return null;
    return switch (r.dataState) {
      ReadinessDataState.complete =>
        r.reasons.isEmpty
            ? l10n.readinessAllOk
            : l10n.readinessReasons(
                r.reasons
                    .map((s) => readinessSignalLabel(l10n, s.kind))
                    .join(', '),
              ),
      _ => null,
    };
  }

  String _tomorrowText(AppLocalizations l10n) => tomorrowsPlan.isEmpty
      ? l10n.heroTomorrowRest
      : l10n.heroTomorrow(
          [
            describePlanned(l10n, tomorrowsPlan.first),
            if (tomorrowsPlan.length > 1) '+${tomorrowsPlan.length - 1}',
          ].join(' '),
        );

  String _summary(AppLocalizations l10n) {
    final r = readiness?.readiness;
    final remaining = _remaining;
    return [
      _title(l10n),
      if (r != null && r.dataState == ReadinessDataState.complete && !_sick)
        [
          readinessLevelLabel(l10n, r.level),
          if (readinessScore(r) case final score?)
            l10n.a11yReadinessScore(score),
        ].join(', '),
      if (r?.dataState == ReadinessDataState.waitingForToday)
        l10n.todayWaitingForWatch,
      if (_sick)
        null
      else if (remaining.isNotEmpty)
        l10n.heroA11yToday(
          [for (final e in remaining) describePlanned(l10n, e)].join('; '),
        )
      else if (activities.isEmpty && !_sick)
        l10n.heroA11yToday(l10n.ribbonRest),
      if (!_sick) _tomorrowText(l10n),
    ].whereType<String>().join('. ');
  }

  Future<void> _showActions(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final movable = _remaining.isNotEmpty && onMoveToTomorrow != null;
    final choice = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                key: const ValueKey('hero-action-sync'),
                leading: const Icon(Icons.sync),
                title: Text(l10n.heroSyncNow),
                onTap: () => Navigator.pop(context, 'sync'),
              ),
              ListTile(
                key: const ValueKey('hero-action-train'),
                leading: const Icon(Icons.fitness_center),
                title: Text(l10n.titleTrainNow),
                onTap: () => Navigator.pop(context, 'train'),
              ),
              ListTile(
                key: const ValueKey('hero-action-feel'),
                leading: const Icon(Icons.mood_outlined),
                title: Text(l10n.feelActionLabel),
                onTap: () => Navigator.pop(context, 'feel'),
              ),
              if (movable)
                ListTile(
                  key: const ValueKey('hero-action-move'),
                  leading: const Icon(Icons.redo),
                  title: Text(l10n.heroMoveToTomorrow),
                  onTap: () => Navigator.pop(context, 'move'),
                ),
              if (onOpenIntervals != null)
                ListTile(
                  key: const ValueKey('hero-action-intervals'),
                  leading: const Icon(Icons.open_in_new),
                  title: Text(l10n.openInIntervals),
                  onTap: () => Navigator.pop(context, 'intervals'),
                ),
              ListTile(
                key: const ValueKey('hero-action-customize'),
                leading: const Icon(Icons.tune),
                title: Text(l10n.customizeTodayTitle),
                onTap: () => Navigator.pop(context, 'customize'),
              ),
            ],
          ),
        ),
      ),
    );
    switch (choice) {
      case 'sync':
        onRefresh();
      case 'train':
        onTrainNow();
      case 'feel':
        onFeel();
      case 'move':
        onMoveToTomorrow?.call(_remaining.first);
      case 'intervals':
        onOpenIntervals?.call();
      case 'customize':
        onCustomize();
    }
  }

  void _primary() {
    final remaining = _remaining;
    switch (action) {
      case HeroAction.start:
        onOpenPlanned(remaining.first);
      case HeroAction.swapEasier:
        final hard = remaining.firstWhere(
          isHardSession,
          orElse: () => remaining.first,
        );
        (onSwapEasier ?? (_) => onTrainNow())(hard);
      case HeroAction.logFeel:
        HapticFeedback.lightImpact();
        onFeel();
      case HeroAction.propose:
        onTrainNow();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final remaining = _remaining;
    final readinessLine = _readinessLine(l10n);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final primary = action;
    final (IconData primaryIcon, String primaryLabel) = switch (primary) {
      HeroAction.start => (Icons.play_arrow_rounded, l10n.heroActionStart),
      HeroAction.swapEasier => (Icons.swap_horiz, l10n.heroActionSwap),
      HeroAction.logFeel => (Icons.mood_outlined, l10n.heroActionFeel),
      HeroAction.propose => (Icons.auto_awesome, l10n.proposeTraining),
    };

    final String? restLine;
    if (_sick || remaining.isNotEmpty || activities.isNotEmpty) {
      restLine = null;
    } else if (!connected && todaysPlan.isEmpty) {
      restLine = l10n.connectToSeePlan;
    } else if (nextKeySession case final next?) {
      final day = DateTime.tryParse(next.date);
      restLine = l10n.heroNextKeySession(
        day == null ? next.date : DateFormat.E(locale).format(day),
        next.name ?? next.type ?? l10n.plannedSessionFallback,
      );
    } else {
      restLine = l10n.nothingPlannedToday;
    }

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _DateBadge(date: date, locale: locale),
        const SizedBox(width: 12),
        Expanded(
          child: Semantics(
            container: true,
            label: _summary(l10n),
            excludeSemantics: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.EEEE(locale).format(date).toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  _title(l10n),
                  key: const ValueKey('hero-title'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: _titleColor(scheme),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (readinessLine != null)
                  Text(
                    readinessLine,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
        if (!_sick) _readinessSlot(context, l10n),
      ],
    );

    final body = activities.isNotEmpty && remaining.isEmpty
        ? _ResultView(
            key: const ValueKey('hero-result'),
            activities: activities,
            planned: todaysPlan,
            onOpenActivity: onOpenActivity,
            fatigue: fatigue,
            soreness: soreness,
          )
        : Column(
            key: const ValueKey('hero-plan'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (activities.isNotEmpty)
                _ResultView(
                  activities: activities,
                  planned: todaysPlan,
                  onOpenActivity: onOpenActivity,
                  fatigue: fatigue,
                  soreness: soreness,
                  showFeel: false,
                ),
              if (!_sick)
                for (final e in remaining)
                  _SessionRow(
                    event: e,
                    onOpen: () => onOpenPlanned(e),
                    onFeel: onFeel,
                    onMove: onMoveToTomorrow == null
                        ? null
                        : () => onMoveToTomorrow!(e),
                  ),
              if (restLine != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    restLine,
                    key: const ValueKey('hero-rest'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          );

    return Card(
      key: const ValueKey('today-hero'),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            const SizedBox(height: 6),
            AnimatedSwitcher(
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 250),
              child: body,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                // Once the feel is logged there is nothing left to do for
                // the day: no primary button, only refresh and more.
                if (_feelDone)
                  const Spacer()
                else
                  Expanded(
                    child: FilledButton.icon(
                      key: ValueKey('hero-primary-${primary.name}'),
                      onPressed: _primary,
                      icon: Icon(primaryIcon),
                      label: Text(
                        primaryLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                // 48 dp: the minimum touch target. Doubles as the
                // refresh affordance with a mouse on Windows.
                SizedBox(
                  width: 48,
                  height: 48,
                  child: loading
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        )
                      : IconButton(
                          key: const ValueKey('hero-refresh'),
                          onPressed: onRefresh,
                          tooltip: l10n.refreshTooltip,
                          icon: Icon(Icons.refresh, color: scheme.primary),
                        ),
                ),
                IconButton(
                  key: const ValueKey('hero-more'),
                  onPressed: () => _showActions(context),
                  tooltip: l10n.heroMoreTooltip,
                  icon: Icon(Icons.more_horiz, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ActionChip(
                  key: const ValueKey('hero-ask-trainer'),
                  avatar: const Icon(Icons.chat_bubble_outline, size: 16),
                  label: Text(l10n.heroAskTrainer),
                  visualDensity: VisualDensity.compact,
                  onPressed: onAskTrainer,
                ),
                ?statusChip,
              ],
            ),
            if (!_sick) ...[
              const Divider(height: 8),
              _TomorrowStrip(
                text: _tomorrowText(l10n),
                event: tomorrowsPlan.firstOrNull,
                onTap: onOpenTomorrow,
              ),
            ] else
              const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _readinessSlot(BuildContext context, AppLocalizations l10n) {
    final scheme = Theme.of(context).colorScheme;
    final report = readiness;
    final r = report?.readiness;
    if (r != null && r.dataState == ReadinessDataState.waitingForToday) {
      // An incomplete score would mislead: say the watch data is still on
      // its way, with a way to fetch it.
      return Container(
        key: const ValueKey('readiness-waiting'),
        width: 92,
        padding: const EdgeInsets.fromLTRB(8, 4, 0, 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.watch_outlined, color: scheme.onSurfaceVariant),
            Text(
              l10n.todayWaitingForWatch,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            TextButton(
              key: const ValueKey('readiness-waiting-refresh'),
              onPressed: onRefresh,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
              child: Text(l10n.refreshTooltip),
            ),
          ],
        ),
      );
    }
    final complete = r?.dataState == ReadinessDataState.complete;
    final level = r?.level ?? ReadinessLevel.ready;
    return Semantics(
      button: true,
      hint: l10n.heroExplainReadiness,
      child: InkWell(
        key: const ValueKey('hero-readiness'),
        customBorder: const CircleBorder(),
        onTap: report == null ? null : onExplainReadiness,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: ReadinessScoreRing(
            score: complete ? readinessScore(r!) : null,
            level: level,
            color: readinessColor(scheme, level),
            dim: !complete,
            size: 60,
          ),
        ),
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.date, required this.locale});

  final DateTime date;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ExcludeSemantics(
      child: Container(
        width: 44,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat.MMM(locale).format(date).toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onPrimaryContainer,
                fontSize: 11,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              '${date.day}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One of today's sessions still to do. Tap opens its steps; swipe right
/// logs how it felt, swipe left moves it to tomorrow — both also as screen
/// reader actions and in the ⋯ menu.
class _SessionRow extends StatelessWidget {
  const _SessionRow({
    required this.event,
    required this.onOpen,
    required this.onFeel,
    this.onMove,
  });

  final LocalEvent event;
  final VoidCallback onOpen;
  final VoidCallback onFeel;
  final VoidCallback? onMove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = sportColor(event.type, scheme);
    final details = [
      if (event.type != null) event.type!,
      if (event.indoor) l10n.indoorLabel,
      if ((event.plannedTime ?? 0) > 0) _minutes(event.plannedTime!),
      if (event.plannedLoad != null) '${event.plannedLoad} ${l10n.tssSuffix}',
    ].join(' · ');

    Widget row = InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Row(
          children: [
            // Hold the icon to see the session's details (type, dates, notes);
            // a tap anywhere on the row opens it as before.
            Peekable(
              preview: (_) => EventPeek(event: event),
              child: SizedBox(
                key: ValueKey('hero-icon-${event.id}'),
                width: 40,
                height: 40,
                child: Icon(
                  activityTypeIcon(event.type),
                  color: color,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name ?? event.type ?? l10n.plannedSessionFallback,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (details.isNotEmpty)
                    Text(
                      details,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );

    Widget bg(Color c, IconData icon, String label, Alignment align) =>
        Container(
          color: c,
          alignment: align,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );

    row = Dismissible(
      key: ValueKey('hero-swipe-${event.id}'),
      direction: onMove == null
          ? DismissDirection.startToEnd
          : DismissDirection.horizontal,
      background: bg(
        scheme.primary,
        Icons.mood,
        l10n.heroActionFeel,
        Alignment.centerLeft,
      ),
      secondaryBackground: onMove == null
          ? null
          : bg(
              scheme.secondary,
              Icons.redo,
              l10n.heroMoveToTomorrow,
              Alignment.centerRight,
            ),
      // The row never goes away here: a move re-reads Today (with Undo on
      // the snackbar), the feel dialog leaves it be.
      confirmDismiss: (direction) async {
        HapticFeedback.selectionClick();
        if (direction == DismissDirection.endToStart) {
          onMove?.call();
        } else {
          onFeel();
        }
        return false;
      },
      child: row,
    );

    return Semantics(
      key: ValueKey('hero-session-${event.id}'),
      customSemanticsActions: {
        CustomSemanticsAction(label: l10n.heroActionFeel): onFeel,
        CustomSemanticsAction(label: l10n.heroMoveToTomorrow): ?onMove,
      },
      child: row,
    );
  }
}

/// After the session: what was done against what was planned, the
/// performance-trend arrow, and how it felt.
class _ResultView extends StatelessWidget {
  const _ResultView({
    super.key,
    required this.activities,
    required this.planned,
    required this.onOpenActivity,
    this.fatigue,
    this.soreness,
    this.showFeel = true,
  });

  final ValueChanged<LocalActivity> onOpenActivity;
  final List<LocalActivity> activities;
  final List<LocalEvent> planned;
  final int? fatigue;
  final int? soreness;
  final bool showFeel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final matches = matchAll(activities, planned);

    String actual(LocalActivity a) {
      final p = matches[a.id];
      final secs = a.movingTime ?? 0;
      final load = a.trainingLoad;
      final time = p?.plannedTime != null && p!.plannedTime! > 0
          ? l10n.heroResultOf(_minutes(secs), _minutes(p.plannedTime!))
          : (secs > 0 ? _minutes(secs) : null);
      final tss = load == null
          ? null
          : p?.plannedLoad != null
          ? l10n.heroResultOf('$load', '${p!.plannedLoad} ${l10n.tssSuffix}')
          : '$load ${l10n.tssSuffix}';
      return [?time, ?tss].join(' · ');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final a in activities)
          InkWell(
            key: ValueKey('hero-result-${a.id}'),
            onTap: () => onOpenActivity(a),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  // Hold the icon for the session's key figures; a tap on the
                  // row opens the activity.
                  Peekable(
                    preview: (_) => ActivityPeek(activity: a),
                    child: SizedBox(
                      key: ValueKey('hero-result-icon-${a.id}'),
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.check_circle,
                        color: scheme.primary,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.name ?? a.type ?? l10n.activityFallback,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          actual(a),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PerformanceTrendIcon(activity: a),
                  Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
        if (showFeel)
          Text(
            fatigue == null && soreness == null
                ? l10n.heroFeelNotLogged
                : l10n.heroFeelLogged(
                    fatigue?.toString() ?? '–',
                    soreness?.toString() ?? '–',
                  ),
            key: const ValueKey('hero-feel'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class _TomorrowStrip extends StatelessWidget {
  const _TomorrowStrip({
    required this.text,
    required this.event,
    required this.onTap,
  });

  final String text;
  final LocalEvent? event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      key: const ValueKey('hero-tomorrow'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 40),
        child: Row(
          children: [
            Icon(
              event == null
                  ? Icons.bedtime_outlined
                  : activityTypeIcon(event!.type),
              size: 18,
              color: event == null
                  ? scheme.onSurfaceVariant
                  : sportColor(event!.type, scheme),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
