import '../data/models/local_wellness.dart';
import '../data/repositories/wellness_repository.dart';
import '../plan/knowledge.dart';
import '../util/dates.dart';
import 'readiness.dart';
import 'readiness_settings.dart';

/// Today's readiness and the records behind it, for the detail screen's
/// trend.
class ReadinessReport {
  const ReadinessReport(this.readiness, this.records);

  final Readiness readiness;

  /// The window [readiness] was rated from, oldest first.
  final List<LocalWellness> records;
}

/// Reads the wellness window from the cache and the thresholds from the
/// knowledge, then rates it with [evaluateReadiness] over the signals the
/// athlete left on ([ReadinessSettings]). The Today tile, the
/// detail screen and the agent tool all go through here, so they agree.
class ReadinessService {
  ReadinessService({
    WellnessRepository? wellness,
    KnowledgeRepository? knowledge,
    DateTime Function()? clock,
    ReadinessSettings? settings,
  }) : _settings = settings ?? ReadinessSettings.instance,
       _wellness = wellness ?? WellnessRepository(),
       _knowledge = knowledge ?? KnowledgeRepository(),
       _clock = clock ?? DateTime.now;

  final WellnessRepository _wellness;
  final KnowledgeRepository _knowledge;
  final DateTime Function() _clock;
  final ReadinessSettings _settings;

  Future<ReadinessRules> _rules() async {
    await _settings.ensureLoaded();
    var rules = (await _knowledge.load()).rules.readiness;
    final smoothing = _settings.smoothingDays;
    if (smoothing != null) rules = rules.copyWith(smoothingDays: smoothing);
    return rules;
  }

  /// Readiness for each day [from]..[to] (inclusive), by the same rules
  /// and switched-on signals as [load] — the weekly review counts ready /
  /// caution / back-off days from this.
  Future<List<Readiness>> loadDays(DateTime from, DateTime to) async {
    final rules = await _rules();
    final first = dateOnly(from);
    final last = dateOnly(to);
    final records = await _wellness.getRange(
      isoDate(DateTime(first.year, first.month, first.day - rules.historyDays)),
      isoDate(last),
    );
    return [
      for (
        var d = first;
        !d.isAfter(last);
        d = DateTime(d.year, d.month, d.day + 1)
      )
        evaluateReadiness(records, d, rules: rules, enabled: _settings.enabled),
    ];
  }

  Future<ReadinessReport> load() async {
    final rules = await _rules();
    final today = dateOnly(_clock());
    final records = await _wellness.getRange(
      isoDate(DateTime(today.year, today.month, today.day - rules.historyDays)),
      isoDate(today),
    );
    return ReadinessReport(
      evaluateReadiness(
        records,
        today,
        rules: rules,
        enabled: _settings.enabled,
      ),
      records,
    );
  }
}
