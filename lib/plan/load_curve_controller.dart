import 'package:flutter/foundation.dart';

import 'load_curve.dart';
import 'plan_models.dart';

/// The state behind the load graph: the proposal, the athlete's per-week
/// factors, the selected week and an undo stack. The editor widget is
/// stateless over it, and every derived number (targets, phases, warnings)
/// comes from the same pure functions the plan engine uses.
class LoadCurveController extends ChangeNotifier {
  LoadCurveController({
    required CurveLimits limits,
    required int weeks,
    List<double> factors = const [],
  }) : _limits = limits,
       _proposal = proposeCurve(limits, weeks),
       _factors = _fit(factors, weeks);

  CurveLimits _limits;
  LoadProposal _proposal;
  List<double> _factors;
  int? _selected;
  final List<List<double>> _undo = [];

  /// Taken at the start of a drag; pushed to [_undo] only if it changed.
  List<double>? _pending;

  CurveLimits get limits => _limits;
  int get weeks => _factors.length;
  List<double> get proposal => _proposal.loads;
  List<WeekLimit> get proposalLimits => _proposal.limits;
  List<double> get factors => List.unmodifiable(_factors);
  int? get selected => _selected;
  bool get canUndo => _undo.isNotEmpty;
  bool get isDefault => _factors.every((f) => f == 1.0);

  List<double> get targets => [
    for (var i = 0; i < weeks; i++) _proposal.loads[i] * _factors[i],
  ];
  List<String> get phases => phasesFor(_limits, targets);
  List<Set<WeekLimit>> get flags =>
      flagWeeks(_limits, targets, proposal: _proposal.loads);

  /// Change of week [index]'s target against the week before (or the
  /// baseline for the first week), as a fraction.
  double deltaFor(int index) {
    final t = targets;
    final previous = index == 0 ? _limits.baseline : t[index - 1];
    return previous <= 0 ? 0 : t[index] / previous - 1;
  }

  /// New limits or length, e.g. after a sync or a goal edit. Factors keep
  /// their percentages; absolute loads follow the new proposal.
  void update({required CurveLimits limits, required int weeks}) {
    _limits = limits;
    _proposal = proposeCurve(limits, weeks);
    _factors = _fit(_factors, weeks);
    if (_selected != null && _selected! >= weeks) _selected = null;
    notifyListeners();
  }

  void select(int? index) {
    if (_selected == index) return;
    _selected = index;
    notifyListeners();
  }

  /// Starts a drag on [index]: selects it and remembers the state to undo to.
  void beginDrag(int index) {
    _pending = List.of(_factors);
    _selected = index;
    notifyListeners();
  }

  /// Sets [index] to [factor], snapped to the 5% grid. Returns whether the
  /// snapped value changed — the editor ticks a haptic on `true`.
  bool drag(int index, double factor) {
    final snapped = snapFactor(factor);
    if (_factors[index] == snapped) return false;
    _factors[index] = snapped;
    notifyListeners();
    return true;
  }

  void endDrag() {
    final before = _pending;
    _pending = null;
    if (before != null && !listEquals(before, _factors)) _undo.add(before);
  }

  /// Moves [index] by [steps] 5% steps (buttons, arrow keys, screen reader).
  bool step(int index, int steps) {
    final snapped = snapFactor(_factors[index] + steps * Goal.factorStep);
    if (_factors[index] == snapped) return false;
    _undo.add(List.of(_factors));
    _factors[index] = snapped;
    _selected = index;
    notifyListeners();
    return true;
  }

  void undo() {
    if (_undo.isEmpty) return;
    _factors = _fit(_undo.removeLast(), weeks);
    notifyListeners();
  }

  void reset() {
    if (isDefault) return;
    _undo.add(List.of(_factors));
    _factors = List.filled(weeks, 1.0);
    notifyListeners();
  }

  static List<double> _fit(List<double> factors, int weeks) => [
    for (var i = 0; i < weeks; i++)
      i < factors.length ? snapFactor(factors[i]) : 1.0,
  ];
}
