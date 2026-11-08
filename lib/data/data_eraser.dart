import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../agent/llm_settings.dart';
import '../evaluation/readiness_settings.dart';
import '../locale_controller.dart';
import '../notifications/notification_service.dart';
import '../notifications/notification_settings.dart';
import '../plan/plan_changes.dart';
import '../screens/settings/weekly_targets_settings.dart';
import '../screens/settings/year_goals_settings.dart';
import '../screens/today/today_layout_settings.dart';
import '../theme_controller.dart';
import 'backup/backup_files.dart';
import 'db/app_database.dart';
import 'feel_settings.dart';
import 'home_widget_data.dart';
import 'intervals_session.dart';
import 'pending_writes.dart';
import 'privacy_settings.dart';
import 'sync/auto_sync_service.dart';
import 'sync/sync_settings.dart';

/// "Delete all my data" (GDPR Art. 17) for what TriIQ keeps on the device:
///
/// * the local database — every table emptied, then the file rebuilt
///   (`VACUUM`) so the rows can't be recovered from free pages or the WAL;
/// * every saved key and every preference;
/// * scheduled notifications (the morning briefing carries a copy of the
///   athlete's data);
/// * the Android home widget, which keeps its own copy;
/// * backup files TriIQ wrote to the temporary folder for sharing.
///
/// Afterwards every in-memory setting is reset and the screens are told to
/// reload, so the app is in a fresh-install state without a restart. The
/// Intervals.icu connection is dropped. Data already at Intervals.icu or an
/// AI provider is theirs to delete.
class DataEraser {
  DataEraser({
    AppDatabase? database,
    IntervalsSession? session,
    LlmSettings? llm,
    PrivacySettings? privacy,
    NotificationService? notifications,
    Future<void> Function()? clearHomeWidget,
    Future<Directory?> Function()? tempDirectory,
    List<Future<void> Function()>? reloaders,
  }) : _database = database ?? AppDatabase.instance,
       _session = session ?? IntervalsSession.instance,
       _llm = llm ?? LlmSettings.instance,
       _privacy = privacy ?? PrivacySettings.instance,
       _notifications = notifications ?? NotificationService.instance,
       _clearHomeWidget = clearHomeWidget ?? _refreshHomeWidget,
       _tempDirectory = tempDirectory ?? _systemTemp,
       _reloaders = reloaders ?? _defaultReloaders;

  final AppDatabase _database;
  final IntervalsSession _session;
  final LlmSettings _llm;
  final PrivacySettings _privacy;
  final NotificationService _notifications;
  final Future<void> Function() _clearHomeWidget;
  final Future<Directory?> Function() _tempDirectory;
  final List<Future<void> Function()> _reloaders;

  /// Erases everything. Each step runs even when an earlier one fails, so a
  /// problem with one store never leaves the others full; the first error is
  /// rethrown at the end.
  Future<void> eraseAll() async {
    Object? first;
    Future<void> step(Future<void> Function() run) async {
      try {
        await run();
      } catch (error) {
        debugPrint('DataEraser: $error');
        first ??= error;
      }
    }

    // Keys first: nothing may keep talking to an account once it is erased.
    await step(_session.disconnect);
    await step(() => _llm.setClaudeApiKey(''));
    await step(() => _llm.setOllamaApiKey(''));
    await step(_notifications.cancelBriefing);
    await step(_notifications.cancelDailyReminder);
    await step(() async => await _database.eraseAll());
    await step(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });
    await step(_deleteBackupCopies);
    // From the now-empty database: the widget shows nothing.
    await step(_clearHomeWidget);

    // Fresh-install state in memory too, so nothing stale is shown or
    // written back to the cleared preferences.
    _llm.resetInMemory();
    _privacy.resetInMemory();
    for (final reload in _reloaders) {
      await step(reload);
    }

    final error = first;
    if (error != null) throw error;
  }

  /// Backups written to the temporary folder for the share sheet.
  Future<void> _deleteBackupCopies() async {
    final dir = await _tempDirectory();
    if (dir == null || !await dir.exists()) return;
    await for (final entry in dir.list()) {
      final name = entry.uri.pathSegments.isEmpty
          ? ''
          : entry.uri.pathSegments.last;
      if (entry is File && BackupFiles.isBackupName(name)) await entry.delete();
    }
  }

  static Future<void> _refreshHomeWidget() => HomeWidgetUpdater().update();

  static Future<Directory?> _systemTemp() async {
    if (kIsWeb) return null;
    return getTemporaryDirectory();
  }

  static final List<Future<void> Function()> _defaultReloaders = [
    () => PendingWritesService.instance.refresh(),
    () => SyncSettings.instance.load(),
    () => LocaleController.instance.load(),
    () => ThemeController.instance.load(),
    () => WeeklyTargetsSettings.instance.load(),
    () => YearGoalsSettings.instance.load(),
    () => TodayLayoutSettings.instance.load(),
    () => ReadinessSettings.instance.load(),
    () => FeelSettings.instance.load(),
    () => NotificationSettings.instance.load(),
    () => PrivacySettings.instance.load(),
    () async {
      AutoSyncService.instance.notifyCacheChanged();
      PlanChanges.instance.notify();
    },
  ];
}
