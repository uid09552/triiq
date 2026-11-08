import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/screens/today/today_layout_settings.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a new install starts from the lean default', () async {
    final s = TodayLayoutSettings.forTesting();
    await s.load();
    expect(s.order, TodayLayoutSettings.defaultOrder);
    for (final section in TodaySection.values) {
      expect(
        s.isVisible(section),
        !TodayLayoutSettings.defaultHidden.contains(section),
        reason: section.name,
      );
    }
  });

  test('order and visibility persist across a fresh load', () async {
    final s = TodayLayoutSettings.forTesting();
    await s.move(TodayLayoutSettings.defaultOrder.length - 1, 0);
    await s.setVisible(TodaySection.metrics, false);

    final fresh = TodayLayoutSettings.forTesting();
    await fresh.load();
    expect(fresh.order.first, TodayLayoutSettings.defaultOrder.last);
    expect(fresh.isVisible(TodaySection.metrics), isFalse);

    await fresh.reset();
    expect(fresh.order, TodayLayoutSettings.defaultOrder);
    expect(fresh.isVisible(TodaySection.metrics), isTrue);
  });
}
