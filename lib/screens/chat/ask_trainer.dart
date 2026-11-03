import 'package:flutter/material.dart';

import '../../agent/chat_handoff.dart';
import '../../widgets/main_navigation.dart';

/// Hands [topic] to Chat and switches to it: the topic's [ChatTopic.context]
/// goes to the agent, its [ChatTopic.draft] lands in the input field ready
/// to send or edit (never sent on the athlete's behalf).
///
/// Closes any screens pushed over the shell first, so the Chat tab is what
/// the athlete sees.
void askTrainer(BuildContext context, ChatTopic topic) {
  ChatHandoff.instance.open(topic);
  Navigator.of(context).popUntil((route) => route.isFirst);
  MainNavigation.instance.openTab(MainNavigation.chatTab);
}
