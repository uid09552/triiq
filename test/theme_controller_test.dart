import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/theme_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('theme choice survives a restart', () async {
    SharedPreferences.setMockInitialValues({});
    final first = ThemeController.forTesting();
    await first.setChoice(AppThemeChoice.developer);

    final second = ThemeController.forTesting();
    expect(second.choice, AppThemeChoice.system);
    await second.load();
    expect(second.choice, AppThemeChoice.developer);
  });

  test('unknown stored value falls back to system', () async {
    SharedPreferences.setMockInitialValues({'theme.choice': 'bogus'});
    final c = ThemeController.forTesting();
    await c.load();
    expect(c.choice, AppThemeChoice.system);
  });
}
