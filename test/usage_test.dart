import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/agent/usage.dart';

TurnUsage _u(String model, int i, int o, {bool local = false}) =>
    TurnUsage(inputTokens: i, outputTokens: o, model: model, local: local);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('PriceTable', () {
    final prices = PriceTable();

    test('known Claude families have a price, newest first', () {
      expect(prices.priceOf('claude-sonnet-4-5')!.outputPerMillion, 15);
      expect(prices.priceOf('claude-opus-4-5')!.inputPerMillion, 5);
      expect(prices.priceOf('claude-opus-4-1')!.inputPerMillion, 15);
      expect(prices.priceOf('claude-haiku-4-5')!.outputPerMillion, 5);
      expect(prices.priceOf('claude-3-5-haiku-latest')!.inputPerMillion, 0.8);
    });

    test('an unknown model has no guessed price; an override wins', () {
      final t = PriceTable();
      expect(t.priceOf('some-future-model'), isNull);
      expect(t.costOf(_u('some-future-model', 1000, 1000)), isNull);
      t.setOverride('some-future-model', const ModelPrice(2, 10));
      expect(t.costOf(_u('some-future-model', 1000000, 1000000)), 12);
      t.setOverride('claude-sonnet-4-5', const ModelPrice(1, 1));
      expect(t.priceOf('claude-sonnet-4-5')!.inputPerMillion, 1);
      t.setOverride('claude-sonnet-4-5', null);
      expect(t.priceOf('claude-sonnet-4-5')!.inputPerMillion, 3);
    });

    test('a local model costs nothing', () {
      expect(prices.costOf(_u('llama3', 5000, 5000, local: true)), 0);
    });
  });

  group('UsageLedger', () {
    test('adds up per model, persists and rolls over with the month', () async {
      var now = DateTime(2026, 11, 20);
      final ledger = UsageLedger.forTesting(clock: () => now);
      await ledger.load();
      await ledger.record(_u('claude-sonnet-4-5', 1000000, 100000));
      await ledger.record(_u('claude-sonnet-4-5', 1000000, 100000));
      await ledger.record(_u('llama3', 3000, 1000, local: true));
      expect(ledger.totalTokens, 2200000 + 4000);
      final (cost, incomplete) = ledger.cost;
      expect(cost, closeTo(2 * (3 + 1.5), 1e-9));
      expect(incomplete, isFalse);

      // A new run reads it back.
      final again = UsageLedger.forTesting(clock: () => now);
      await again.load();
      expect(again.byModel['claude-sonnet-4-5'], (2000000, 200000));
      expect(again.isLocalModel('llama3'), isTrue);

      // The next month starts at zero.
      now = DateTime(2026, 12, 1);
      final december = UsageLedger.forTesting(clock: () => now);
      await december.load();
      expect(december.totalTokens, 0);
    });

    test('a model without a price makes the total a lower bound', () async {
      final ledger = UsageLedger.forTesting(clock: () => DateTime(2026, 11, 1));
      await ledger.load();
      await ledger.record(_u('mystery', 1000, 1000));
      final (cost, incomplete) = ledger.cost;
      expect(cost, 0);
      expect(incomplete, isTrue);
      await ledger.setPrice('mystery', const ModelPrice(1, 1));
      expect(ledger.cost.$2, isFalse);
      // Prices are kept for the next run.
      final again = UsageLedger.forTesting(clock: () => DateTime(2026, 11, 1));
      await again.load();
      expect(again.prices.priceOf('mystery')!.inputPerMillion, 1);
    });

    test('reset empties the month', () async {
      final ledger = UsageLedger.forTesting(clock: () => DateTime(2026, 11, 1));
      await ledger.load();
      await ledger.record(_u('x', 10, 10));
      await ledger.reset();
      expect(ledger.totalTokens, 0);
    });
  });

  test('formatting', () {
    expect(formatTokens(340), '340');
    expect(formatTokens(1234), '1.2k');
    expect(formatCost(0.004), '<\$0.01');
    expect(formatCost(0.5), '\$0.500');
    expect(formatCost(12.345), '\$12.35');
  });
}
