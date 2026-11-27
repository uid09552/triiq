import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../agent/llm_settings.dart';
import '../agent/openai_connection.dart';
import '../data/intervals_session.dart';
import '../data/sync/sync_scope.dart';
import '../data/sync/sync_service.dart';
import '../l10n/app_localizations.dart';
import '../screens/settings/ai_consent.dart';
import '../widgets/intervals_login.dart';
import '../screens/settings/openai_texts.dart';
import '../screens/settings/privacy_screen.dart';
import '../screens/events/event_editor_screen.dart';
import '../screens/settings/weekly_targets_settings.dart';
import '../screens/settings/year_goals_settings.dart';
import 'onboarding_settings.dart';
import 'setup_checks.dart';

/// First-run flow, and the guided setup in Settings: welcome, connect
/// Intervals.icu (and sync this month), sync more history, sports and weekly
/// hours, year goals, races and events, the AI trainer (with its consent),
/// done. Every step can be skipped, and "Skip setup" leaves at once —
/// Today's "Finish setting up" banner then covers what's missing. The
/// choices go to the same settings the Settings screen edits.
///
/// [guided] is the run from Settings: what is already set is filled in (and
/// kept when a step is skipped or left as it is), and it ends back in
/// Settings.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    this.connect,
    this.syncMonth,
    this.athleteName,
    this.targets,
    this.llm,
    this.settings,
    this.askConsent,
    this.login,
    this.loginAvailable,
    this.guided = false,
    this.isConnected,
    this.yearGoals,
    this.syncData,
    this.addEvent,
    this.findings,
  });

  /// Reads what the first sync shows (Strava stubs, missing thresholds);
  /// default [checkSetup] for the sports picked earlier.
  final Future<SetupFindings> Function(List<String> sports)? findings;

  /// Opened from Settings rather than on a fresh install.
  final bool guided;

  /// Whether Intervals.icu is connected already; default the session.
  final bool Function()? isConnected;
  final YearGoalsSettings? yearGoals;

  /// Syncs [SyncScope]; default [SyncService.syncScope].
  final Future<SyncResult> Function(SyncScope scope)? syncData;

  /// Opens the event editor for a new event of [category] (`null`: the
  /// athlete picks); returns whether one was saved.
  final Future<bool> Function(BuildContext context, String? category)? addEvent;

  /// The browser login (default: Intervals.icu OAuth, then connect), and
  /// whether to offer it (default: where the platform supports it).
  final Future<void> Function()? login;
  final bool? loginAvailable;

  /// Checks and saves the key; default [IntervalsSession.connect].
  final Future<void> Function(String apiKey)? connect;

  /// Syncs the current month and returns how many activities came in.
  final Future<int> Function()? syncMonth;
  final String? Function()? athleteName;
  final WeeklyTargetsSettings? targets;
  final LlmSettings? llm;
  final OnboardingSettings? settings;

  /// Asks for the AI consent; default [askAiConsent].
  final Future<bool> Function(BuildContext context)? askConsent;

  static const steps = 8;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

enum _Sync { idle, connecting, syncing, synced, failed }

