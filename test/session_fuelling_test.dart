import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/evaluation/session_fuelling.dart';

LocalEvent ev(int minutes, {int load = 60, String cat = 'WORKOUT'}) =>
    LocalEvent(
      id: '1',
      date: '2026-11-03',
      category: cat,
      type: 'Ride',
      name: 'Ride',
      description: null,
      plannedLoad: load,
      plannedTime: minutes * 60,
      plannedDistance: null,
      indoor: false,
      raw: const {},
      syncedAt: DateTime(2026),
    );

void main() {
  test('short sessions need nothing', () {
    expect(sessionFuelling(ev(60)), isNull);
    expect(sessionFuelling(ev(74)), isNull);
  });

  test('75–150 min: 30–60 g/h; longer: 60–90 g/h', () {
    expect(sessionFuelling(ev(90)), (low: 30, high: 60));
    expect(sessionFuelling(ev(180, load: 150)), (low: 60, high: 90));
  });

  test('a hard 2-hour session counts as long', () {
    expect(sessionFuelling(ev(120, load: 160)), (low: 60, high: 90));
  });

  test('notes are not sessions', () {
    expect(sessionFuelling(ev(200, cat: 'NOTE')), isNull);
  });
}
