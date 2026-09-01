import 'dart:async';

import 'package:flutter/material.dart';

import '../../agent/chat_model_factory.dart';
import '../../agent/llm_settings.dart';
import '../../agent/training_agent.dart';
import '../../l10n/app_localizations.dart';
import '../../notifications/app_lifecycle_tracker.dart';
import '../../notifications/notification_service.dart';
import '../../notifications/notification_settings.dart';
import '../../widgets/markdown_reply.dart';
import '../settings/settings_screen.dart';

class _ChatMessage {
  _ChatMessage({required this.fromUser, this.text = '', this.isError = false});

  /// Grows as the model streams, so this is the one mutable field.
  String text;
  final bool fromUser;
  final bool isError;
}

/// Chat with the training-analysis agent about your Intervals.icu data.
///
/// The agent ([TrainingAgent]) runs in-process: it talks to whichever LLM
/// provider is configured in Settings and reads the local cache through its
/// tools. This screen only renders the stream it emits — partial text as it
/// arrives, and a line naming each tool while it runs, so a question that
/// takes three round-trips doesn't look like a hang.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

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

  bool get _isBusy => _subscription != null;

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    _subscription?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Provider or credentials changed: drop the agent so the next message
  /// builds a fresh chat model. The transcript stays — it's the athlete's.
  void _onSettingsChanged() {
    _agent = null;
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
    });
  }

  void _sendText(String text) {
    _controller.text = text;
    _send();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || _isBusy) return;

    final reply = _ChatMessage(fromUser: false);
    setState(() {
      _messages
        ..add(_ChatMessage(fromUser: true, text: text))
        ..add(reply);
      _activity = AppLocalizations.of(context)!.thinkingEllipsis;
    });
    _controller.clear();
    _scrollToEnd();

    final agent = _agent ??= TrainingAgent();
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
      switch (event) {
        case AgentTextDelta(:final text):
          reply.text += text;
          _activity = null;
        case AgentToolStarted(:final name):
          _activity = _describeTool(l10n, name);
        case AgentToolFinished(:final name, :final failed):
          _activity = failed
              ? l10n.toolFailedSuffix(_describeTool(l10n, name))
              : null;
      }
    });
    _scrollToEnd();
  }

  void _finish(_ChatMessage reply, {Object? error}) {
    _subscription?.cancel();
    _subscription = null;
    setState(() {
      _activity = null;
      if (error != null) {
        if (reply.text.isEmpty) {
          _messages.remove(reply);
        }
        _messages.add(
          _ChatMessage(fromUser: false, isError: true, text: '$error'),
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
                  onSuggestion: _sendText,
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) =>
                      _ChatBubble(message: _messages[index]),
                ),
        ),
        if (_activity != null) _ActivityLine(label: _activity!),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !_isBusy,
                    decoration: InputDecoration(
                      hintText: l10n.messageAgentHint,
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isBusy ? null : _send,
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
  const _EmptyState({required this.configured, required this.onSuggestion});

  final bool configured;

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
              configured
                  ? l10n.askAboutTraining
                  : l10n.pickLlmProviderToChat,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (!configured) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
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
            ? MarkdownReply(text: message.text)
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
