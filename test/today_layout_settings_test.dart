import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/screens/today/today_layout_settings.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('defaults to every section visible in declaration order', () async {
    final s = TodayLayoutSettings.forTesting();
    await s.load();
    expect(s.order, TodaySection.values);
    expect(TodaySection.values.every(s.isVisible), isTrue);
  });

  test('order and visibility persist across a fresh load', () async {
    final s = TodayLayoutSettings.forTesting();
    await s.move(TodaySection.values.length - 1, 0);
    await s.setVisible(TodaySection.metrics, false);

    final fresh = TodayLayoutSettings.forTesting();
    await fresh.load();
    expect(fresh.order.first, TodaySection.values.last);
    expect(fresh.isVisible(TodaySection.metrics), isFalse);

    await fresh.reset();
    expect(fresh.order, TodaySection.values);
    expect(fresh.isVisible(TodaySection.metrics), isTrue);
  });
}
