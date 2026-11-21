import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../agent/llm_settings.dart';
import '../../data/sync/background_sync.dart';
import '../../data/sync/background_sync_runner.dart';
import '../../data/sync/sync_settings.dart';
import '../../l10n/app_localizations.dart';
import '../../locale_controller.dart';
import '../../notifications/notification_service.dart';
import '../../notifications/notification_settings.dart';
import '../../theme_controller.dart';
import '../../widgets/section_card.dart';
import '../more/customize_navigation_sheet.dart';
import 'backup_settings_section.dart';
import 'calendar_settings_section.dart';
import 'ai_consent.dart';
import 'feel_settings_section.dart';
import 'llm_models_section.dart';
import 'privacy_screen.dart';
import 'settings_hub.dart';
import 'home_widget_section.dart';
import 'usage_section.dart';
import 'weekly_targets_section.dart';
import 'year_goals_section.dart';

export 'settings_hub.dart';

/// One group of settings (Training, AI trainer, Data & privacy, App), opened
/// from the [SettingsScreen] hub or a search result there.
///
/// Intervals.icu connection lives on the Profile screen (it's a login, not
/// a setting). The AI trainer's models are persisted by [LlmSettings] —
/// their keys to the OS credential vault, the rest to shared preferences.
class SettingsGroupScreen extends StatefulWidget {
  const SettingsGroupScreen({super.key, required this.group, this.focus});

  final SettingsGroup group;

  /// Scrolled into view on arrival (a search result).
  final SettingsSection? focus;

  @override
  State<SettingsGroupScreen> createState() => _SettingsGroupScreenState();
}

class _SettingsGroupScreenState extends State<SettingsGroupScreen> {
  final _settings = LlmSettings.instance;
  final _keys = {for (final s in SettingsSection.values) s: GlobalKey()};

