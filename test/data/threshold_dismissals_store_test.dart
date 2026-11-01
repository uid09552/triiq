import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/data/threshold_dismissals_store.dart';
import 'package:triiq/evaluation/performance_curves.dart';
import 'package:triiq/evaluation/threshold_suggestions.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('defaults to no dismissals', () async {
    final store = ThresholdDismissalsStore.forTesting();
    await store.load();

    expect(store.all, isEmpty);
  });

  test('a dismissal persists across a fresh load', () async {
    final store = ThresholdDismissalsStore.forTesting();
    await store.dismiss(CurveSport.ride, ThresholdDirection.up, 262);

    final again = ThresholdDismissalsStore.forTesting();
    await again.load();

    final key = (CurveSport.ride, ThresholdDirection.up);
    expect(again.all[key]?.candidateValue, 262);
  });

  test('sport and direction are independent', () async {
    final store = ThresholdDismissalsStore.forTesting();
    await store.dismiss(CurveSport.ride, ThresholdDirection.up, 262);
    await store.dismiss(CurveSport.run, ThresholdDirection.down, 3.5);

    expect(store.all, hasLength(2));
    expect(store.all[(CurveSport.ride, ThresholdDirection.down)], isNull);
  });
}
