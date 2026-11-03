import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/agent/chat_handoff.dart';
import 'package:triiq/screens/chat/ask_trainer.dart';
import 'package:triiq/widgets/main_navigation.dart';

void main() {
  testWidgets('hands the topic and its draft to Chat and opens the tab', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => askTrainer(
              context,
              const ChatTopic(
                title: 'Run',
                context: '{}',
                draft: 'How did my run go?',
              ),
            ),
            child: const Text('ask'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('ask'));
    await tester.pump();

    final topic = ChatHandoff.instance.take();
    expect(topic?.draft, 'How did my run go?');
    expect(MainNavigation.instance.requestedTab, MainNavigation.chatTab);
    expect(ChatHandoff.instance.take(), isNull);
  });
}
