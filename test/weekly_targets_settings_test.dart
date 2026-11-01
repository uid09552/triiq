import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/screens/settings/weekly_targets_settings.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('WeeklyTargetsSettings', () {
    test('defaults to no targets and shown on Today', () async {
      final settings = WeeklyTargetsSettings.forTesting();
      await settings.load();

      expect(settings.swimHours, isNull);
      expect(settings.cycleHours, isNull);
      expect(settings.runHours, isNull);
      expect(settings.showOnToday, isTrue);
      expect(settings.hasAnyTarget, isFalse);
    });

    test('targets persist across a fresh load', () async {
      final settings = WeeklyTargetsSettings.forTesting();
      await settings.setSwimHours(2.5);
      await settings.setCycleHours(4);
      await settings.setRunHours(3);
      await settings.setShowOnToday(false);

      final again = WeeklyTargetsSettings.forTesting();
      await again.load();

      expect(again.swimHours, 2.5);
      expect(again.cycleHours, 4);
      expect(again.runHours, 3);
      expect(again.showOnToday, isFalse);
      expect(again.hasAnyTarget, isTrue);
    });

    test('0 and negative values normalize to unset', () async {
      final settings = WeeklyTargetsSettings.forTesting();
      await settings.setSwimHours(0);
      await settings.setCycleHours(-1);

      expect(settings.swimHours, isNull);
      expect(settings.cycleHours, isNull);

      final again = WeeklyTargetsSettings.forTesting();
      await again.load();
      expect(again.swimHours, isNull);
      expect(again.cycleHours, isNull);
    });

    test('clearing a target with null removes it', () async {
      final settings = WeeklyTargetsSettings.forTesting();
      await settings.setRunHours(5);
      await settings.setRunHours(null);

      final again = WeeklyTargetsSettings.forTesting();
      await again.load();
      expect(again.runHours, isNull);
    });
  });
}
