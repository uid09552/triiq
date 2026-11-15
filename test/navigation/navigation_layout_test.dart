import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/navigation/navigation_layout.dart';
import 'package:triiq/screens/more/more_screen.dart';

void main() {
  final known = NavigationLayout.defaultKnown();
  const core = NavigationLayout.coreIds;
  final entries = [for (final e in moreEntries) e.id];

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('defaults and normalize', () {
    test('the default is the layout that shipped: core tabs in the bar, '
        'every More entry in More, in order', () {
      final layout = NavigationLayout.forTesting();
      expect(layout.bar, core);
      expect(layout.barWithMore, [...core, 'more']);
      expect(layout.more, entries);
      expect(layout.isDefault, isTrue);
      expect(NavigationLayout.normalize(null, null, known).bar, core);
    });

    test('unknown, duplicate and "more" ids are dropped; the bar wins a '
        'duplicate', () {
      final n = NavigationLayout.normalize(
        ['chat', 'gear', 'more', 'today', 'chat'],
        ['today', 'old-thing', ...entries, 'calendar', 'insights'],
        known,
      );
      expect(n.bar, ['chat', 'today']);
      expect(n.more, [...entries, 'calendar', 'insights']);
    });

    test('items new in this version: a core tab joins the bar when there is '
        'room, else More\'s top; a More entry is appended to More', () {
      // An older version without Insights and without Sync.
      final roomy = NavigationLayout.normalize(
        ['today', 'calendar', 'chat'],
        ['plan', 'season', 'events', 'memory', 'knowledge'],
        known,
      );
      expect(roomy.bar, ['today', 'calendar', 'chat', 'insights']);
      expect(roomy.more.last, 'info');
      expect(roomy.more, contains('sync'));

      final full = NavigationLayout.normalize(
        ['today', 'calendar', 'chat', 'plan'],
        ['season', 'events', 'memory', 'knowledge', 'sync'],
        known,
      );
      expect(full.bar, ['today', 'calendar', 'chat', 'plan']);
      expect(full.more.first, 'insights');
    });

    test('limits: a long bar spills onto More, a short one takes a core tab '
        'back from More first', () {
      final long = NavigationLayout.normalize(
        ['plan', 'today', 'calendar', 'chat', 'insights', 'sync'],
        ['season', 'events', 'memory', 'knowledge'],
        known,
      );
      expect(long.bar, ['plan', 'today', 'calendar', 'chat']);
      expect(long.more.take(2), ['insights', 'sync']);

      final short = NavigationLayout.normalize(
        ['gone'],
        ['plan', ...core, 'season', 'events', 'memory', 'knowledge', 'sync'],
        known,
      );
      expect(short.bar, ['today', 'calendar']);
      expect(short.more, isNot(contains('today')));
    });

    test('every known id ends up in exactly one list', () {
      final n = NavigationLayout.normalize(['sync', 'x'], ['y'], known);
      expect({...n.bar, ...n.more}, known.toSet());
      expect(n.bar.length + n.more.length, known.length);
    });
  });

  group('moves', () {
    test('reorder within the bar and within More', () async {
      final layout = NavigationLayout.forTesting();
      expect(await layout.shift('chat', -1), NavMoveResult.ok);
      expect(layout.bar, ['today', 'chat', 'calendar', 'insights']);
      expect(await layout.shift('today', -1), NavMoveResult.unchanged);
      expect(
        await layout.place('sync', inBar: false, index: 0),
        NavMoveResult.ok,
      );
      expect(layout.more.first, 'sync');
    });

    test(
      'moving an item between the bar and More updates both lists',
      () async {
        final layout = NavigationLayout.forTesting();
        expect(await layout.moveToMore('insights'), NavMoveResult.ok);
        expect(layout.bar, ['today', 'calendar', 'chat']);
        expect(layout.more.first, 'insights');
        expect(layout.isInBar('insights'), isFalse);

        expect(await layout.pinToBar('plan'), NavMoveResult.ok);
        expect(layout.bar, ['today', 'calendar', 'chat', 'plan']);
        expect(layout.more, isNot(contains('plan')));
        expect(layout.isInBar('plan'), isTrue);
        expect(layout.isInBar('more'), isTrue);
      },
    );

    test(
      'limits are enforced: at most 4 and at least 2 besides More',
      () async {
        final layout = NavigationLayout.forTesting();
        expect(await layout.pinToBar('plan'), NavMoveResult.barFull);
        expect(layout.bar, core);

        await layout.moveToMore('insights');
        await layout.moveToMore('chat');
        expect(layout.bar, ['today', 'calendar']);
        expect(await layout.moveToMore('today'), NavMoveResult.barMinimum);
        expect(layout.bar, ['today', 'calendar']);
        // Reordering a full or minimal bar is still fine.
        expect(await layout.shift('calendar', -1), NavMoveResult.ok);
        expect(layout.bar, ['calendar', 'today']);
      },
    );

    test('More itself and unknown ids cannot be moved', () async {
      final layout = NavigationLayout.forTesting();
      expect(await layout.moveToMore('more'), NavMoveResult.unchanged);
      expect(await layout.pinToBar('gear'), NavMoveResult.unchanged);
      expect(layout.isDefault, isTrue);
    });

    test('reset brings back the default', () async {
      final layout = NavigationLayout.forTesting();
      await layout.moveToMore('chat');
      await layout.pinToBar('sync');
      expect(layout.isDefault, isFalse);
      await layout.reset();
      expect(layout.isDefault, isTrue);
    });
  });

  group('persistence', () {
    test('nothing stored loads the default and writes nothing', () async {
      final layout = NavigationLayout.forTesting();
      await layout.load();
      expect(layout.isDefault, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList(NavigationLayout.barPref), isNull);
    });

    test('a change is saved and loaded back', () async {
      final layout = NavigationLayout.forTesting();
      await layout.moveToMore('calendar');
      await layout.pinToBar('season');
      await layout.shift('season', -1);

      final again = NavigationLayout.forTesting();
      await again.load();
      expect(again.bar, ['today', 'chat', 'season', 'insights']);
      expect(again.more.first, 'calendar');
    });

    test('a stored layout with stale ids is repaired once and saved', () async {
      SharedPreferences.setMockInitialValues({
        NavigationLayout.barPref: ['gear', 'plan', 'today'],
        NavigationLayout.morePref: ['calendar', 'x'],
      });
      final layout = NavigationLayout.forTesting();
      await layout.load();
      expect(layout.bar, ['plan', 'today', 'chat', 'insights']);
      expect(layout.more.first, 'calendar');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList(NavigationLayout.barPref), layout.bar);
      expect(prefs.getStringList(NavigationLayout.morePref), layout.more);
    });

    test('a stored value of the wrong type keeps the default', () async {
      SharedPreferences.setMockInitialValues({
        NavigationLayout.barPref: 'today',
      });
      final layout = NavigationLayout.forTesting();
      await layout.load();
      expect(layout.isDefault, isTrue);
    });

    test(
      'sanitizeStored repairs restored values and drops wrong types',
      () async {
        SharedPreferences.setMockInitialValues({
          NavigationLayout.barPref: ['sync', 'sync', 'nope'],
        });
        var prefs = await SharedPreferences.getInstance();
        await NavigationLayout.sanitizeStored(prefs);
        expect(prefs.getStringList(NavigationLayout.barPref), [
          'sync',
          'today',
          'calendar',
          'chat',
        ]);
        expect(
          prefs.getStringList(NavigationLayout.morePref),
          contains('insights'),
        );

        SharedPreferences.setMockInitialValues({NavigationLayout.barPref: 42});
        prefs = await SharedPreferences.getInstance();
        await NavigationLayout.sanitizeStored(prefs);
        expect(prefs.containsKey(NavigationLayout.barPref), isFalse);
      },
    );

    test('a custom catalogue (forTesting) is respected', () {
      final layout = NavigationLayout.forTesting(
        known: const ['today', 'chat', 'plan'],
      );
      expect(layout.bar, ['today', 'chat']);
      expect(layout.more, ['plan']);
    });
  });
}
