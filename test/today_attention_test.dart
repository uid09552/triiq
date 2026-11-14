import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/today/attention_stack.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Widget stack(List<AttentionItem> items, List<AttentionKind> dismissed) =>
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: StatefulBuilder(
            // Like Today: a dismissed kind leaves the list.
            builder: (context, setState) => ListView(
              children: [
                AttentionStack(
                  items: [
                    for (final i in items)
                      if (!dismissed.contains(i.kind)) i,
                  ],
                  onDismiss: (k) => setState(() => dismissed.add(k)),
                ),
              ],
            ),
          ),
        ),
      );

  AttentionItem item(AttentionKind kind, int priority) => AttentionItem(
    kind: kind,
    priority: priority,
    child: Card(
      child: SizedBox(height: 60, child: Center(child: Text(kind.name))),
    ),
  );

  testWidgets('most important first, two visible, the rest behind +N', (
    t,
  ) async {
    final dismissed = <AttentionKind>[];
    await t.pumpWidget(
      stack([
        item(AttentionKind.thresholds, 5),
        item(AttentionKind.race, 4),
        item(AttentionKind.fatigue, 1),
        item(AttentionKind.adjustments, 2),
      ], dismissed),
    );
    expect(find.text('fatigue'), findsOneWidget);
    expect(find.text('adjustments'), findsOneWidget);
    expect(find.text('race'), findsNothing);
    expect(find.text('thresholds'), findsNothing);
    expect(
      t.getTopLeft(find.text('fatigue')).dy,
      lessThan(t.getTopLeft(find.text('adjustments')).dy),
    );
    expect(find.text('+2 more'), findsOneWidget);

    await t.tap(find.byKey(const ValueKey('attention-more')));
    await t.pump();
    expect(find.text('race'), findsOneWidget);
    expect(find.text('thresholds'), findsOneWidget);
    expect(find.text('Show less'), findsOneWidget);
  });

  testWidgets('nothing to say: nothing shown', (t) async {
    await t.pumpWidget(stack(const [], []));
    expect(find.byKey(const ValueKey('attention-stack')), findsNothing);
  });

  testWidgets('two items need no "more"; each can be closed or swiped', (
    t,
  ) async {
    final dismissed = <AttentionKind>[];
    await t.pumpWidget(
      stack([
        item(AttentionKind.race, 4),
        item(AttentionKind.health, 0),
      ], dismissed),
    );
    expect(find.byKey(const ValueKey('attention-more')), findsNothing);
    await t.tap(find.byKey(const ValueKey('attention-close-race')));
    await t.pump();
    expect(dismissed, [AttentionKind.race]);
    expect(find.text('race'), findsNothing);
    await t.drag(find.text('health'), const Offset(-500, 0));
    await t.pumpAndSettle();
    expect(dismissed, [AttentionKind.race, AttentionKind.health]);
  });

  test('a dismissal lasts for the day only', () async {
    final d = AttentionDismissals.forTesting();
    await d.load();
    final today = DateTime(2026, 11, 4, 9);
    await d.dismiss(AttentionKind.fatigue, today);
    expect(d.isDismissed(AttentionKind.fatigue, today), isTrue);
    expect(d.isDismissed(AttentionKind.race, today), isFalse);

    final again = AttentionDismissals.forTesting();
    await again.load();
    expect(again.isDismissed(AttentionKind.fatigue, today), isTrue);
    expect(
      again.isDismissed(AttentionKind.fatigue, DateTime(2026, 11, 5, 7)),
      isFalse,
    );
  });
}
