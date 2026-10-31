import 'package:flutter/foundation.dart';

/// Something another screen wants the chat to talk about — a session and
/// its evaluation, say. The chat attaches [context] to the agent's system
/// context (not as a message from the athlete) and shows [title] so it's
/// clear what the next question is about.
class ChatTopic {
  const ChatTopic({required this.title, required this.context});

  final String title;
  final String context;
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
