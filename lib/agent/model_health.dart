import 'package:flutter/foundation.dart';

import 'openai_connection.dart' show LlmFailureKind;
import '../util/clock.dart';

/// How one model entry has been doing in this app run.
@immutable
class ModelStatus {
  const ModelStatus({
    this.consecutiveFailures = 0,
    this.coolingUntil,
    this.lastFailure,
    this.lastFailureAt,
    this.needsAttention = false,
    this.lastUsed,
  });

  final int consecutiveFailures;

  /// Skipped (unless nothing else is left) until then.
  final DateTime? coolingUntil;

  /// Why the last call failed, if the last call failed.
  final LlmFailureKind? lastFailure;
  final DateTime? lastFailureAt;

  /// The entry looks misconfigured (key, model, tools refused).
  final bool needsAttention;

  /// When it last answered.
  final DateTime? lastUsed;

  bool get isOk => lastFailure == null;
}

/// The per-entry circuit breaker: after [failureThreshold] consecutive
/// failover-worthy failures an entry is skipped for [cooldown], so each
/// message does not first wait for a dead server to time out. A success, a
/// "Test" in Settings or a manual retry clears it.
///
/// Kept in memory only: a restart gives every entry a fresh chance.
class ModelHealth extends ChangeNotifier {
  ModelHealth({
    DateTime Function()? clock,
    this.failureThreshold = 2,
    this.cooldown = const Duration(minutes: 5),
  }) : _clock = clock ?? clockNow;

  final DateTime Function() _clock;
  final int failureThreshold;
  final Duration cooldown;

  final _status = <String, ModelStatus>{};

  ModelStatus statusOf(String id) => _status[id] ?? const ModelStatus();

  /// Whether [id] is inside its cooldown right now.
  bool isCoolingDown(String id) {
    final until = _status[id]?.coolingUntil;
    return until != null && _clock().isBefore(until);
  }

  void recordSuccess(String id) {
    _status[id] = ModelStatus(lastUsed: _clock());
    notifyListeners();
  }

  void recordFailure(
    String id,
    LlmFailureKind? kind, {
    bool needsAttention = false,
  }) {
    final now = _clock();
    final before = statusOf(id);
    // A cooldown that has run out starts the count again.
    final count =
        (before.coolingUntil != null && !now.isBefore(before.coolingUntil!))
        ? 1
        : before.consecutiveFailures + 1;
    _status[id] = ModelStatus(
      consecutiveFailures: count,
      coolingUntil: count >= failureThreshold ? now.add(cooldown) : null,
      lastFailure: kind,
      lastFailureAt: now,
      needsAttention: needsAttention,
      lastUsed: before.lastUsed,
    );
    notifyListeners();
  }

  /// Forgets failures and the cooldown (a Test, or a manual retry).
  void clear(String id) {
    final before = _status[id];
    if (before == null) return;
    _status[id] = ModelStatus(lastUsed: before.lastUsed);
    notifyListeners();
  }

  /// Clears every cooldown — the athlete pressed Retry after "all models
  /// failed".
  void clearAll() {
    for (final id in _status.keys.toList()) {
      final before = _status[id]!;
      _status[id] = ModelStatus(lastUsed: before.lastUsed);
    }
    notifyListeners();
  }

  void forget(String id) {
    if (_status.remove(id) != null) notifyListeners();
  }

  void reset() {
    _status.clear();
    notifyListeners();
  }
}