  @override
  void initState() {
    super.initState();
    if (widget.focus case final focus?) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final target = _keys[focus]!.currentContext;
        if (target != null && target.mounted) {
          Scrollable.ensureVisible(
            target,
            duration: const Duration(milliseconds: 250),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(widget.group.title(l10n))),
      body: ListenableBuilder(
        listenable: _settings,
        builder: (context, _) {
          final cards = <SettingsSection, Widget>{
            SettingsSection.appearance: SectionCard(
              icon: Icons.brightness_6_outlined,
              title: l10n.appearanceTitle,
              child: ListenableBuilder(
                listenable: ThemeController.instance,
                builder: (context, _) => SegmentedButton<AppThemeChoice>(
                  segments: [
                    ButtonSegment(
                      value: AppThemeChoice.system,
                      label: Text(l10n.appearanceSystem),
                      icon: const Icon(Icons.brightness_auto_outlined),
                    ),
                    ButtonSegment(
                      value: AppThemeChoice.light,
                      label: Text(l10n.appearanceLight),
                      icon: const Icon(Icons.light_mode_outlined),
                    ),
                    ButtonSegment(
                      value: AppThemeChoice.dark,
                      label: Text(l10n.appearanceDark),
                      icon: const Icon(Icons.dark_mode_outlined),
                    ),
                    ButtonSegment(
                      value: AppThemeChoice.developer,
                      label: Text(l10n.appearanceDeveloper),
                      icon: const Icon(Icons.terminal),
                    ),
                  ],
                  selected: {ThemeController.instance.choice},
                  onSelectionChanged: (selection) =>
                      ThemeController.instance.setChoice(selection.first),
                ),
              ),
            ),
            SettingsSection.language: SectionCard(
              icon: Icons.language_outlined,
              title: l10n.languageTitle,
              child: const _LanguageSection(),
            ),
            SettingsSection.notifications: SectionCard(
              icon: Icons.notifications_outlined,
              title: l10n.notificationsTitle,
              child: const _NotificationsSection(),
            ),
            SettingsSection.sync: SectionCard(
              icon: Icons.sync_outlined,
              title: l10n.syncSectionTitle,
              child: const _AutoSyncSection(),
            ),
            SettingsSection.calendar: SectionCard(
              icon: Icons.calendar_month_outlined,
              title: l10n.calendarSettingsTitle,
              child: CalendarSettingsSection(),
            ),
            SettingsSection.backup: SectionCard(
              icon: Icons.backup_outlined,
              title: l10n.backupTitle,
              child: const BackupSettingsSection(),
            ),
            SettingsSection.feel: SectionCard(
              icon: Icons.mood_outlined,
              title: l10n.feelSettingsTitle,
              child: FeelSettingsSection(),
            ),
            SettingsSection.weeklyTargets: SectionCard(
              icon: Icons.track_changes_outlined,
              title: l10n.weeklyTargetsSectionTitle,
              child: WeeklyTargetsSection(),
            ),
            SettingsSection.homeWidget: SectionCard(
              icon: Icons.widgets_outlined,
              title: l10n.homeWidgetTitle,
              child: HomeWidgetSection(),
            ),
            SettingsSection.yearGoals: SectionCard(
              icon: Icons.flag_outlined,
              title: l10n.yearGoalsTitle,
              child: YearGoalsSection(),
            ),
            SettingsSection.privacy: Card(
              child: ListTile(
                key: const ValueKey('settings-privacy'),
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(l10n.pvTitle),
                subtitle: Text(l10n.pvSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PrivacyScreen(),
                  ),
                ),
              ),
            ),
            SettingsSection.ai: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Goes away the moment the athlete agrees.
                ListenableBuilder(
                  listenable: _settings,
                  builder: (context, _) => _settings.needsConsent
                      ? const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: AiConsentCard(),
                        )
                      : const SizedBox.shrink(),
                ),
                SectionCard(
                  icon: Icons.auto_awesome_outlined,
                  title: l10n.llmProviderTitle,
                  child: const LlmModelsSection(),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  icon: Icons.data_usage_outlined,
                  title: l10n.usageTitle,
                  child: UsageSection(),
                ),
              ],
            ),
            SettingsSection.navigation: SectionCard(
              icon: Icons.swap_vert,
              title: l10n.navigationSettingsTitle,
              child: const NavigationSettingsTile(),
            ),
          };
          final sections = widget.group.sections;
          // Built in full (a group is a few cards), so a search result's
          // section exists to scroll to.
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < sections.length; i++) ...[
                  if (i > 0) const SizedBox(height: 16),
                  KeyedSubtree(
                    key: _keys[sections[i]],
                    child: cards[sections[i]]!,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Notification opt-in and the daily-reminder schedule. Split out of
/// [SettingsScreen] mainly so its own `ListenableBuilder` doesn't force the
/// whole Settings screen (LLM fields included) to rebuild on every toggle.
class _NotificationsSection extends StatelessWidget {
  const _NotificationsSection();

  static final _service = NotificationService.instance;
  static final _settings = NotificationSettings.instance;

  Future<void> _setEnabled(BuildContext context, bool value) async {
    if (value) {
      final granted = await _service.requestPermission();
      if (!granted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.notificationPermissionDenied,
              ),
            ),
          );
        }
        return;
      }
      await _settings.setEnabled(true);
      if (_settings.dailyReminderEnabled) {
        await _service.scheduleDailyReminder(_settings.dailyReminderTime);
      }
    } else {
      await _settings.setEnabled(false);
      await _service.cancelDailyReminder();
    }
  }

  Future<void> _setDailyReminderEnabled(bool value) async {
    await _settings.setDailyReminderEnabled(value);
    if (value) {
      await _service.scheduleDailyReminder(_settings.dailyReminderTime);
    } else {
      await _service.cancelDailyReminder();
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _settings.dailyReminderTime,
    );
    if (picked == null) return;
    await _settings.setDailyReminderTime(picked);
    if (_settings.dailyReminderEnabled) {
      await _service.scheduleDailyReminder(picked);
    }
  }

  Future<void> _pickBriefingTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _settings.morningBriefingTime,
    );
    if (picked != null) await _settings.setMorningBriefingTime(picked);
  }

  Future<void> _pickWeeklyReviewTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _settings.weeklyReviewTime,
    );
    if (picked != null) await _settings.setWeeklyReviewTime(picked);
  }

  /// Weekly review: on/off, day, time and the optional trainer sentence.
  List<Widget> _weeklyReview(BuildContext context, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).toString();
    // 1 Jan 2024 was a Monday.
    String dayName(int weekday) =>
        DateFormat.EEEE(locale).format(DateTime(2024, 1, weekday));
    return [
      SwitchListTile(
        key: const ValueKey('weekly-review'),
        contentPadding: EdgeInsets.zero,
        title: Text(l10n.weeklyReviewNotification),
        subtitle: Text(
          _service.supportsScheduledReminder
              ? l10n.weeklyReviewNotificationHelp
              : '${l10n.weeklyReviewNotificationHelp} '
                    '${l10n.weeklyReviewOnStartHelp}',
        ),
        value: _settings.weeklyReviewEnabled,
        onChanged: _settings.setWeeklyReviewEnabled,
      ),
      if (_settings.weeklyReviewEnabled) ...[
        Wrap(
          spacing: 12,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DropdownButton<int>(
              key: const ValueKey('weekly-review-day'),
              value: _settings.weeklyReviewWeekday,
              hint: Text(l10n.weeklyReviewDayLabel),
              items: [
                for (var d = DateTime.monday; d <= DateTime.sunday; d++)
                  DropdownMenuItem(value: d, child: Text(dayName(d))),
              ],
              onChanged: (d) {
                if (d != null) _settings.setWeeklyReviewWeekday(d);
              },
            ),
            OutlinedButton.icon(
              key: const ValueKey('weekly-review-time'),
              onPressed: () => _pickWeeklyReviewTime(context),
              icon: const Icon(Icons.schedule_outlined),
              label: Text(_settings.weeklyReviewTime.format(context)),
            ),
          ],
        ),
        // The sentence needs a provider; without one it isn't offered.
        if (LlmSettings.instance.isConfigured)
          SwitchListTile(
            key: const ValueKey('weekly-review-comment'),
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.weeklyReviewTrainerComment),
            subtitle: Text(l10n.weeklyReviewTrainerCommentHelp),
            value: _settings.weeklyReviewTrainerComment,
            onChanged: _settings.setWeeklyReviewTrainerComment,
          ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_settings, LlmSettings.instance]),
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.enableNotifications),
              subtitle: Text(l10n.notificationsSubtitle),
              value: _settings.enabled,
              onChanged: (value) => _setEnabled(context, value),
            ),
            if (_settings.enabled && _service.supportsScheduledReminder) ...[
              const Divider(height: 1),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.dailyTrainingReminder),
                value: _settings.dailyReminderEnabled,
                onChanged: (value) => _setDailyReminderEnabled(value),
              ),
              if (_settings.dailyReminderEnabled)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: OutlinedButton.icon(
                    onPressed: () => _pickTime(context),
                    icon: const Icon(Icons.schedule_outlined),
                    label: Text(_settings.dailyReminderTime.format(context)),
                  ),
                ),
              SwitchListTile(
                key: const ValueKey('morning-briefing'),
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.morningBriefing),
                subtitle: Text(l10n.morningBriefingHelp),
                value: _settings.morningBriefingEnabled,
                onChanged: _settings.setMorningBriefingEnabled,
              ),
              if (_settings.morningBriefingEnabled)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: OutlinedButton.icon(
                    key: const ValueKey('morning-briefing-time'),
                    onPressed: () => _pickBriefingTime(context),
                    icon: const Icon(Icons.schedule_outlined),
                    label: Text(_settings.morningBriefingTime.format(context)),
                  ),
                ),
            ] else if (_settings.enabled)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.reminderNeedsBackground,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            if (_settings.enabled &&
                (_service.supportsScheduledReminder ||
                    _service.showsMissedOnStart))
              ..._weeklyReview(context, l10n),
            const Divider(height: 1),
            // In-app, so independent of the OS notification permission.
            SwitchListTile(
              key: const ValueKey('insights-popup'),
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.insightsPopupSetting),
              subtitle: Text(l10n.insightsPopupSettingHelp),
              value: _settings.insightsPopupEnabled,
              onChanged: _settings.setInsightsPopupEnabled,
            ),
          ],
        );
      },
    );
  }
}

