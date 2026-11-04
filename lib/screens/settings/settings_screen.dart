import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../agent/llm_settings.dart';
import '../../agent/ollama_connection.dart';
import '../../data/sync/background_sync.dart';
import '../../data/sync/background_sync_runner.dart';
import '../../data/sync/sync_settings.dart';
import '../../l10n/app_localizations.dart';
import '../../locale_controller.dart';
import '../../notifications/notification_service.dart';
import '../../notifications/notification_settings.dart';
import '../../theme_controller.dart';
import '../../widgets/section_card.dart';
import 'backup_settings_section.dart';
import 'calendar_settings_section.dart';
import 'feel_settings_section.dart';
import 'weekly_targets_section.dart';
import 'year_goals_section.dart';

/// App settings: appearance and the LLM provider the chat agent talks to.
///
/// Intervals.icu connection lives on the Profile screen (it's a login, not
/// a setting). Everything here is persisted by [LlmSettings] — the Claude
/// and Ollama Cloud keys to the OS credential vault, the rest to shared
/// preferences.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settings = LlmSettings.instance;

  late final TextEditingController _claudeKeyController;
  late final TextEditingController _claudeModelController;
  late final TextEditingController _ollamaUrlController;
  late final TextEditingController _ollamaModelController;
  late final TextEditingController _ollamaKeyController;

  bool _showClaudeKey = false;
  bool _showOllamaKey = false;
  bool _adoptedStoredValues = false;

  /// Models actually seen on the server, replacing the static suggestion
  /// list once a connection test succeeds. Starts as the static list so
  /// the field is never empty.
  List<String> _ollamaModels = List.of(LlmSettings.ollamaModelSuggestions);
  bool _testingOllama = false;
  String? _ollamaTestError;

  @override
  void initState() {
    super.initState();
    _claudeKeyController = TextEditingController();
    _claudeModelController = TextEditingController(
      text: _settings.claudeModel,
    );
    _ollamaUrlController = TextEditingController(
      text: _settings.ollamaBaseUrl,
    );
    _ollamaModelController = TextEditingController(text: _settings.ollamaModel);
    _ollamaKeyController = TextEditingController();
    // The screen can open before the initial load resolves, so pick the
    // stored values up when they land.
    _settings.addListener(_adoptStoredValues);
    _adoptStoredValues();
  }

  @override
  void dispose() {
    _settings.removeListener(_adoptStoredValues);
    _claudeKeyController.dispose();
    _claudeModelController.dispose();
    _ollamaUrlController.dispose();
    _ollamaModelController.dispose();
    _ollamaKeyController.dispose();
    super.dispose();
  }

  /// Copies the stored values into the text fields once, when the initial
  /// load resolves. Only once: after that the fields are the user's, and
  /// every keystroke notifies this listener via the setters.
  void _adoptStoredValues() {
    if (!mounted || _adoptedStoredValues || !_settings.isLoaded) return;
    _adoptedStoredValues = true;
    setState(() {
      _claudeModelController.text = _settings.claudeModel;
      _ollamaUrlController.text = _settings.ollamaBaseUrl;
      _ollamaModelController.text = _settings.ollamaModel;
    });
    // Best-effort: if Ollama is already set up, show the live model list
    // right away rather than waiting for the user to press something.
    // Silent — a stale/unreachable server on screen-open isn't an error
    // worth a SnackBar, just a reason to keep the static suggestions.
    if (_settings.provider == LlmProvider.ollama &&
        (!_settings.isOllamaCloud || _settings.hasOllamaApiKey)) {
      _testOllamaConnection(announce: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleSettings)),
      body: ListenableBuilder(
        listenable: _settings,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SectionCard(
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
            const SizedBox(height: 16),
            SectionCard(
              icon: Icons.language_outlined,
              title: l10n.languageTitle,
              child: const _LanguageSection(),
            ),
            const SizedBox(height: 16),
            SectionCard(
              icon: Icons.notifications_outlined,
              title: l10n.notificationsTitle,
              child: const _NotificationsSection(),
            ),
            const SizedBox(height: 16),
            SectionCard(
              icon: Icons.sync_outlined,
              title: l10n.syncSectionTitle,
              child: const _AutoSyncSection(),
            ),
            const SizedBox(height: 16),
            SectionCard(
              icon: Icons.calendar_month_outlined,
              title: l10n.calendarSettingsTitle,
              child: CalendarSettingsSection(),
            ),
            const SizedBox(height: 16),
            SectionCard(
              icon: Icons.backup_outlined,
              title: l10n.backupTitle,
              child: const BackupSettingsSection(),
            ),
            const SizedBox(height: 16),
            SectionCard(
              icon: Icons.mood_outlined,
              title: l10n.feelSettingsTitle,
              child: FeelSettingsSection(),
            ),
            const SizedBox(height: 16),
            SectionCard(
              icon: Icons.track_changes_outlined,
              title: l10n.weeklyTargetsSectionTitle,
              child: WeeklyTargetsSection(),
            ),
            const SizedBox(height: 16),
            SectionCard(
              icon: Icons.flag_outlined,
              title: l10n.yearGoalsTitle,
              child: YearGoalsSection(),
            ),
            const SizedBox(height: 16),
            SectionCard(
              icon: Icons.auto_awesome_outlined,
              title: l10n.llmProviderTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SegmentedButton<LlmProvider>(
                    segments: [
                      ButtonSegment(
                        value: LlmProvider.claude,
                        label: Text(l10n.claudeLabel),
                        icon: const Icon(Icons.bolt_outlined),
                      ),
                      ButtonSegment(
                        value: LlmProvider.ollama,
                        label: Text(l10n.ollamaLabel),
                        icon: const Icon(Icons.dns_outlined),
                      ),
                    ],
                    selected: {_settings.provider},
                    onSelectionChanged: (selection) =>
                        _settings.setProvider(selection.first),
                  ),
                  const SizedBox(height: 14),
                  if (_settings.provider == LlmProvider.claude)
                    ..._claudeFields(context)
                  else
                    ..._ollamaFields(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _claudeFields(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      TextField(
        controller: _claudeKeyController,
        obscureText: !_showClaudeKey,
        autocorrect: false,
        enableSuggestions: false,
        decoration: InputDecoration(
          labelText: l10n.claudeApiKeyLabel,
          hintText: _settings.hasClaudeApiKey
              ? l10n.claudeKeyStoredHint
              : 'sk-ant-…',
          suffixIcon: IconButton(
            tooltip: _showClaudeKey ? l10n.hideTooltip : l10n.showTooltip,
            icon: Icon(
              _showClaudeKey
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            onPressed: () => setState(() => _showClaudeKey = !_showClaudeKey),
          ),
        ),
        onSubmitted: (_) => _saveClaudeKey(),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          FilledButton(
            onPressed: _saveClaudeKey,
            child: Text(l10n.saveKeyButton),
          ),
          const SizedBox(width: 8),
          if (_settings.hasClaudeApiKey)
            TextButton(
              onPressed: _clearClaudeKey,
              child: Text(l10n.clearButton),
            ),
        ],
      ),
      const SizedBox(height: 14),
      _modelField(
        controller: _claudeModelController,
        label: l10n.claudeModelLabel,
        suggestions: LlmSettings.claudeModelSuggestions,
        onChanged: _settings.setClaudeModel,
      ),
      const SizedBox(height: 10),
      _helpText(
        context,
        _settings.remembersClaudeApiKey
            ? l10n.claudeKeySecureHelp
            : l10n.claudeKeyInsecureHelp,
      ),
    ];
  }

  List<Widget> _ollamaFields(BuildContext context) {
    final isCloud = _settings.isOllamaCloud;
    final l10n = AppLocalizations.of(context)!;

    return [
      TextField(
        controller: _ollamaUrlController,
        autocorrect: false,
        keyboardType: TextInputType.url,
        decoration: InputDecoration(labelText: l10n.ollamaServerUrlLabel),
        onChanged: (value) {
          _settings.setOllamaBaseUrl(value);
          setState(() => _ollamaTestError = null);
        },
      ),
      const SizedBox(height: 14),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: _ollamaKeyController,
              obscureText: !_showOllamaKey,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: isCloud
                    ? l10n.ollamaCloudApiKeyLabel
                    : l10n.ollamaApiKeyOptionalLabel,
                hintText: _settings.hasOllamaApiKey
                    ? l10n.ollamaKeyStoredHint
                    : null,
                suffixIcon: IconButton(
                  tooltip: _showOllamaKey ? l10n.hideTooltip : l10n.showTooltip,
                  icon: Icon(
                    _showOllamaKey
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _showOllamaKey = !_showOllamaKey),
                ),
              ),
              onSubmitted: (_) => _saveOllamaKey(),
            ),
          ),
          if (isCloud) ...[
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TextButton.icon(
                onPressed: _openOllamaKeysPage,
                icon: const Icon(Icons.open_in_new, size: 16),
                label: Text(l10n.getAKeyButton),
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          FilledButton(
            onPressed: _testingOllama ? null : _saveOllamaKey,
            child: _testingOllama
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : Text(l10n.saveKeyButton),
          ),
          const SizedBox(width: 8),
          if (_settings.hasOllamaApiKey)
            TextButton(
              onPressed: _clearOllamaKey,
              child: Text(l10n.clearButton),
            ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _testingOllama
                ? null
                : () => _testOllamaConnection(announce: true),
            icon: const Icon(Icons.wifi_tethering, size: 16),
            label: Text(l10n.testConnectionButton),
          ),
        ],
      ),
      if (_ollamaTestError != null) ...[
        const SizedBox(height: 6),
        Text(
          _ollamaTestError!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ],
      const SizedBox(height: 14),
      _modelField(
        controller: _ollamaModelController,
        label: l10n.ollamaModelLabel,
        suggestions: _ollamaModels,
        onChanged: _settings.setOllamaModel,
      ),
      const SizedBox(height: 10),
      _helpText(
        context,
        isCloud
            ? (_settings.remembersOllamaApiKey
                  ? l10n.ollamaKeySecureHelp
                  : l10n.ollamaKeyInsecureHelp)
            : l10n.ollamaLocalHelp,
      ),
    ];
  }

  Widget _modelField({
    required TextEditingController controller,
    required String label,
    required List<String> suggestions,
    required void Function(String) onChanged,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        controller: controller,
        autocorrect: false,
        decoration: InputDecoration(labelText: label),
        onChanged: onChanged,
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: [
          for (final suggestion in suggestions)
            ActionChip(
              label: Text(suggestion),
              onPressed: () {
                controller.text = suggestion;
                onChanged(suggestion);
              },
            ),
        ],
      ),
    ],
  );

  Widget _helpText(BuildContext context, String text) => Text(
    text,
    style: Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );

  Future<void> _saveClaudeKey() async {
    final key = _claudeKeyController.text.trim();
    if (key.isEmpty) return;
    await _settings.setClaudeApiKey(key);
    _claudeKeyController.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.claudeKeySavedMessage)),
    );
  }

  Future<void> _clearClaudeKey() async {
    await _settings.setClaudeApiKey('');
    _claudeKeyController.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.claudeKeyRemovedMessage),
      ),
    );
  }

  /// The key to test/connect with: whatever's freshly typed, else whatever
  /// is already stored — so "Test connection" still works after a key was
  /// saved earlier in this session without retyping it.
  String? get _effectiveOllamaApiKey {
    final typed = _ollamaKeyController.text.trim();
    return typed.isNotEmpty ? typed : _settings.ollamaApiKey;
  }

  /// Saves the typed key — but only once it's proven to actually work.
  /// Mirrors how a bad Intervals.icu key never gets persisted either; the
  /// difference from Claude's key (saved unconditionally) is that this test
  /// is free, where a Claude round-trip would cost tokens.
  Future<void> _saveOllamaKey() async {
    final key = _ollamaKeyController.text.trim();
    if (key.isEmpty) return;
    setState(() {
      _testingOllama = true;
      _ollamaTestError = null;
    });
    try {
      final models = await fetchOllamaModels(
        baseUrl: _ollamaUrlController.text,
        apiKey: key,
      );
      await _settings.setOllamaApiKey(key);
      _ollamaKeyController.clear();
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        if (models.isNotEmpty) _ollamaModels = models;
        _testingOllama = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.connectedModelsMessage(
              l10n.ollamaKeySavedPrefix,
              models.length,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _testingOllama = false;
        _ollamaTestError = AppLocalizations.of(
          context,
        )!.couldNotConnectKeyNotSaved(e.toString());
      });
    }
  }

  /// Fetches the live model list without saving anything — for a local
  /// server that needs no key, or to re-check/refresh after a key is
  /// already saved. [announce] suppresses feedback for the silent check on
  /// screen open, where an unreachable server isn't worth interrupting for.
  Future<void> _testOllamaConnection({required bool announce}) async {
    setState(() {
      _testingOllama = true;
      _ollamaTestError = null;
    });
    try {
      final models = await fetchOllamaModels(
        baseUrl: _ollamaUrlController.text,
        apiKey: _effectiveOllamaApiKey,
      );
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        if (models.isNotEmpty) _ollamaModels = models;
        _testingOllama = false;
      });
      if (announce) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.connectedModelsMessage(l10n.connectedPrefix, models.length),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _testingOllama = false;
        if (announce) {
          _ollamaTestError = AppLocalizations.of(
            context,
          )!.couldNotConnect(e.toString());
        }
      });
    }
  }

  Future<void> _clearOllamaKey() async {
    await _settings.setOllamaApiKey('');
    _ollamaKeyController.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.ollamaKeyRemovedMessage),
      ),
    );
  }

  Future<void> _openOllamaKeysPage() async {
    final uri = Uri.parse('https://ollama.com/settings/keys');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.couldNotOpenUrl(uri.toString()),
          ),
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
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

/// The nightly background-sync toggle and what its last run did. Android
/// only — elsewhere nothing can wake a closed app, so it says so instead of
/// offering a switch that would do nothing.
/// The nightly background-sync switch and its last run (Android only).
class BackgroundSyncControls extends StatefulWidget {
  const BackgroundSyncControls({super.key, required this.settings});

  final SyncSettings settings;

  @override
  State<BackgroundSyncControls> createState() =>
      BackgroundSyncControlsState();
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
          const ButtonSegment(
            value: Locale('en'),
            label: Text('English'),
          ),
          const ButtonSegment(
            value: Locale('de'),
            label: Text('Deutsch'),
          ),
        ],
        selected: {_controller.locale},
        onSelectionChanged: (selection) =>
            _controller.setLocale(selection.first),
      ),
    );
  }
}
