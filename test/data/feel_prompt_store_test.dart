import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/data/feel_prompt_store.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('defaults to nothing prompted', () async {
    final store = FeelPromptStore.forTesting();
    await store.load();

    expect(store.hasPrompted('42'), isFalse);
  });

  test('recording a prompt persists across a fresh load', () async {
    final store = FeelPromptStore.forTesting();
    await store.recordPrompted('42');

    expect(store.hasPrompted('42'), isTrue);

    final again = FeelPromptStore.forTesting();
    await again.load();

    expect(again.hasPrompted('42'), isTrue);
    expect(again.hasPrompted('7'), isFalse);
  });
}
