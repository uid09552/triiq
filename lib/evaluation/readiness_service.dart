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

  Future<ReadinessReport> load() async {
    await _settings.ensureLoaded();
    final today = dateOnly(_clock());
    final rules = (await _knowledge.load()).rules.readiness;
    final records = await _wellness.getRange(
      isoDate(
        DateTime(today.year, today.month, today.day - rules.baselineDays),
      ),
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
