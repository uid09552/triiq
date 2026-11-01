import 'package:flutter/foundation.dart';

/// Something another screen wants the chat to talk about — a session and
/// its evaluation, say. The chat attaches [context] to the agent's system
/// context (not as a message from the athlete) and shows [title] so it's
/// clear what the next question is about.
class ChatTopic {
  const ChatTopic({required this.title, required this.context, this.draft});

  final String title;
  final String context;

  /// A question put in the input field for the athlete to send or edit —
  /// never sent on their behalf.
  final String? draft;
}

/// Hands a [ChatTopic] to the Chat tab. `ChatScreen` listens and takes it.
class ChatHandoff extends ChangeNotifier {
  ChatHandoff._();

  static final ChatHandoff instance = ChatHandoff._();

  ChatTopic? _pending;

  void open(ChatTopic topic) {
    _pending = topic;
    notifyListeners();
  }

  /// The waiting topic, once; `null` after it was taken.
  ChatTopic? take() {
    final t = _pending;
    _pending = null;
    return t;
  }
}