/// How often TriIQ is allowed to auto-refresh the current month from
/// Intervals.icu while the app is open (see `AutoSyncService`). Split out of
/// [SettingsScreen] for the same reason as [_NotificationsSection].
class _AutoSyncSection extends StatelessWidget {
  const _AutoSyncSection();

  static final _settings = SyncSettings.instance;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.autoSyncDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final minutes in SyncSettings.autoSyncIntervalOptions)
                  ChoiceChip(
                    label: Text(
                      minutes < 60
                          ? l10n.autoSyncMinutes(minutes)
                          : l10n.autoSyncHours(minutes ~/ 60),
                    ),
                    selected: _settings.autoSyncIntervalMinutes == minutes,
                    onSelected: (_) =>
                        _settings.setAutoSyncIntervalMinutes(minutes),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            BackgroundSyncControls(settings: _settings),
          ],
        );
      },
    );
  }
}

/// The "keep syncing in background" switch, how often it runs, and what
/// its last run did. Android only — elsewhere nothing can wake a closed
/// app, so it says so instead of offering a switch that would do nothing.
class BackgroundSyncControls extends StatefulWidget {
  const BackgroundSyncControls({super.key, required this.settings});

  final SyncSettings settings;

  @override
  State<BackgroundSyncControls> createState() => BackgroundSyncControlsState();
}

