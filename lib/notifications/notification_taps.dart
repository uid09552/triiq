import 'package:flutter/foundation.dart';

import '../util/dates.dart';

/// A tapped notification's payload, handed from the platform callback to
/// the app's navigator (wired in `main.dart`), same hand-off shape as
/// `ChatHandoff`. The payload says where to go: `weekly_review:<ISO date>`
/// opens the Weekly review on that week.
class NotificationTaps extends ChangeNotifier {
  NotificationTaps._();

  static final NotificationTaps instance = NotificationTaps._();

  @visibleForTesting
  factory NotificationTaps.forTesting() = NotificationTaps._;

  String? _pending;

  void deliver(String? payload) {
    if (payload == null || payload.isEmpty) return;
    _pending = payload;
    notifyListeners();
  }

  /// The waiting payload, once; `null` after it was taken.
  String? take() {
    final p = _pending;
    _pending = null;
    return p;
  }
}

const _weeklyReviewPrefix = 'weekly_review:';

/// The payload that opens the Weekly review on [weekStart]'s week.
String weeklyReviewPayload(DateTime weekStart) =>
    '$_weeklyReviewPrefix${isoDate(weekStart)}';

/// The week a [weeklyReviewPayload] points at, or `null` for any other
/// payload.
DateTime? weeklyReviewWeekOf(String payload) {
  if (!payload.startsWith(_weeklyReviewPrefix)) return null;
  return DateTime.tryParse(payload.substring(_weeklyReviewPrefix.length));
}
