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
    expect(s.timeOfDayOrder, isFalse);
    expect(s.allLoadTiles, isFalse);
  });

  test('order, visibility and the two options persist', () async {
    final s = TodayLayoutSettings.forTesting();
    await s.move(TodayLayoutSettings.defaultOrder.length - 1, 0);
    await s.setVisible(TodaySection.metrics, false);
    await s.setTimeOfDayOrder(true);
    await s.setAllLoadTiles(true);

    final fresh = TodayLayoutSettings.forTesting();
    await fresh.load();
    expect(fresh.order.first, TodayLayoutSettings.defaultOrder.last);
    expect(fresh.isVisible(TodaySection.metrics), isFalse);
    expect(fresh.timeOfDayOrder, isTrue);
    expect(fresh.allLoadTiles, isTrue);

    await fresh.reset();
    expect(fresh.order, TodayLayoutSettings.defaultOrder);
    expect(fresh.isVisible(TodaySection.metrics), isTrue);
    expect(fresh.timeOfDayOrder, isFalse);
  });

  group('migrating an older stored layout', () {
    test('a customized order keeps its relative order', () async {
      SharedPreferences.setMockInitialValues({
        'today.section_order': [
          'metrics',
          'athlete',
          'weeklyTargets',
          'readiness',
          'adjustments',
          'activities',
          'todaysTraining',
          'yearGoals',
          'thresholds',
          'tomorrowsTraining',
        ],
        'today.hidden_sections': ['tomorrowsTraining', 'yearGoals'],
      });
      final s = TodayLayoutSettings.forTesting();
      await s.load();
      expect(s.order, [
        TodaySection.metrics,
        TodaySection.athlete,
        TodaySection.thisWeek, // weekly targets (first of the merged two)
        TodaySection.weekRibbon, // new: after This week, as by default
        TodaySection.hero, // readiness
        TodaySection.attention, // adjustments
        TodaySection.activities,
        TodaySection.tomorrowsTraining,
      ]);
      expect(s.isVisible(TodaySection.thisWeek), isTrue);
      expect(s.isVisible(TodaySection.tomorrowsTraining), isFalse);
      expect(s.isVisible(TodaySection.weekRibbon), isTrue);

      // Saved in the new names, so the next start reads it as is.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('today.section_order'), [
        for (final x in s.order) x.name,
      ]);
    });

    test('a merged section shows when any of its old ones did', () {
      final m = TodayLayoutSettings.migrate(
        ['readiness', 'todaysTraining', 'weeklyTargets', 'yearGoals'],
        ['readiness', 'weeklyTargets', 'yearGoals'],
      );
      // Today's training was on: the hero stays, and so does This week
      // (its TSS-against-plan line lived there).
      expect(m.hidden.contains(TodaySection.hero), isFalse);
      expect(m.hidden.contains(TodaySection.thisWeek), isFalse);

      final off = TodayLayoutSettings.migrate(
        ['readiness', 'todaysTraining', 'weeklyTargets', 'yearGoals'],
        ['todaysTraining', 'weeklyTargets', 'yearGoals'],
      );
      expect(off.hidden, {TodaySection.thisWeek});
    });

    test('an untouched old default takes the new default order', () async {
      SharedPreferences.setMockInitialValues({
        'today.section_order': [
          'readiness',
          'todaysTraining',
          'adjustments',
          'metrics',
          'activities',
          'weeklyTargets',
          'yearGoals',
          'thresholds',
          'tomorrowsTraining',
          'athlete',
        ],
        'today.hidden_sections': [
          'weeklyTargets',
          'yearGoals',
          'thresholds',
          'tomorrowsTraining',
          'athlete',
        ],
      });
      final s = TodayLayoutSettings.forTesting();
      await s.load();
      expect(s.order, TodayLayoutSettings.defaultOrder);
      for (final x in [
        TodaySection.hero,
        TodaySection.weekRibbon,
        TodaySection.attention,
        TodaySection.thisWeek,
        TodaySection.metrics,
      ]) {
        expect(s.isVisible(x), isTrue, reason: x.name);
      }
      expect(s.isVisible(TodaySection.athlete), isFalse);
    });

    test('a current layout needs no migration', () {
      final m = TodayLayoutSettings.migrate([
        for (final s in TodaySection.values) s.name,
      ], const []);
      expect(m.changed, isFalse);
      expect(m.order, TodaySection.values);
    });
  });

  group('time-of-day order', () {
    final visible = [
      TodaySection.thisWeek,
      TodaySection.metrics,
      TodaySection.hero,
      TodaySection.activities,
      TodaySection.attention,
      TodaySection.tomorrowsTraining,
    ];

    test('off: as the athlete set it', () {
      expect(
        contextualTodayOrder(visible, DateTime(2026, 11, 4, 7), enabled: false),
        visible,
      );
    });

    test('morning: the hero and what needs attention first', () {
      expect(
        contextualTodayOrder(
          visible,
          DateTime(2026, 11, 4, 7),
          enabled: true,
        ).take(2),
        [TodaySection.hero, TodaySection.attention],
      );
    });

    test('evening: result, tomorrow and activities first', () {
      expect(
        contextualTodayOrder(
          visible,
          DateTime(2026, 11, 4, 19),
          enabled: true,
        ).take(3),
        [
          TodaySection.hero,
          TodaySection.tomorrowsTraining,
          TodaySection.activities,
        ],
      );
    });

    test('midday: unchanged', () {
      expect(
        contextualTodayOrder(visible, DateTime(2026, 11, 4, 14), enabled: true),
        visible,
      );
    });
  });
}
