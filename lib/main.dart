import 'dart:async';

import 'package:flutter/material.dart';

import 'agent/llm_settings.dart';
import 'app.dart';
import 'data/feel_settings.dart';
import 'data/home_widget_data.dart';
import 'data/intervals_session.dart';
import 'data/pending_writes.dart';
import 'data/sync/auto_sync_service.dart';
import 'data/sync/background_sync.dart';
import 'data/sync/sync_settings.dart';
import 'locale_controller.dart';
import 'plan/plan_changes.dart';
import 'notifications/app_lifecycle_tracker.dart';
import 'notifications/notification_service.dart';
import 'notifications/notification_settings.dart';
import 'screens/settings/weekly_targets_settings.dart';
import 'screens/settings/year_goals_settings.dart';
import 'screens/today/today_layout_settings.dart';
import 'theme_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppLifecycleTracker.instance.start();
  // Fire-and-forget: re-validates a saved API key (if any) in the
  // background so the UI isn't blocked on startup. IntervalsSession is a
  // ChangeNotifier, so screens update reactively once it resolves.
  unawaited(IntervalsSession.instance.restore());
  // Same idea for the LLM provider choice and Claude key: Settings and the
  // Chat screen listen to LlmSettings and rebuild once it resolves.
  unawaited(LlmSettings.instance.load());
  // Auto-sync the current month while the app is open, throttled to the
  // user's configured interval (default 5 minutes) — see AutoSyncService.
  // Then make the nightly background sync match the saved on/off choice
  // (Android only; a no-op elsewhere).
  unawaited(
    SyncSettings.instance.load().then((_) => BackgroundSync.instance.apply()),
  );
  AutoSyncService.instance.start();
  unawaited(PendingWritesService.instance.refresh());
  _keepHomeWidgetFresh();
  // The chosen app language (System/English/German) — TriiqApp listens and
  // rebuilds once it resolves.
  unawaited(LocaleController.instance.load());
  // The chosen theme (System/Light/Dark/Developer).
  unawaited(ThemeController.instance.load());
  // The per-sport weekly targets and whether their rings show on Today —
  // Settings and Today listen and rebuild once it resolves.
  unawaited(WeeklyTargetsSettings.instance.load());
  unawaited(YearGoalsSettings.instance.load());
  unawaited(TodayLayoutSettings.instance.load());
  // Whether a recent activity's detail screen auto-prompts for fatigue and
  // soreness — Settings and the activity detail screen listen and rebuild
  // once it resolves.
  unawaited(FeelSettings.instance.load());
  // Notifications: set up the platform backend, then load whether the user
  // has opted in and re-arm the daily reminder if so. The permission prompt
  // itself is a deliberate action from Settings, not fired here.
  unawaited(
    NotificationService.instance.init().then((_) async {
      await NotificationSettings.instance.load();
      final settings = NotificationSettings.instance;
      if (settings.enabled && settings.dailyReminderEnabled) {
        await NotificationService.instance.scheduleDailyReminder(
          settings.dailyReminderTime,
        );
      }
    }),
  );
  runApp(const TriiqApp());
}

/// Refreshes the Android home-screen widget at start and whenever fresh data
/// or a plan change lands in the cache.
void _keepHomeWidgetFresh() {
  if (!HomeWidgetUpdater.supported) return;
  final updater = HomeWidgetUpdater();
  Timer? pending;
  void schedule() {
    pending?.cancel();
    pending = Timer(const Duration(seconds: 2), () => unawaited(updater.update()));
  }

  AutoSyncService.instance.addListener(schedule);
  PlanChanges.instance.addListener(schedule);
  schedule();
}
