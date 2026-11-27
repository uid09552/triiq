import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../agent/chat_handoff.dart';
import '../../agent/chat_starters.dart';
import '../../agent/chat_transcript.dart';
import '../../agent/usage.dart';
import '../../evaluation/fatigue_warning_service.dart';
import '../../plan/proposal_safety.dart';
import '../today/fatigue_warning_card.dart' show FatigueWarningBanner;
import '../../data/repositories/sync_state_repository.dart';
import '../../agent/chat_model_factory.dart';
import '../../agent/llm_settings.dart';
import '../../agent/plan_proposals.dart';
import '../../agent/training_agent.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/design_tokens.dart';
import '../../notifications/app_lifecycle_tracker.dart';
import '../../notifications/notification_service.dart';
import '../../notifications/notification_settings.dart';
import '../../widgets/markdown_reply.dart';
import '../../widgets/status_message.dart'
    show describeAgentError, describeLlmFailureShort;
import '../settings/ai_consent.dart';
import '../settings/settings_screen.dart';
import 'navigation_card.dart';
import 'proposal_card.dart';

/// Chat with the training-analysis agent about your Intervals.icu data.
///
/// The agent ([TrainingAgent]) runs in-process: it talks to whichever LLM
/// provider is configured in Settings and reads the local cache through its
/// tools. This screen only renders the stream it emits — partial text as it
/// arrives, and a line naming each tool while it runs, so a question that
/// takes three round-trips doesn't look like a hang.
class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    this.agentFactory,
    this.store,
    this.proposals,
    this.syncedAt,
    this.fatigueService,
    this.starterFacts,
  });

  /// What the empty chat's starters are built from (default: the local
  /// cache); for tests.
  final Future<StarterFacts> Function()? starterFacts;

  /// Builds the agent (default [TrainingAgent.new]); for tests.
  final TrainingAgent Function()? agentFactory;

  /// Where the chat is kept between runs, and the proposals it registers
  /// restored ones with; for tests.
  final ChatStore? store;
  final PlanProposals? proposals;

  /// When the local data was last synced (default: the activities sync
  /// state); for tests.
  final Future<DateTime?> Function()? syncedAt;

  /// Reads the fatigue early warning for the banner above the chat (default
  /// from the local cache); for tests.
  final FatigueWarningService? fatigueService;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <TranscriptMessage>[];
  final _settings = LlmSettings.instance;
  late final ChatStore _store = widget.store ?? ChatStore();
  late final PlanProposals _proposals =
      widget.proposals ?? PlanProposals.instance;

  TrainingAgent? _agent;
  StreamSubscription<AgentEvent>? _subscription;
  String? _activity;

  /// What the athlete came here to ask about (from "Ask the trainer"),
  /// attached to the agent's context rather than shown as a message.
  ChatTopic? _topic;

  bool get _isBusy => _subscription != null;

  /// The reply being streamed, so a withdrawn consent can end it.
  TranscriptMessage? _streaming;

  /// Sending is off while models are set up but none is consented to.
  bool get _canSend => !_isBusy && !_settings.blockedByConsent;

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettingsChanged);
    ChatHandoff.instance.addListener(_takeTopic);
    // Applying or dismissing a card changes what is saved.
    _proposals.addListener(_save);
    _takeTopic();
    _restore();
    (widget.starterFacts ?? loadStarterFacts)().then((f) {
      if (mounted) setState(() => _facts = f);
    });
  }

  StarterFacts _facts = const StarterFacts();

  /// Brings back the conversation (and its unapplied proposals) saved by
  /// an earlier run.
  Future<void> _restore() async {
    final saved = await _store.load(_proposals);
    if (!mounted || saved.isEmpty || _messages.isNotEmpty) return;
    setState(() => _messages.addAll(saved));
    _scrollToEnd();
  }

  /// Saves the chat; the reply being streamed is left out until it is done.
  void _save() {
    if (!mounted) return;
    _store.save([
      for (final m in _messages)
        if (m != _streaming) m,
    ]);
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    _proposals.removeListener(_save);
    ChatHandoff.instance.removeListener(_takeTopic);
    _subscription?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Provider or credentials changed: drop the agent so the next message
  /// builds a fresh chat model. The transcript stays — it's the athlete's.
  void _onSettingsChanged() {
    _agent = null;
    // Consent withdrawn mid-reply: stop it now rather than let the provider
    // keep receiving tool results.
    final streaming = _streaming;
    if (_isBusy && streaming != null && _settings.blockedByConsent && mounted) {
      _finish(streaming, error: const AiConsentRequiredException());
      return;
    }
    if (mounted) setState(() {});
  }

  /// Starts a fresh conversation: the transcript goes, and so does the
  /// agent holding the model's own history — otherwise the next question
  /// would be answered in the context of a conversation the athlete can no
  /// longer see.
  Future<void> _newChat() async {
    if (_isBusy || _messages.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.newChatTitle),
        content: Text(l10n.newChatConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.newChatButton),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _messages.clear();
      _activity = null;
      _agent = null;
      _topic = null;
    });
    await _store.clear();
  }

  void _takeTopic() {
    final topic = ChatHandoff.instance.take();
    if (topic == null) return;
    final draft = topic.draft;
    if (draft != null) _controller.text = draft;
    setState(() => _topic = topic);
  }

  void _sendText(String text) {
    _controller.text = text;
    _send();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || !_canSend) return;

    final reply = TranscriptMessage(fromUser: false);
    // What the model is told is the conversation up to this question.
    final earlier = List<TranscriptMessage>.of(_messages);
    // Words that call for a doctor get a card at once, whatever the model
    // goes on to say.
    final flags = redFlagsIn(text);
    setState(() {
      _messages.add(TranscriptMessage(fromUser: true, text: text));
      if (flags.isNotEmpty) {
        _messages.add(
          TranscriptMessage(fromUser: false)..redFlags.addAll(flags),
        );
      }
      _messages.add(reply);
      _activity = AppLocalizations.of(context)!.thinkingEllipsis;
    });
    _controller.clear();
    _scrollToEnd();

    final agent = _agent ??= _newAgent(earlier);
    agent.attachedContext = _topic?.context;
    _streaming = reply;
    _save();
    try {
      _subscription = agent
          .send(text)
          .listen(
            (event) => _onEvent(event, reply),
            onError: (Object error) => _finish(reply, error: error),
            onDone: () => _finish(reply),
            cancelOnError: true,
          );
    } on LlmNotConfiguredException catch (error) {
      // Thrown synchronously, before the stream exists.
      _finish(reply, error: error);
    }
    setState(() {});
  }

  /// A fresh agent that already knows the conversation on screen (the
  /// messages before the one being sent now), so a restored chat carries on
  /// in context and a provider change does not make it forget.
  TrainingAgent _newAgent(List<TranscriptMessage> before) {
    final agent = (widget.agentFactory ?? TrainingAgent.new)();
    agent.restoreHistory([
      for (final m in before)
        if (!m.isError && m.text.trim().isNotEmpty)
          (fromUser: m.fromUser, text: m.text),
    ]);
    return agent;
  }

  void _onEvent(AgentEvent event, TranscriptMessage reply) {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      if (reply.buffer.apply(event)) reply.text = reply.buffer.text;
      switch (event) {
        case AgentModelAnswering(:final entry):
          reply.answeredBy = entry.label;
        case AgentModelSwitched(:final from, :final to, :final reason):
          reply.switchNotes.add(
            l10n.chatModelSwitched(
              to.label,
              from.label,
              describeLlmFailureShort(reason, l10n),
            ),
          );
          _activity = l10n.chatAskingModel(to.label);
        case AgentTextDelta():
          _activity = null;
        case AgentToolStarted(:final name):
          _activity = _describeTool(l10n, name);
          if (!reply.toolsUsed.contains(name)) reply.toolsUsed.add(name);
        case AgentUsage(:final usage):
          reply.usage = usage;
          UsageLedger.instance.record(usage);
        case AgentToolFinished(:final name, :final failed):
          _activity = failed
              ? l10n.toolFailedSuffix(_describeTool(l10n, name))
              : null;
        case AgentProposal(:final proposal):
          reply.proposals.add(proposal);
        case AgentNavigation(:final destinationId):
          if (!reply.navigations.contains(destinationId)) {
            reply.navigations.add(destinationId);
          }
      }
    });
    _scrollToEnd();
  }

  /// Ends the reply being streamed at the athlete's request: what has
  /// arrived stays, marked as stopped.
  void _stop() {
    final reply = _streaming;
    if (reply == null) return;
    reply.stopped = true;
    _finish(reply);
  }

  void _finish(TranscriptMessage reply, {Object? error}) {
    _subscription?.cancel();
    _subscription = null;
    _streaming = null;
    setState(() {
      _activity = null;
      if (error != null) {
        if (reply.text.isEmpty && reply.switchNotes.isEmpty) {
          _messages.remove(reply);
        } else if (reply.text.isEmpty) {
          reply.answeredBy = null;
        }
        _messages.add(
          TranscriptMessage(
            fromUser: false,
            isError: true,
            text: describeAgentError(error, AppLocalizations.of(context)!),
          ),
        );
      }
      if (!reply.fromUser && reply.text.isNotEmpty && !reply.isError) {
        reply.dietConcerns
          ..clear()
          ..addAll(dietConcernsIn(reply.text));
      }
      if (error == null && reply.text.isEmpty) {
        if (reply.stopped) {
          _messages.remove(reply);
        } else {
          reply.text = AppLocalizations.of(context)!.noReplyFromModel;
        }
      }
    });
    _scrollToEnd();
    _save();
    if (error == null && reply.toolsUsed.isNotEmpty) _stampFreshness(reply);
    // Only worth a notification if there's a reply to see and the user has
    // actually switched away — otherwise it's just noise over the bubble
    // already on screen.
    if (error == null &&
        reply.text.isNotEmpty &&
        !AppLifecycleTracker.instance.isForeground &&
        NotificationSettings.instance.enabled) {
      NotificationService.instance.showAgentReply(_preview(reply.text));
    }
  }

  /// Notes when the data the answer read was last synced, so an answer
  /// from a stale cache says so.
  Future<void> _stampFreshness(TranscriptMessage reply) async {
    DateTime? asOf;
    try {
      asOf =
          await (widget.syncedAt ??
              () async => (await SyncStateRepository().get(
                'activities',
              ))?.lastSyncedAt)();
    } catch (_) {
      asOf = null;
    }
    if (asOf == null || !mounted) return;
    setState(() => reply.dataAsOf = asOf);
    _save();
  }

  static String _preview(String text) =>
      text.length <= 140 ? text : '${text.substring(0, 140)}…';

  static String _describeTool(AppLocalizations l10n, String name) =>
      switch (name) {
        'get_athlete_context' => l10n.chatToolChecking,
        'get_daily_metrics' => l10n.chatToolDailyLoad,
        'get_activities' => l10n.chatToolActivities,
        'get_planned_workouts' => l10n.chatToolPlanned,
        'get_training_summary' => l10n.chatToolSummary,
        'get_training_guidance' => l10n.chatToolGuidance,
        'sync_from_intervals' => l10n.chatToolSyncing,
        'get_training_plan' => l10n.chatToolPlanRead,
        'search_app_features' => l10n.chatToolAppSearch,
        'open_app_page' => l10n.chatToolOpenPage,
        'propose_load_curve' ||
        'propose_session_change' ||
        'generate_training_plan' => l10n.chatToolProposing,
        _ => l10n.toolRunningGeneric(name),
      };

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        if (_messages.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.messagesCount(_messages.length),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _isBusy ? null : _newChat,
                  icon: const Icon(Icons.add_comment_outlined, size: 18),
                  label: Text(l10n.newChatButton),
                ),
              ],
            ),
          ),
        // The multi-day fatigue early warning, when the data calls for it.
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: FatigueWarningBanner(service: widget.fatigueService),
        ),
        Expanded(
          child: _messages.isEmpty
              ? _EmptyState(
                  configured: _settings.isConfigured,
                  needsConsent: _settings.needsConsent,
                  onSuggestion: _sendText,
                  facts: _facts,
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) =>
                      _MessageWithProposals(message: _messages[index]),
                ),
        ),
        if (_activity != null) _ActivityLine(label: _activity!),
        if (_topic != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: InputChip(
                key: const ValueKey('chat-topic'),
                avatar: const Icon(Icons.fact_check_outlined, size: 18),
                label: Text(l10n.chatAbout(_topic!.title)),
                onDeleted: _isBusy
                    ? null
                    : () => setState(() {
                        _topic = null;
                        _agent?.attachedContext = null;
                      }),
              ),
            ),
          ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const ValueKey('chat-input'),
                    controller: _controller,
                    enabled: _canSend,
                    decoration: InputDecoration(
                      hintText: l10n.messageAgentHint,
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                if (_isBusy)
                  IconButton.filledTonal(
                    key: const ValueKey('chat-stop'),
                    onPressed: _stop,
                    tooltip: l10n.chatStop,
                    icon: const Icon(Icons.stop_rounded),
                  )
                else
                  IconButton.filled(
                    key: const ValueKey('chat-send'),
                    onPressed: _canSend ? _send : null,
                    icon: const Icon(Icons.send_rounded),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.configured,
    required this.onSuggestion,
    this.facts = const StarterFacts(),
    this.needsConsent = false,
  });

  final StarterFacts facts;

  final bool configured;

  /// A provider is set up but the athlete hasn't agreed to data being sent.
  final bool needsConsent;

  /// Tapping a starter question sends it, so a blank screen isn't the first
  /// thing an athlete has to think of a question for.
  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: inkDecoration(context, shape: BoxShape.circle),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              configured ? l10n.askAboutTraining : l10n.obSetupTrainerTitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (needsConsent) ...[
              const SizedBox(height: 16),
              const AiConsentCard(),
            ] else if (!configured) ...[
              const SizedBox(height: 16),
              Text(
                l10n.obSetupTrainerBody,
                key: const ValueKey('chat-setup-body'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (i, label) in [
                    l10n.obProviderClaude,
                    l10n.obProviderOpenAI,
                    l10n.obProviderOllama,
                  ].indexed)
                    (i == 0 ? FilledButton.tonal : OutlinedButton.new)(
                      key: ValueKey('chat-setup-provider-$i'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsGroupScreen(
                            group: SettingsGroup.ai,
                          ),
                        ),
                      ),
                      child: Text(label),
                    ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (facts.missedDate case final d?)
                    ActionChip(
                      key: const ValueKey('starter-missed'),
                      label: Text(l10n.starterMissed(_dayName(context, d))),
                      onPressed: () => onSuggestion(
                        l10n.starterMissedText(_dayName(context, d)),
                      ),
                    ),
                  if (facts.formIsLow)
                    ActionChip(
                      key: const ValueKey('starter-form'),
                      label: Text(
                        l10n.starterForm(facts.form!.round().toString()),
                      ),
                      onPressed: () => onSuggestion(
                        l10n.starterFormText(facts.form!.round().toString()),
                      ),
                    ),
                  if (facts.missedDate == null && !facts.formIsLow)
                    for (final suggestion in [
                      l10n.chatSuggestionLastWeek,
                      l10n.chatSuggestionRecovered,
                      l10n.chatSuggestionIntensity,
                    ])
                      ActionChip(
                        label: Text(suggestion),
                        onPressed: () => onSuggestion(suggestion),
                      ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (key, label, text) in [
                    ('sick', l10n.chipSick, l10n.chipSickText),
                    ('travel', l10n.chipTravel, l10n.chipTravelText),
                    ('short', l10n.chipShortOnTime, l10n.chipShortText),
                  ])
                    ActionChip(
                      key: ValueKey('chip-$key'),
                      avatar: const Icon(Icons.bolt, size: 16),
                      label: Text(label),
                      onPressed: () => onSuggestion(text),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The "what the agent is doing right now" line under the transcript.
class _ActivityLine extends StatelessWidget {
  const _ActivityLine({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final TranscriptMessage message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fromUser = message.fromUser;

    final avatar = Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: message.isError
            ? colorScheme.errorContainer
            : fromUser
            ? colorScheme.surfaceContainerHighest
            : inkDecoration(context).color,
      ),
      child: Icon(
        message.isError
            ? Icons.error_outline
            : fromUser
            ? Icons.person
            : Icons.auto_awesome,
        size: 16,
        color: message.isError
            ? colorScheme.onErrorContainer
            : fromUser
            ? colorScheme.onSurfaceVariant
            : Colors.white,
      ),
    );

    final bubble = Flexible(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: message.isError
              ? colorScheme.errorContainer
              : fromUser
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(fromUser ? 16 : 4),
            bottomRight: Radius.circular(fromUser ? 4 : 16),
          ),
        ),
        child: !fromUser && !message.isError
            ? _ReplyContent(message: message)
            : SelectableText(
                message.text,
                style: message.isError
                    ? TextStyle(color: colorScheme.onErrorContainer)
                    : null,
              ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: fromUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: fromUser
            ? [bubble, const SizedBox(width: 8), avatar]
            : [avatar, const SizedBox(width: 8), bubble],
      ),
    );
  }
}

