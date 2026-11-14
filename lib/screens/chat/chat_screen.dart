import 'dart:async';

import 'package:flutter/material.dart';

import '../../agent/chat_handoff.dart';
import '../../agent/chat_model_factory.dart';
import '../../agent/llm_settings.dart';
import '../../agent/plan_proposals.dart';
import '../../agent/training_agent.dart';
import '../../l10n/app_localizations.dart';
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

class _ChatMessage {
  _ChatMessage({required this.fromUser, this.text = '', this.isError = false});

  /// Grows as the model streams, so this is the one mutable field.
  String text;
  final bool fromUser;
  final bool isError;

  /// Changes the agent proposed during this reply, shown as cards under it.
  final proposals = <PlanProposal>[];

  /// App pages the agent offered to open (`open_app_page`), as buttons.
  final navigations = <String>[];

  /// The reply as streamed, minus any failed attempt's partial text.
  final buffer = AgentReplyBuffer();

  /// "Switched to … — … unreachable" notes, in order.
  final switchNotes = <String>[];

  /// The model entry that gave this reply (shown as a chip under it).
  String? answeredBy;
}

/// Chat with the training-analysis agent about your Intervals.icu data.
///
/// The agent ([TrainingAgent]) runs in-process: it talks to whichever LLM
/// provider is configured in Settings and reads the local cache through its
/// tools. This screen only renders the stream it emits — partial text as it
/// arrives, and a line naming each tool while it runs, so a question that
/// takes three round-trips doesn't look like a hang.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.agentFactory});

  /// Builds the agent (default [TrainingAgent.new]); for tests.
  final TrainingAgent Function()? agentFactory;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_ChatMessage>[];
  final _settings = LlmSettings.instance;

  TrainingAgent? _agent;
  StreamSubscription<AgentEvent>? _subscription;
  String? _activity;

  /// What the athlete came here to ask about (from "Ask the trainer"),
  /// attached to the agent's context rather than shown as a message.
  ChatTopic? _topic;

  bool get _isBusy => _subscription != null;

  /// The reply being streamed, so a withdrawn consent can end it.
  _ChatMessage? _streaming;

  /// Sending is off while models are set up but none is consented to.
  bool get _canSend => !_isBusy && !_settings.blockedByConsent;

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettingsChanged);
    ChatHandoff.instance.addListener(_takeTopic);
    _takeTopic();
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
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

    final reply = _ChatMessage(fromUser: false);
    setState(() {
      _messages
        ..add(_ChatMessage(fromUser: true, text: text))
        ..add(reply);
      _activity = AppLocalizations.of(context)!.thinkingEllipsis;
    });
    _controller.clear();
    _scrollToEnd();

    final agent = _agent ??= (widget.agentFactory ?? TrainingAgent.new)();
    agent.attachedContext = _topic?.context;
    _streaming = reply;
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

  void _onEvent(AgentEvent event, _ChatMessage reply) {
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

  void _finish(_ChatMessage reply, {Object? error}) {
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
          _ChatMessage(
            fromUser: false,
            isError: true,
            text: describeAgentError(error, AppLocalizations.of(context)!),
          ),
        );
      } else if (reply.text.isEmpty) {
        reply.text = AppLocalizations.of(context)!.noReplyFromModel;
      }
    });
    _scrollToEnd();
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
        Expanded(
          child: _messages.isEmpty
              ? _EmptyState(
                  configured: _settings.isConfigured,
                  needsConsent: _settings.needsConsent,
                  onSuggestion: _sendText,
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
    this.needsConsent = false,
  });

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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colorScheme.primary, colorScheme.tertiary],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              configured ? l10n.askAboutTraining : l10n.pickLlmProviderToChat,
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
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const SettingsGroupScreen(group: SettingsGroup.ai),
                  ),
                ),
                child: Text(l10n.openSettingsButton),
              ),
            ] else ...[
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
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

  final _ChatMessage message;

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
        gradient: fromUser || message.isError
            ? null
            : LinearGradient(
                colors: [colorScheme.primary, colorScheme.tertiary],
              ),
        color: message.isError
            ? colorScheme.errorContainer
            : fromUser
            ? colorScheme.surfaceContainerHighest
            : null,
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
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
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

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
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

  final _ChatMessage message;

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
