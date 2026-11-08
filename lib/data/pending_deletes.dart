import 'package:flutter/foundation.dart';

/// Planned entries the athlete has just deleted, still inside the undo window.
///
/// A delete is not carried out the moment it is tapped: the entry is hidden
/// here, so every calendar list stops showing it at once, and the real delete
/// (Intervals.icu, the cache, the plan) runs only when the undo snackbar goes
/// away. Undo simply unhides it. Nothing is written until then, so quitting
/// the app inside the window leaves the entry exactly as it was.
class PendingDeletes extends ChangeNotifier {
  PendingDeletes._();

  static final PendingDeletes instance = PendingDeletes._();

  @visibleForTesting
  factory PendingDeletes.forTesting() = PendingDeletes._;

  final Set<String> _hidden = {};

  /// Whether the planned entry with this id (an Intervals.icu event id, or
  /// `plan:<session>` for a TriIQ plan session) is hidden awaiting its delete.
  bool isHidden(String id) => _hidden.contains(id);

  bool get isEmpty => _hidden.isEmpty;

  void hide(String id) {
    if (_hidden.add(id)) notifyListeners();
  }

  /// Shows [id] again: the athlete undid the delete, or the delete failed.
  void restore(String id) {
    if (_hidden.remove(id)) notifyListeners();
  }
}
