import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/data/feel_settings.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('defaults to prompting on', () async {
    final settings = FeelSettings.forTesting();
    await settings.load();

    expect(settings.promptOnNewActivity, isTrue);
  });

  test('turning it off persists across a fresh load', () async {
    final settings = FeelSettings.forTesting();
    await settings.setPromptOnNewActivity(false);

    final again = FeelSettings.forTesting();
    await again.load();

    expect(again.promptOnNewActivity, isFalse);
  });
}