/// A message bubble with, for a reply, the proposals it made underneath.
class _MessageWithProposals extends StatelessWidget {
  const _MessageWithProposals({required this.message});

  final TranscriptMessage message;

  @override
  Widget build(BuildContext context) {
    if (message.redFlags.isNotEmpty) {
      return _RedFlagCard(flags: message.redFlags);
    }
    if (message.proposals.isEmpty && message.navigations.isEmpty) {
      return _ChatBubble(message: message);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ChatBubble(message: message),
        for (final p in message.proposals) ProposalCard(proposal: p),
        for (final id in message.navigations) NavigationCard(destinationId: id),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// A reply's body: the switch notes (if the first model failed), the
/// markdown, and the chip naming the model that answered.
class _ReplyContent extends StatelessWidget {
  const _ReplyContent({required this.message});

  final TranscriptMessage message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontStyle: FontStyle.italic,
    );
    final answeredBy = message.answeredBy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final note in message.switchNotes)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              key: const ValueKey('chat-model-switched'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.swap_horiz,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(note, style: muted)),
              ],
            ),
          ),
        if (message.text.isNotEmpty || message.switchNotes.isEmpty)
          MarkdownReply(text: message.text),
        if (message.dietConcerns.isNotEmpty) const _DietNote(),
        if (message.text.isNotEmpty) _ReplyMeta(message: message),
        if (answeredBy != null && message.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Semantics(
              container: true,
              label: l10n.chatAnsweredBy(answeredBy),
              excludeSemantics: true,
              child: Container(
                key: const ValueKey('chat-answered-by'),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_outlined,
                      size: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        answeredBy,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The data tools whose results an answer is built from, as plain nouns.
/// Tools that only act (propose, open a page, sync, remember) are not
/// sources.
String? toolSourceLabel(AppLocalizations l10n, String tool) => switch (tool) {
  'get_athlete_context' => l10n.chatSrcAthlete,
  'get_daily_metrics' => l10n.chatSrcMetrics,
  'get_activities' => l10n.chatSrcActivities,
  'get_planned_workouts' => l10n.chatSrcPlanned,
  'get_training_summary' => l10n.chatSrcSummary,
  'get_training_guidance' => l10n.chatSrcGuidance,
  'get_training_plan' => l10n.chatSrcPlan,
  'get_readiness' => l10n.chatSrcReadiness,
  'get_fatigue_warning' => l10n.chatSrcFatigue,
  'get_fitness_forecast' => l10n.chatSrcForecast,
  'get_health_status' => l10n.chatSrcHealth,
  'get_performance_curve' => l10n.chatSrcCurves,
  'get_plan_adjustments' => l10n.chatSrcAdjust,
  'get_race_prediction' => l10n.chatSrcRace,
  'get_threshold_suggestions' => l10n.chatSrcThresholds,
  'get_weekly_review' => l10n.chatSrcWeekly,
  'get_bricks' => l10n.chatSrcBricks,
  'get_session_template' => l10n.chatSrcTemplate,
  _ => null,
};

/// Under a reply: what it is based on (one tap shows the sources and how
/// fresh the data was), what it used in tokens and, with a price, about
/// what it cost; and a note when the athlete stopped it.
class _ReplyMeta extends StatefulWidget {
  const _ReplyMeta({required this.message});

  final TranscriptMessage message;

  @override
  State<_ReplyMeta> createState() => _ReplyMetaState();
}

class _ReplyMetaState extends State<_ReplyMeta> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final m = widget.message;
    final muted = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final sources = <String>[
      for (final t in m.toolsUsed) ?toolSourceLabel(l10n, t),
    ];
    final usage = m.usage;
    String? usageLine;
    if (usage != null) {
      final tokens = formatTokens(usage.totalTokens);
      final cost = UsageLedger.instance.prices.costOf(usage);
      usageLine = usage.local
          ? l10n.chatUsageLocal(tokens)
          : cost == null
          ? l10n.chatUsageNoPrice(tokens)
          : l10n.chatUsageCost(tokens, formatCost(cost));
    }
    final asOf = m.dataAsOf;
    final when = asOf == null
        ? null
        : DateFormat.MMMd(locale).add_Hm().format(asOf);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            key: const ValueKey('chat-based-on'),
            borderRadius: BorderRadius.circular(6),
            onTap: sources.isEmpty
                ? null
                : () => setState(() => _open = !_open),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    sources.isEmpty
                        ? l10n.chatBasedOnNothing
                        : l10n.chatBasedOn(sources.join(', ')),
                    maxLines: _open ? null : 1,
                    overflow: _open ? null : TextOverflow.ellipsis,
                    style: muted,
                  ),
                ),
                if (sources.isNotEmpty)
                  Icon(
                    _open ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
          if (_open && when != null)
            Text(
              l10n.chatDataAsOf(when),
              key: const ValueKey('chat-data-as-of'),
              style: muted,
            ),
          if (usageLine != null)
            Text(usageLine, key: const ValueKey('chat-usage'), style: muted),
          if (m.stopped)
            Text(
              l10n.chatStopped,
              key: const ValueKey('chat-stopped'),
              style: muted,
            ),
        ],
      ),
    );
  }
}

