import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/widgets/charts/chart_viewport.dart';

void main() {
  test('starts showing everything', () {
    final v = ChartViewport(length: 101);
    expect(v.lo, 0);
    expect(v.hi, 100);
    expect(v.isZoomed, isFalse);
  });

  test('zoom keeps the anchor in place and stays inside the data', () {
    final v = ChartViewport(length: 101)..zoomAt(4, 0.5);
    expect(v.span, closeTo(25, 1e-9));
    expect(v.lo + v.span / 2, closeTo(50, 1e-9));
    v.zoomAt(1000, 0.5);
    expect(v.span, ChartViewport.minPoints - 1);
    v.zoomAt(0.0001, 0.5);
    expect(v.lo, 0);
    expect(v.hi, 100);
  });

  test('pan is clamped to the data and reset restores the full range', () {
    final v = ChartViewport(length: 101)..zoomAt(4, 0);
    v.panByFraction(-10);
    expect(v.hi, 100);
    v.panByFraction(10);
    expect(v.lo, 0);
    v.reset();
    expect(v.isZoomed, isFalse);
  });
}