enum _Data { idle, syncing, done, failed }

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;

  // Connect.
  final _apiKey = TextEditingController();
  _Sync _sync = _Sync.idle;
  String? _connectError;
  int _synced = 0;

  /// Connected before this run started (guided setup).
  bool _wasConnected = false;

  // Sync history.
  SyncScope _scope = SyncScope.year;
  _Data _data = _Data.idle;
  SetupFindings _findings = const SetupFindings();
  SyncResult? _dataResult;

  // Year goals.
  final _goals = {
    'swim': TextEditingController(),
    'ride': TextEditingController(),
    'run': TextEditingController(),
  };

  // Events.
  int _eventsAdded = 0;

  // Training.
  final _sports = {'swim', 'ride', 'run'};
  final _hours = {
    'swim': TextEditingController(text: '2'),
    'ride': TextEditingController(text: '4'),
    'run': TextEditingController(text: '3'),
  };

  // AI.
  LlmProvider? _provider;
  final _aiKey = TextEditingController();
  final _ollamaUrl = TextEditingController(
    text: LlmSettings.defaultOllamaBaseUrl,
  );
  final _openAiUrl = TextEditingController(
    text: LlmSettings.defaultOpenAiBaseUrl,
  );
  final _openAiModel = TextEditingController(
    text: LlmSettings.defaultOpenAiModel,
  );
  bool _savingAi = false;

  WeeklyTargetsSettings get _targets =>
      widget.targets ?? WeeklyTargetsSettings.instance;
  LlmSettings get _llm => widget.llm ?? LlmSettings.instance;
  OnboardingSettings get _settings =>
      widget.settings ?? OnboardingSettings.instance;
  YearGoalsSettings get _yearGoals =>
      widget.yearGoals ?? YearGoalsSettings.instance;

  bool get _connected =>
      (widget.isConnected ?? () => IntervalsSession.instance.isConnected)();

  static const _goalSport = {'swim': 'swim', 'ride': 'cycle', 'run': 'run'};

  static String _number(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toString();

  @override
  void initState() {
    super.initState();
    if (_connected) {
      _wasConnected = true;
      _sync = _Sync.synced;
    }
    // What is set already is the starting point, so a guided run that
    // only clicks through changes nothing.
    if (_targets.hasAnyTarget) {
      final hours = {
        'swim': _targets.swimHours,
        'ride': _targets.cycleHours,
        'run': _targets.runHours,
      };
      _sports
        ..clear()
        ..addAll([
          for (final e in hours.entries)
            if (e.value != null) e.key,
        ]);
      for (final e in hours.entries) {
        if (e.value != null) _hours[e.key]!.text = _number(e.value!);
      }
    }
    for (final e in _goalSport.entries) {
      final km = _yearGoals.goalFor(e.value);
      if (km != null) _goals[e.key]!.text = _number(km);
    }
    if (widget.guided && _llm.isConfigured) {
      _provider = _llm.provider;
      _ollamaUrl.text = _llm.ollamaBaseUrl;
      _openAiUrl.text = _llm.openAiBaseUrl;
      _openAiModel.text = _llm.openAiModel;
    }
  }

  /// The AI step would keep what is configured: same provider, no new key.
  bool get _keepAi =>
      widget.guided &&
      _llm.isConfigured &&
      _provider == _llm.provider &&
      _aiKey.text.trim().isEmpty &&
      (_provider != LlmProvider.ollama ||
          _ollamaUrl.text.trim() == _llm.ollamaBaseUrl) &&
      (_provider != LlmProvider.openai ||
          (_openAiUrl.text.trim() == _llm.openAiBaseUrl &&
              _openAiModel.text.trim() == _llm.openAiModel));

  @override
  void dispose() {
    _apiKey.dispose();
    for (final c in _goals.values) {
      c.dispose();
    }
    for (final c in _hours.values) {
      c.dispose();
    }
    _aiKey.dispose();
    _ollamaUrl.dispose();
    _openAiUrl.dispose();
    _openAiModel.dispose();
    super.dispose();
  }

  void _next() => setState(() => _step++);
  void _back() => setState(() => _step--);

  Future<void> _finish() async {
    await _settings.markDone();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _connect() async {
    final key = _apiKey.text.trim();
    if (key.isEmpty) return;
    setState(() {
      _sync = _Sync.connecting;
      _connectError = null;
    });
    try {
      await (widget.connect ?? IntervalsSession.instance.connect)(key);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sync = _Sync.idle;
        _connectError = AppLocalizations.of(
          context,
        )!.couldNotConnectGeneric(e.toString());
      });
      return;
    }
    await _syncAfterConnect();
  }

  /// Connected (by key or by the browser login): bring this month in.
  Future<void> _syncAfterConnect() async {
    if (!mounted) return;
    setState(() => _sync = _Sync.syncing);
    try {
      final count =
          await (widget.syncMonth ??
              () async => (await SyncService().syncScope(
                SyncScope.month,
              )).activitiesCount)();
      if (!mounted) return;
      setState(() {
        _synced = count;
        _sync = _Sync.synced;
      });
    } catch (_) {
      if (mounted) setState(() => _sync = _Sync.failed);
    }
  }

  Future<void> _saveTraining() async {
    double? hours(String sport) => _sports.contains(sport)
        ? double.tryParse(_hours[sport]!.text.replaceAll(',', '.'))
        : null;
    await _targets.setSwimHours(hours('swim'));
    await _targets.setCycleHours(hours('ride'));
    await _targets.setRunHours(hours('run'));
    _next();
  }

  Future<void> _syncData() async {
    setState(() {
      _data = _Data.syncing;
      _dataResult = null;
    });
    try {
      final result =
          await (widget.syncData ?? (s) => SyncService().syncScope(s))(_scope);
      if (!mounted) return;
      SetupFindings found = const SetupFindings();
      try {
        found =
            await (widget.findings ?? (sports) => checkSetup(sports: sports))([
              for (final s in _sports)
                {'swim': 'Swim', 'ride': 'Ride', 'run': 'Run'}[s] ?? s,
            ]);
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _dataResult = result;
        _findings = found;
        _data = _Data.done;
      });
    } catch (_) {
      if (mounted) setState(() => _data = _Data.failed);
    }
  }

  Future<void> _saveGoals() async {
    double? km(String sport) {
      if (!_sports.contains(sport)) {
        return _yearGoals.goalFor(_goalSport[sport]!);
      }
      final v = double.tryParse(
        _goals[sport]!.text.trim().replaceAll(',', '.'),
      );
      return v == null || v <= 0 ? null : v;
    }

    await _yearGoals.setSwimKm(km('swim'));
    await _yearGoals.setCycleKm(km('ride'));
    await _yearGoals.setRunKm(km('run'));
    _next();
  }

  Future<void> _addEvent(String? category) async {
    final saved =
        await (widget.addEvent ??
            (context, category) async =>
                await Navigator.of(context).push<bool>(
                  MaterialPageRoute<bool>(
                    builder: (_) =>
                        EventEditorScreen(initialCategory: category),
                  ),
                ) ==
                true)(context, category);
    if (saved && mounted) setState(() => _eventsAdded++);
  }

  Future<void> _saveAi() async {
    final provider = _provider;
    if (provider == null || _keepAi) return _next();
    setState(() => _savingAi = true);
    try {
      await _llm.setProvider(provider);
      if (provider == LlmProvider.claude) {
        await _llm.setClaudeApiKey(_aiKey.text);
      } else if (provider == LlmProvider.ollama) {
        await _llm.setOllamaBaseUrl(_ollamaUrl.text);
        if (_aiKey.text.trim().isNotEmpty) {
          await _llm.setOllamaApiKey(_aiKey.text);
        }
      } else {
        await _llm.setOpenAiBaseUrl(_openAiUrl.text);
        await _llm.setOpenAiModel(_openAiModel.text);
        if (_aiKey.text.trim().isNotEmpty) {
          await _llm.setOpenAiApiKey(_aiKey.text);
        }
      }
    } catch (error) {
      // The vault may refuse (no keychain): the in-memory choice stands for
      // this run, and Settings shows what was not saved.
      debugPrint('Onboarding: could not save the AI settings: $error');
    }
    if (!mounted) return;
    await (widget.askConsent ?? (c) => askAiConsent(c, settings: _llm))(
      context,
    );
    if (!mounted) return;
    setState(() => _savingAi = false);
    _next();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final last = _step == OnboardingScreen.steps - 1;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _step > 0 && !last ? _back() : _finish();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: _step > 0 && !last
              ? IconButton(
                  tooltip: l10n.obBack,
                  icon: const BackButtonIcon(),
                  onPressed: _back,
                )
              : null,
          title: Text(l10n.obStep(_step + 1, OnboardingScreen.steps)),
          actions: [
            if (!last)
              TextButton(
                key: const ValueKey('onboarding-skip-all'),
                onPressed: _finish,
                child: Text(widget.guided ? l10n.obClose : l10n.obSkipSetup),
              ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: (_step + 1) / OnboardingScreen.steps,
            ),
          ),
        ),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                key: ValueKey('onboarding-step-$_step'),
                padding: const EdgeInsets.all(24),
                children: switch (_step) {
                  0 => _welcome(context, l10n),
                  1 => _connectStep(context, l10n),
                  2 => _syncStep(context, l10n),
                  3 => _training(context, l10n),
                  4 => _yearGoalsStep(context, l10n),
                  5 => _eventsStep(context, l10n),
                  6 => _ai(context, l10n),
                  _ => _done(context, l10n),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _title(BuildContext context, IconData icon, String text) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: 12),
      Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 12),
    ],
  );

  Widget _actions({
    required String primary,
    required VoidCallback? onPrimary,
    VoidCallback? onSkip,
    Key? primaryKey,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: OverflowBar(
        alignment: onSkip == null
            ? MainAxisAlignment.end
            : MainAxisAlignment.spaceBetween,
        overflowAlignment: OverflowBarAlignment.end,
        overflowSpacing: 8,
        children: [
          if (onSkip != null)
            TextButton(
              key: const ValueKey('onboarding-skip-step'),
              onPressed: onSkip,
              child: Text(l10n.obSkipStep),
            ),
          FilledButton(
            key: primaryKey ?? const ValueKey('onboarding-next'),
            onPressed: onPrimary,
            child: Text(primary),
          ),
        ],
      ),
    );
  }

  List<Widget> _welcome(BuildContext context, AppLocalizations l10n) => [
    if (widget.guided) ...[
      _title(context, Icons.assistant_navigation, l10n.obGuidedTitle),
      Text(l10n.obGuidedBody),
    ] else ...[
      _title(context, Icons.waving_hand_outlined, l10n.obWelcomeTitle),
      Text(l10n.obWelcomeBody),
    ],
    const SizedBox(height: 16),
    Card(
      child: ListTile(
        leading: const Icon(Icons.privacy_tip_outlined),
        title: Text(l10n.obWelcomePrivacy),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const PrivacyScreen())),
      ),
    ),
    _actions(primary: l10n.obGetStarted, onPrimary: _next),
  ];

  List<Widget> _connectStep(BuildContext context, AppLocalizations l10n) {
    final busy = _sync == _Sync.connecting || _sync == _Sync.syncing;
    final connected =
        _sync == _Sync.synced ||
        _sync == _Sync.failed ||
        _sync == _Sync.syncing;
    final name =
        (widget.athleteName ?? () => IntervalsSession.instance.athleteName)();
    return [
      _title(context, Icons.link, l10n.obConnectTitle),
      Text(l10n.obConnectBody),
      const SizedBox(height: 16),
      if (!connected)
        IntervalsLoginButton(
          available: widget.loginAvailable,
          login: widget.login,
          onBusyChanged: (busy) => setState(
            () => _sync = busy
                ? _Sync.connecting
                : (_sync == _Sync.connecting ? _Sync.idle : _sync),
          ),
          onError: (message) => setState(() => _connectError = message),
          onConnected: () {
            setState(() => _connectError = null);
            _syncAfterConnect();
          },
        ),
      TextField(
        key: const ValueKey('onboarding-api-key'),
        controller: _apiKey,
        enabled: !busy && !connected,
        obscureText: true,
        autocorrect: false,
        enableSuggestions: false,
        decoration: InputDecoration(
          labelText: l10n.intervalsApiKeyLabel,
          errorText: _connectError,
          errorMaxLines: 4,
        ),
        onSubmitted: (_) => _connect(),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          icon: const Icon(Icons.help_outline, size: 18),
          label: Text(l10n.obWhereKey),
          onPressed: () => launchUrl(
            Uri.parse('https://intervals.icu/settings'),
            mode: LaunchMode.externalApplication,
          ),
        ),
      ),
      if (!connected)
        FilledButton.tonal(
          key: const ValueKey('onboarding-connect'),
          onPressed: busy ? null : _connect,
          child: Text(l10n.obConnect),
        ),
      if (busy || connected) ...[
        const SizedBox(height: 16),
        if (connected)
          Text(
            l10n.obConnected(name ?? '—'),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        const SizedBox(height: 8),
        if (busy) ...[
          const LinearProgressIndicator(key: ValueKey('onboarding-progress')),
          const SizedBox(height: 8),
          if (_sync == _Sync.syncing) Text(l10n.obSyncing),
        ],
        if (_sync == _Sync.synced && !_wasConnected)
          Text(
            l10n.obSynced(_synced),
            key: const ValueKey('onboarding-synced'),
          ),
        if (_sync == _Sync.failed) Text(l10n.obSyncFailed),
      ],
      _actions(
        primary: l10n.obNext,
        onPrimary: _sync == _Sync.synced || _sync == _Sync.failed
            ? _next
            : null,
        onSkip: busy ? null : _next,
      ),
    ];
  }

  List<Widget> _syncStep(BuildContext context, AppLocalizations l10n) {
    final connected = _connected;
    final busy = _data == _Data.syncing;
    final result = _dataResult;
    return [
      _title(context, Icons.sync, l10n.obSyncTitle),
      Text(l10n.obSyncBody),
      const SizedBox(height: 16),
      if (!connected)
        Text(
          l10n.obNeedsConnection,
          key: const ValueKey('onboarding-sync-offline'),
        )
      else ...[
        SegmentedButton<SyncScope>(
          key: const ValueKey('onboarding-sync-scope'),
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: SyncScope.month,
              label: Text(l10n.obSyncMonth),
            ),
            ButtonSegment(value: SyncScope.year, label: Text(l10n.obSyncYear)),
            ButtonSegment(value: SyncScope.all, label: Text(l10n.obSyncAll)),
          ],
          selected: {_scope},
          onSelectionChanged: busy
              ? null
              : (s) => setState(() => _scope = s.first),
        ),
        const SizedBox(height: 8),
        Text(l10n.obSyncHint, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          key: const ValueKey('onboarding-sync-now'),
          onPressed: busy ? null : _syncData,
          icon: const Icon(Icons.download),
          label: Text(l10n.obSyncNow),
        ),
        if (busy) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
        ],
        if (result != null) ...[
          const SizedBox(height: 12),
          Text(
            l10n.obSyncDone(
              result.activitiesCount,
              result.wellnessCount,
              result.eventsCount,
            ),
            key: const ValueKey('onboarding-sync-done'),
          ),
        ],
        if (_data == _Data.failed) ...[
          const SizedBox(height: 12),
          Text(l10n.obSyncDataFailed),
        ],
        if (_findings.stravaActivities > 0) ...[
          const SizedBox(height: 12),
          Card(
            key: const ValueKey('onboarding-strava-hint'),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(l10n.obStravaHint(_findings.stravaActivities)),
            ),
          ),
        ],
        if (_findings.missingThresholds.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            key: const ValueKey('onboarding-threshold-hint'),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                l10n.obThresholdHint(_findings.missingThresholds.join(', ')),
              ),
            ),
          ),
        ],
      ],
      _actions(
        primary: l10n.obNext,
        onPrimary: busy ? null : _next,
        onSkip: busy ? null : _next,
      ),
    ];
  }

  List<Widget> _yearGoalsStep(BuildContext context, AppLocalizations l10n) {
    final labels = {
      'swim': l10n.obSwim,
      'ride': l10n.obRide,
      'run': l10n.obRun,
    };
    return [
      _title(context, Icons.flag_outlined, l10n.obGoalsTitle),
      Text(l10n.obGoalsBody),
      const SizedBox(height: 16),
      for (final sport in labels.keys)
        if (_sports.contains(sport))
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              key: ValueKey('onboarding-goal-$sport'),
              controller: _goals[sport],
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.obGoalKm(labels[sport]!),
                hintText: l10n.noTargetSet,
                suffixText: 'km',
              ),
            ),
          ),
      _actions(primary: l10n.obNext, onPrimary: _saveGoals, onSkip: _next),
    ];
  }

  List<Widget> _eventsStep(BuildContext context, AppLocalizations l10n) {
    final connected = _connected;
    return [
      _title(context, Icons.emoji_events_outlined, l10n.obEventsTitle),
      Text(l10n.obEventsBody),
      const SizedBox(height: 16),
      if (!connected)
        Text(l10n.obNeedsConnection)
      else ...[
        FilledButton.tonalIcon(
          key: const ValueKey('onboarding-add-race'),
          onPressed: () => _addEvent('RACE_A'),
          icon: const Icon(Icons.emoji_events_outlined),
          label: Text(l10n.obAddRace),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          key: const ValueKey('onboarding-add-event'),
          onPressed: () => _addEvent(null),
          icon: const Icon(Icons.event_note_outlined),
          label: Text(l10n.obAddEvent),
        ),
        if (_eventsAdded > 0) ...[
          const SizedBox(height: 12),
          Text(
            l10n.obEventsAdded(_eventsAdded),
            key: const ValueKey('onboarding-events-added'),
          ),
        ],
      ],
      _actions(primary: l10n.obNext, onPrimary: _next, onSkip: _next),
    ];
  }

  List<Widget> _training(BuildContext context, AppLocalizations l10n) {
    final labels = {
      'swim': l10n.obSwim,
      'ride': l10n.obRide,
      'run': l10n.obRun,
    };
    final icons = {
      'swim': Icons.pool,
      'ride': Icons.directions_bike,
      'run': Icons.directions_run,
    };
    return [
      _title(context, Icons.fitness_center, l10n.obTrainingTitle),
      Text(l10n.obTrainingBody),
      const SizedBox(height: 16),
      Wrap(
        spacing: 8,
        children: [
          for (final sport in labels.keys)
            FilterChip(
              key: ValueKey('onboarding-sport-$sport'),
              avatar: Icon(icons[sport], size: 18),
              label: Text(labels[sport]!),
              selected: _sports.contains(sport),
              onSelected: (on) => setState(
                () => on ? _sports.add(sport) : _sports.remove(sport),
              ),
            ),
        ],
      ),
      const SizedBox(height: 16),
      for (final sport in labels.keys)
        if (_sports.contains(sport))
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              key: ValueKey('onboarding-hours-$sport'),
              controller: _hours[sport],
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.obHoursPerWeek(labels[sport]!),
              ),
            ),
          ),
      _actions(primary: l10n.obNext, onPrimary: _saveTraining, onSkip: _next),
    ];
  }

  List<Widget> _ai(BuildContext context, AppLocalizations l10n) => [
    _title(context, Icons.auto_awesome_outlined, l10n.obAiTitle),
    Text(l10n.obAiBody),
    if (widget.guided && _llm.isConfigured) ...[
      const SizedBox(height: 8),
      Text(
        l10n.obAiConfigured,
        key: const ValueKey('onboarding-ai-configured'),
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    ],
    const SizedBox(height: 16),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          key: const ValueKey('onboarding-ai-none'),
          label: Text(l10n.obAiNone),
          selected: _provider == null,
          onSelected: (_) => setState(() => _provider = null),
        ),
        ChoiceChip(
          key: const ValueKey('onboarding-ai-claude'),
          label: Text(l10n.claudeLabel),
          selected: _provider == LlmProvider.claude,
          onSelected: (_) => setState(() => _provider = LlmProvider.claude),
        ),
        ChoiceChip(
          key: const ValueKey('onboarding-ai-ollama'),
          label: Text(l10n.ollamaLabel),
          selected: _provider == LlmProvider.ollama,
          onSelected: (_) => setState(() => _provider = LlmProvider.ollama),
        ),
        ChoiceChip(
          key: const ValueKey('onboarding-ai-openai'),
          label: Text(l10n.openaiLabel),
          selected: _provider == LlmProvider.openai,
          onSelected: (_) => setState(() => _provider = LlmProvider.openai),
        ),
      ],
    ),
    const SizedBox(height: 16),
    if (_provider == LlmProvider.ollama) ...[
      TextField(
        key: const ValueKey('onboarding-ollama-url'),
        controller: _ollamaUrl,
        keyboardType: TextInputType.url,
        decoration: InputDecoration(labelText: l10n.obOllamaServer),
      ),
      const SizedBox(height: 12),
    ],
    if (_provider == LlmProvider.openai) ...[
      TextField(
        key: const ValueKey('onboarding-openai-url'),
        controller: _openAiUrl,
        keyboardType: TextInputType.url,
        autocorrect: false,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: l10n.openaiBaseUrlLabel,
          errorText: checkOpenAiBaseUrl(_openAiUrl.text) == null
              ? null
              : openAiUrlProblemText(
                  l10n,
                  checkOpenAiBaseUrl(_openAiUrl.text)!,
                  _openAiUrl.text,
                ),
          errorMaxLines: 3,
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        key: const ValueKey('onboarding-openai-model'),
        controller: _openAiModel,
        autocorrect: false,
        decoration: InputDecoration(labelText: l10n.openaiModelLabel),
      ),
      const SizedBox(height: 12),
    ],
    if (_provider != null)
      TextField(
        key: const ValueKey('onboarding-ai-key'),
        controller: _aiKey,
        onChanged: (_) => setState(() {}),
        obscureText: true,
        autocorrect: false,
        enableSuggestions: false,
        decoration: InputDecoration(
          labelText: switch (_provider) {
            LlmProvider.claude => l10n.claudeApiKeyLabel,
            LlmProvider.openai => l10n.openaiApiKeyOptionalLabel,
            _ => l10n.ollamaApiKeyOptionalLabel,
          },
        ),
      ),
    _actions(
      primary: _provider == null || _keepAi ? l10n.obNext : l10n.obAiSave,
      onPrimary:
          _savingAi ||
              (_provider == LlmProvider.claude &&
                  _aiKey.text.trim().isEmpty &&
                  !_keepAi) ||
              (_provider == LlmProvider.openai &&
                  !isValidOpenAiBaseUrl(_openAiUrl.text))
          ? null
          : _saveAi,
      onSkip: _next,
    ),
  ];

  List<Widget> _done(BuildContext context, AppLocalizations l10n) => [
    _title(context, Icons.check_circle_outline, l10n.obDoneTitle),
    Text(widget.guided ? l10n.obGuidedDoneBody : l10n.obDoneBody),
    _actions(
      primary: widget.guided ? l10n.obBackToSettings : l10n.obOpenToday,
      onPrimary: _finish,
      primaryKey: const ValueKey('onboarding-finish'),
    ),
  ];
}
