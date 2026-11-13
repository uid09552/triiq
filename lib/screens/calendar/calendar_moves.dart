import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../data/models/local_event.dart';
import '../../evaluation/session_evaluator.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/plan_actions.dart';
import '../../util/dates.dart';
import '../activities/planned_workout_actions.dart';
import '../plan/plan_labels.dart';
import '../today/readiness_card.dart' show isHardSession;

/// Moves planned sessions for the calendar's drag-and-drop and "Move to…".
/// The app uses [PlanActions.movePlanned] (plan rules, offline queue);
/// tests override [move].
class CalendarMover {
  CalendarMover({PlanActions? actions, DateTime Function()? clock})
    : _actions = actions,
      _clock = clock ?? DateTime.now;

  final PlanActions? _actions;
  final DateTime Function() _clock;

  DateTime get today => dateOnly(_clock());

  /// Why [event] can't be moved, in words, or `null` when it can: only
  /// workouts (races are fixed), not in the past, and an Intervals.icu event
  /// only once it has a real id there.
  String? whyNot(AppLocalizations l10n, LocalEvent event) {
    if (event.category != 'WORKOUT') return l10n.calMoveNotWorkout;
    final day = DateTime.tryParse(event.date);
    if (day == null || day.isBefore(today)) return l10n.planChangePast;
    if (!event.isPlanSession && int.tryParse(event.id) == null) {
      return l10n.calMoveNotSynced;
    }
    return null;
  }

  Future<void> move(LocalEvent event, DateTime target) =>
      (_actions ?? PlanActions()).movePlanned(event, target);
}

/// What a move would break of the plan's placement rules (the same ones
/// plan adaptation reschedules by). The move still goes ahead — these only
/// warn.
enum MoveWarning {
  /// A hard session next to (or on the same day as) another hard one.
  hardBackToBack,

  /// A hard session the day after strength.
  hardAfterStrength,

  /// Strength the day before a hard session.
  strengthBeforeHard,
}

bool _isStrength(LocalEvent e) =>
    e.planSessionSlot == 'strength' || isStrengthType(e.type);

bool _isHard(LocalEvent e) =>
    e.category == 'WORKOUT' && !_isStrength(e) && isHardSession(e);

/// The rule warnings for moving [moved] to [target], against the other
/// sessions in [eventsByDate].
List<MoveWarning> moveWarnings(
  LocalEvent moved,
  DateTime target,
  Map<String, List<LocalEvent>> eventsByDate,
) {
  List<LocalEvent> on(int offset) => [
    for (final e
        in eventsByDate[isoDate(
              DateTime(target.year, target.month, target.day + offset),
            )] ??
            const <LocalEvent>[])
      if (e.id != moved.id && e.isTraining) e,
  ];
  final before = on(-1);
  final same = on(0);
  final after = on(1);
  final out = <MoveWarning>[];
  if (_isHard(moved)) {
    if ([...before, ...same, ...after].any(_isHard)) {
      out.add(MoveWarning.hardBackToBack);
    }
    if (before.any(_isStrength)) out.add(MoveWarning.hardAfterStrength);
  } else if (_isStrength(moved)) {
    if (after.any(_isHard)) out.add(MoveWarning.strengthBeforeHard);
  }
  return out;
}

String moveWarningLabel(AppLocalizations l10n, MoveWarning w) => switch (w) {
  MoveWarning.hardBackToBack => l10n.calWarnHardBackToBack,
  MoveWarning.hardAfterStrength => l10n.calWarnHardAfterStrength,
  MoveWarning.strengthBeforeHard => l10n.calWarnStrengthBeforeHard,
};

/// Explains on a snackbar why [event] can't be dragged; true when it can.
bool checkMovable(BuildContext context, CalendarMover mover, LocalEvent event) {
  final why = mover.whyNot(AppLocalizations.of(context)!, event);
  if (why == null) return true;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(why)));
  return false;
}

/// Moves [event] to [target] and offers Undo, which moves it back. Rule
/// conflicts ([moveWarnings]) are named on the snackbar, not enforced.
Future<void> moveWithUndo(
  BuildContext context,
  CalendarMover mover,
  LocalEvent event,
  DateTime target, {
  Map<String, List<LocalEvent>> eventsByDate = const {},
}) async {
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  final locale = Localizations.localeOf(context).toString();
  final day = dateOnly(target);
  final from = DateTime.tryParse(event.date);
  if (from == null || dateOnly(from) == day) return;
  final why = mover.whyNot(l10n, event);
  if (why != null) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(why)));
    return;
  }
  if (day.isBefore(mover.today)) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.planChangePast)));
    return;
  }
  final warnings = moveWarnings(event, day, eventsByDate);
  final name = plannedWorkoutTitle(l10n, event);
  try {
    await mover.move(event, day);
  } catch (error) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            error is ReplaceRefusedException
                ? refusalLabel(l10n, error)
                : l10n.calMoveFailed('$error'),
          ),
        ),
      );
    return;
  }
  HapticFeedback.selectionClick();
  final dayLabel = DateFormat.MMMEd(locale).format(day);
  final text = warnings.isEmpty
      ? l10n.calMoved(name, dayLabel)
      : l10n.calMovedWarning(
          name,
          dayLabel,
          warnings.map((w) => moveWarningLabel(l10n, w)).join(', '),
        );
  final moved = _redated(event, day);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(text),
        duration: Duration(seconds: warnings.isEmpty ? 6 : 10),
        persist: false,
        action: SnackBarAction(
          label: l10n.undoButton,
          onPressed: () async {
            try {
              await mover.move(moved, dateOnly(from));
            } catch (error) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    error is ReplaceRefusedException
                        ? refusalLabel(l10n, error)
                        : l10n.calMoveFailed('$error'),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
}

/// "Move to…" without a gesture: a date picker from today on.
Future<void> pickAndMove(
  BuildContext context,
  CalendarMover mover,
  LocalEvent event, {
  Map<String, List<LocalEvent>> eventsByDate = const {},
}) async {
  if (!checkMovable(context, mover, event)) return;
  final today = mover.today;
  final current = DateTime.tryParse(event.date) ?? today;
  final picked = await showDatePicker(
    context: context,
    initialDate: current.isBefore(today) ? today : current,
    firstDate: today,
    lastDate: DateTime(today.year + 1, today.month, today.day),
    helpText: AppLocalizations.of(context)!.calMoveTo,
  );
  if (picked == null || !context.mounted) return;
  await moveWithUndo(context, mover, event, picked, eventsByDate: eventsByDate);
}

LocalEvent _redated(LocalEvent e, DateTime day) => LocalEvent(
  id: e.id,
  date: isoDate(day),
  category: e.category,
  type: e.type,
  name: e.name,
  description: e.description,
  plannedLoad: e.plannedLoad,
  plannedTime: e.plannedTime,
  plannedDistance: e.plannedDistance,
  indoor: e.indoor,
  raw: e.raw,
  syncedAt: e.syncedAt,
);
