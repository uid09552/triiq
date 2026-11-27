import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/agent/ai_label.dart';
import 'package:triiq/navigation/app_destinations.dart';
import 'package:triiq/notifications/notification_taps.dart';
import 'package:triiq/notifications/push_budget.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('at most one a day and three a week', () async {
    var now = DateTime(2026, 11, 2, 9);
    final budget = PushBudget(clock: () => now);
    expect(await budget.take(), isTrue);
    expect(await budget.take(), isFalse); // same day
    for (var day = 3; day <= 4; day++) {
      now = DateTime(2026, 11, day, 9);
      expect(await budget.take(), isTrue);
      await budget.opened(); // read: no back-off
    }
    now = DateTime(2026, 11, 5, 9);
    expect(await budget.take(), isFalse); // fourth in seven days
    now = DateTime(2026, 11, 9, 10);
    expect(await budget.take(), isTrue); // the first one aged out
  });

  test('three ignored in a row: only every other day', () async {
    var now = DateTime(2026, 11, 2, 9);
    final budget = PushBudget(clock: () => now);
    for (var day = 2; day <= 4; day++) {
      now = DateTime(2026, 11, day, 9);
      expect(await budget.take(), isTrue);
    }
    // A week later the weekly cap is clear, but three went unread.
    now = DateTime(2026, 11, 10, 9);
    expect(await budget.take(), isTrue);
    now = DateTime(2026, 11, 11, 9, 30);
    expect(await budget.take(), isFalse); // back-off: one within 2 days
    await budget.opened();
    expect(await budget.take(), isTrue);
  });

  test('notification payloads open real app pages', () {
    for (final id in ['tab.chat', 'tab.today', 'more.sync']) {
      final target = openTargetOf(openPayload(id));
      expect(appDestinations.any((d) => d.id == target), isTrue, reason: id);
    }
    expect(openTargetOf('weekly_review:2026-11-02'), isNull);
  });

  test('AI-written text is labelled once', () {
    final once = withAiLabel('- 10m Z2');
    expect(once, endsWith(aiWrittenNote));
    expect(withAiLabel(once), once);
  });
}
