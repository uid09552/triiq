import 'package:shared_preferences/shared_preferences.dart';

import '../agent/llm_settings.dart';
import 'db/app_database.dart';
import 'intervals_session.dart';
import 'privacy_settings.dart';

/// "Delete all my data" (GDPR Art. 17) for what TriIQ keeps on the device:
/// the local database (activities, wellness, plans, knowledge library,
/// caches, the offline queue), every saved key, and every preference. The
/// Intervals.icu connection is dropped. Data already at Intervals.icu or an
/// AI provider is theirs to delete.
class DataEraser {
  DataEraser({
    AppDatabase? database,
    IntervalsSession? session,
    LlmSettings? llm,
    PrivacySettings? privacy,
  }) : _database = database ?? AppDatabase.instance,
       _session = session ?? IntervalsSession.instance,
       _llm = llm ?? LlmSettings.instance,
       _privacy = privacy ?? PrivacySettings.instance;

  final AppDatabase _database;
  final IntervalsSession _session;
  final LlmSettings _llm;
  final PrivacySettings _privacy;

  /// Erases everything. Each step runs even when an earlier one fails, so a
  /// problem with one store never leaves the others full; the first error is
  /// rethrown at the end.
  Future<void> eraseAll() async {
    Object? first;
    Future<void> step(Future<void> Function() run) async {
      try {
        await run();
      } catch (error) {
        first ??= error;
      }
    }

    // Keys first: nothing may keep talking to an account once it is erased.
    await step(_session.disconnect);
    await step(() => _llm.setClaudeApiKey(''));
    await step(() => _llm.setOllamaApiKey(''));
    await step(() async => await _database.eraseAll());
    await step(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });
    _privacy.resetInMemory();

    final error = first;
    if (error != null) throw error;
  }
}
