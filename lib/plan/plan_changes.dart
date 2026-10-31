import 'package:flutter/foundation.dart';

/// Pinged whenever the saved plan changes — taken, removed, sent to
/// Intervals.icu, a session's status updated — so the Calendar, Today,
/// Statistics and Plan screens reload, the same way they follow
/// `AutoSyncService` for synced data.
class PlanChanges extends ChangeNotifier {
  PlanChanges._();

  static final PlanChanges instance = PlanChanges._();

  void notify() => notifyListeners();
}
