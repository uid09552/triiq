import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/agent/usage.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/settings/usage_section.dart';

void main() {
  late UsageLedger ledger;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    ledger = UsageLedger.forTesting(clock: () => DateTime(2026, 11, 20));
    await ledger.load();
  });

  Future<void> pump(WidgetTester t) => t.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: SingleChildScrollView(child: UsageSection(ledger: ledger)),
      ),
    ),
  );

  testWidgets('empty month says so', (t) async {
    await pump(t);
    expect(find.byKey(const ValueKey('usage-empty')), findsOneWidget);
  });

  testWidgets('shows tokens and cost per model, and the month total', (
    t,
  ) async {
    await t.runAsync(() async {
      await ledger.record(
        const TurnUsage(
          inputTokens: 2000000,
          outputTokens: 1000000,
          model: 'claude-sonnet-4-5',
          local: false,
        ),
      );
      await ledger.record(
        const TurnUsage(
          inputTokens: 5000,
          outputTokens: 1000,
          model: 'llama3',
          local: true,
        ),
      );
    });
    await pump(t);
    expect(find.byKey(const ValueKey('usage-row-claude-sonnet-4-5')), findsOne);
    expect(find.text('2.0M in · 1.0M out'), findsOneWidget);
    // 2 × 3 + 1 × 15 = $21; the local model adds nothing.
    expect(find.text('\$21.00'), findsWidgets);
    expect(find.text('local, free'), findsOneWidget);
    expect(find.byKey(const ValueKey('usage-total')), findsOneWidget);
  });

  testWidgets('a model without a price can be given one', (t) async {
    await t.runAsync(
      () => ledger.record(
        const TurnUsage(
          inputTokens: 1000000,
          outputTokens: 1000000,
          model: 'mystery',
          local: false,
        ),
      ),
    );
    await pump(t);
    expect(find.textContaining('at least'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('usage-set-price-mystery')));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const ValueKey('usage-price-in')), '2');
    await t.enterText(find.byKey(const ValueKey('usage-price-out')), '10');
    await t.tap(find.byKey(const ValueKey('usage-price-save')));
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await t.pumpAndSettle();
    expect(ledger.prices.priceOf('mystery')!.outputPerMillion, 10);
    expect(find.textContaining('at least'), findsNothing);
    expect(find.text('\$12.00'), findsWidgets);
  });

  testWidgets('reset asks first, then clears the month', (t) async {
    await t.runAsync(
      () => ledger.record(
        const TurnUsage(
          inputTokens: 10,
          outputTokens: 10,
          model: 'claude-sonnet-4-5',
          local: false,
        ),
      ),
    );
    await pump(t);
    await t.tap(find.byKey(const ValueKey('usage-reset')));
    await t.pumpAndSettle();
    expect(ledger.totalTokens, 20);
    await t.tap(find.widgetWithText(FilledButton, 'Reset'));
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await t.pumpAndSettle();
    expect(ledger.totalTokens, 0);
    expect(find.byKey(const ValueKey('usage-empty')), findsOneWidget);
  });
}