/// Shown at once under a message whose words suggest something that needs a
/// doctor rather than a training tip. It does not replace the trainer's
/// reply and does not judge: it says what to do and that TriIQ cannot.
class _RedFlagCard extends StatelessWidget {
  const _RedFlagCard({required this.flags});

  final List<RedFlag> flags;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    String label(RedFlag f) => switch (f) {
      RedFlag.chestPain => l10n.redFlagChestPain,
      RedFlag.fainting => l10n.redFlagFainting,
      RedFlag.breathing => l10n.redFlagBreathing,
      RedFlag.palpitations => l10n.redFlagPalpitations,
      RedFlag.disorderedEating => l10n.redFlagEating,
      RedFlag.pregnancy => l10n.redFlagPregnancy,
      RedFlag.severePain => l10n.redFlagSeverePain,
    };
    return Card(
      key: const ValueKey('red-flag-card'),
      color: scheme.errorContainer,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.health_and_safety_outlined,
              color: scheme.onErrorContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.redFlagTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: scheme.onErrorContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.redFlagBody(flags.map(label).join(', ')),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _dayName(BuildContext context, DateTime d) =>
    DateFormat.EEEE(Localizations.localeOf(context).toString()).format(d);

/// Under a reply that set a calorie or weight target, a deficit or
/// fasting: TriIQ does not give diet targets, whatever the model wrote.
class _DietNote extends StatelessWidget {
  const _DietNote();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      key: const ValueKey('diet-note'),
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(DesignRadius.panel),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.no_food_outlined,
            size: 20,
            color: theme.colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.dietNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