class BackgroundSyncControlsState extends State<BackgroundSyncControls> {
  SyncSettings get settings => widget.settings;

  @override
  void initState() {
    super.initState();
    // The last run is written by the background isolate, so re-read it from
    // disk whenever Settings opens.
    settings.load();
  }

  String _result(AppLocalizations l10n, String? name) {
    final outcome = BackgroundSyncOutcome.values.asNameMap()[name];
    return switch (outcome) {
      BackgroundSyncOutcome.success => l10n.backgroundResultSuccess,
      BackgroundSyncOutcome.skippedFresh => l10n.backgroundResultSkippedFresh,
      BackgroundSyncOutcome.authRejected => l10n.backgroundResultAuthRejected,
      BackgroundSyncOutcome.notConnected => l10n.backgroundResultNotConnected,
      _ => l10n.backgroundResultFailed,
    };
  }

  String _intervalLabel(
    AppLocalizations l10n,
    BackgroundSyncInterval interval,
  ) => switch (interval) {
    BackgroundSyncInterval.minutes15 => l10n.backgroundInterval15Min,
    BackgroundSyncInterval.hourly => l10n.backgroundIntervalHourly,
    BackgroundSyncInterval.every6Hours => l10n.backgroundInterval6Hours,
    BackgroundSyncInterval.nightly => l10n.backgroundIntervalNightly,
  };

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: settings,
    builder: (context, _) => _build(context),
  );

  Widget _build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final muted = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    if (!BackgroundSync.isSupported) {
      return Text(l10n.backgroundSyncUnsupported, style: muted);
    }
    final lastRun = settings.backgroundLastRunAt;
    final material = MaterialLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.backgroundSyncTitle),
          subtitle: Text(l10n.backgroundSyncDescription),
          value: settings.backgroundSyncEnabled,
          onChanged: (value) async {
            await settings.setBackgroundSyncEnabled(value);
            await BackgroundSync.instance.apply();
          },
        ),
        if (settings.backgroundSyncEnabled) ...[
          Text(l10n.backgroundSyncIntervalLabel),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final interval in BackgroundSyncInterval.values)
                ChoiceChip(
                  label: Text(_intervalLabel(l10n, interval)),
                  selected: settings.backgroundSyncInterval == interval,
                  onSelected: (_) async {
                    await settings.setBackgroundSyncInterval(interval);
                    await BackgroundSync.instance.apply();
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(l10n.backgroundSyncNotifyHint, style: muted),
          const SizedBox(height: 4),
          Text(l10n.backgroundSyncBatteryHint, style: muted),
          const SizedBox(height: 8),
        ],
        Text(
          lastRun == null
              ? l10n.backgroundSyncNoRun
              : l10n.backgroundSyncLastRun(
                  '${material.formatShortDate(lastRun)} '
                  '${material.formatTimeOfDay(TimeOfDay.fromDateTime(lastRun))}',
                  _result(l10n, settings.backgroundLastResult),
                ),
          style: muted,
        ),
      ],
    );
  }
}

/// The app language: System (follows the device locale), English, or
/// German. Split out of [SettingsScreen] for the same reason as
/// [_NotificationsSection].
class _LanguageSection extends StatelessWidget {
  const _LanguageSection();

  static final _controller = LocaleController.instance;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => SegmentedButton<Locale?>(
        segments: [
          ButtonSegment(value: null, label: Text(l10n.languageSystem)),
          const ButtonSegment(value: Locale('en'), label: Text('English')),
          const ButtonSegment(value: Locale('de'), label: Text('Deutsch')),
        ],
        selected: {_controller.locale},
        onSelectionChanged: (selection) =>
            _controller.setLocale(selection.first),
      ),
    );
  }
}
