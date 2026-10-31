import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/models/local_activity.dart';
import '../../data/models/local_event.dart';
import '../../data/planned_items.dart';
import '../../evaluation/new_training.dart';
import '../../notifications/notification_settings.dart';
import '../activities/activity_detail_screen.dart';
import '../today/train_now_screen.dart';
import 'insights_card.dart';
import 'new_training_sheet.dart';

/// Shows [NewTrainingSheet] when [openSyncDone] fires — after the today-sync
/// that opening or resuming the app runs — if today has unseen sessions,
/// the pop-up is on, no sheet is already up and [child]'s route is the
/// visible one (never over a pushed screen or a dialog). Closing the sheet
/// marks every session it showed as seen.
class NewTrainingTrigger extends StatefulWidget {
  const NewTrainingTrigger({
    super.key,
    required this.openSyncDone,
    required this.child,
    this.insights,
    this.enabled,
    this.plannedItems,
    this.sessionInsights,
  });

  final Stream<void> openSyncDone;
  final Widget child;

  /// Test seams; the app uses the defaults.
  final NewTrainingInsights? insights;
  final bool Function()? enabled;
  final PlannedItemsRepository? plannedItems;
  final SessionInsightsLoader? sessionInsights;

  @override
  State<NewTrainingTrigger> createState() => _NewTrainingTriggerState();
}

class _NewTrainingTriggerState extends State<NewTrainingTrigger> {
  late final _insights = widget.insights ?? NewTrainingInsights();
  StreamSubscription<void>? _sub;
  bool _showing = false;

  bool get _enabled =>
      (widget.enabled ?? () => NotificationSettings.instance.insightsPopupEnabled)();

  @override
  void initState() {
    super.initState();
    _sub = widget.openSyncDone.listen((_) => _maybeShow());
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _maybeShow() async {
    if (_showing || !mounted || !_enabled) return;
    if (ModalRoute.of(context)?.isCurrent == false) return;
    _showing = true;
    try {
      final sessions = await _insights.unseenToday();
      if (sessions.isEmpty || !mounted) return;
      if (ModalRoute.of(context)?.isCurrent == false) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheet) => NewTrainingSheet(
          sessions: sessions,
          plannedItems: widget.plannedItems,
          insights: widget.sessionInsights,
          onDetails: (a) => _open(sheet, a),
          onFindAlternative: (e) => _alternative(sheet, e),
        ),
      );
      await _insights.seen.markSeen([for (final s in sessions) s.id]);
    } finally {
      _showing = false;
    }
  }

  void _open(BuildContext sheet, LocalActivity a) {
    Navigator.of(sheet).pop();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ActivityDetailScreen(activity: a)),
    );
  }

  void _alternative(BuildContext sheet, LocalEvent tomorrowSession) {
    Navigator.of(sheet).pop();
    final day = DateTime.tryParse(tomorrowSession.date);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrainNowScreen(today: day == null ? null : () => day),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
