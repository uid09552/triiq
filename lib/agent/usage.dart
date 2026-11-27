import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/clock.dart';

/// Tokens one reply used, with the model entry that served it. The chat
/// shows it under the reply; [UsageLedger] adds it to the month's total.
class TurnUsage {
  const TurnUsage({
    required this.inputTokens,
    required this.outputTokens,
    required this.model,
    required this.local,
  });

  final int inputTokens;
  final int outputTokens;

  /// The model name as the provider knows it (`claude-sonnet-4-5`, …).
  final String model;

  /// Served by a local or private-network server: nothing to pay.
  final bool local;

  int get totalTokens => inputTokens + outputTokens;

  Map<String, dynamic> toJson() => {
    'in': inputTokens,
    'out': outputTokens,
    'model': model,
    'local': local,
  };

  static TurnUsage? fromJson(Object? json) {
    if (json is! Map) return null;
    final i = json['in'], o = json['out'], m = json['model'];
    if (i is! num || o is! num || m is! String) return null;
    return TurnUsage(
      inputTokens: i.toInt(),
      outputTokens: o.toInt(),
      model: m,
      local: json['local'] == true,
    );
  }
}

/// US dollars per million tokens, input and output.
class ModelPrice {
  const ModelPrice(this.inputPerMillion, this.outputPerMillion);

  final double inputPerMillion;
  final double outputPerMillion;

  double costOf(int inputTokens, int outputTokens) =>
      inputTokens / 1e6 * inputPerMillion +
      outputTokens / 1e6 * outputPerMillion;

  Map<String, dynamic> toJson() => {
    'in': inputPerMillion,
    'out': outputPerMillion,
  };

  static ModelPrice? fromJson(Object? json) {
    if (json is! Map) return null;
    final i = json['in'], o = json['out'];
    if (i is! num || o is! num) return null;
    return ModelPrice(i.toDouble(), o.toDouble());
  }
}

/// What a model costs, for the estimate under a reply.
///
/// The built-in list only knows a few Claude families whose public list
/// prices are well established; any other model is shown as tokens only
/// until the athlete sets a price (prices change, and a wrong figure is
/// worse than none). An override always wins. Everything is an estimate:
/// it ignores prompt-caching discounts and any account-specific pricing.
class PriceTable {
  PriceTable({Map<String, ModelPrice> overrides = const {}})
    : _overrides = Map.of(overrides);

  final Map<String, ModelPrice> _overrides;

  Map<String, ModelPrice> get overrides => Map.unmodifiable(_overrides);

  void setOverride(String model, ModelPrice? price) {
    if (price == null) {
      _overrides.remove(model);
    } else {
      _overrides[model] = price;
    }
  }

  /// The price of [model], or `null` when unknown.
  ModelPrice? priceOf(String model) {
    final override = _overrides[model];
    if (override != null) return override;
    final m = model.toLowerCase();
    // Newest first: "opus-4-5" must not fall into the older Opus price.
    for (final (pattern, price) in _defaults) {
      if (pattern.hasMatch(m)) return price;
    }
    return null;
  }

  static final _defaults = <(RegExp, ModelPrice)>[
    (RegExp(r'opus-4-5'), const ModelPrice(5, 25)),
    (RegExp(r'opus'), const ModelPrice(15, 75)),
    (RegExp(r'haiku-4-5'), const ModelPrice(1, 5)),
    (RegExp(r'3-5-haiku|haiku-3-5'), const ModelPrice(0.8, 4)),
    (RegExp(r'sonnet-(3|4)'), const ModelPrice(3, 15)),
    (RegExp(r'3-5-sonnet|3-7-sonnet'), const ModelPrice(3, 15)),
  ];

  /// The estimated cost of [usage] in US dollars: 0 for a local model,
  /// `null` when the model's price is unknown.
  double? costOf(TurnUsage usage) {
    if (usage.local) return 0;
    return priceOf(usage.model)?.costOf(usage.inputTokens, usage.outputTokens);
  }
}

/// This month's tokens and estimated cost per model, kept on the device
/// (shared preferences) and rolled over when the month changes. Nothing
/// here leaves the device, and it is not part of a backup.
class UsageLedger extends ChangeNotifier {
  UsageLedger._({DateTime Function()? clock, PriceTable? prices})
    : _clock = clock ?? clockNow,
      prices = prices ?? PriceTable();

  static final UsageLedger instance = UsageLedger._();

  @visibleForTesting
  factory UsageLedger.forTesting({DateTime Function()? clock}) =>
      UsageLedger._(clock: clock);

  static const prefsKey = 'usage.ledger';
  static const pricesKey = 'usage.prices';

  final DateTime Function() _clock;
  final PriceTable prices;

  /// `YYYY-MM` the totals belong to.
  String _month = '';
  final _tokens = <String, (int, int)>{};
  final _local = <String>{};
  bool isLoaded = false;

  String _monthOf(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  /// Models used this month with their (input, output) tokens.
  Map<String, (int, int)> get byModel => Map.unmodifiable(_tokens);

  bool isLocalModel(String model) => _local.contains(model);

  int get totalTokens => _tokens.values.fold(0, (s, t) => s + t.$1 + t.$2);

  /// The month's estimated cost, and whether some model had no price (so
  /// the figure is a lower bound).
  (double, bool) get cost {
    var sum = 0.0;
    var incomplete = false;
    for (final e in _tokens.entries) {
      if (_local.contains(e.key)) continue;
      final price = prices.priceOf(e.key);
      if (price == null) {
        incomplete = true;
      } else {
        sum += price.costOf(e.value.$1, e.value.$2);
      }
    }
    return (sum, incomplete);
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(prefsKey);
      if (raw != null) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        _month = json['month'] as String? ?? '';
        _tokens.clear();
        _local.clear();
        for (final e in (json['models'] as Map? ?? const {}).entries) {
          final v = e.value as Map;
          _tokens[e.key as String] = (
            (v['in'] as num).toInt(),
            (v['out'] as num).toInt(),
          );
          if (v['local'] == true) _local.add(e.key as String);
        }
      }
      final rawPrices = prefs.getString(pricesKey);
      if (rawPrices != null) {
        final json = jsonDecode(rawPrices) as Map<String, dynamic>;
        for (final e in json.entries) {
          final p = ModelPrice.fromJson(e.value);
          if (p != null) prices.setOverride(e.key, p);
        }
      }
    } catch (error) {
      debugPrint('UsageLedger: cannot read stored usage: $error');
    } finally {
      _rollMonth();
      isLoaded = true;
      notifyListeners();
    }
  }

  void _rollMonth() {
    final now = _monthOf(_clock());
    if (_month != now) {
      _month = now;
      _tokens.clear();
      _local.clear();
    }
  }

  /// Adds one reply's tokens to this month.
  Future<void> record(TurnUsage usage) async {
    _rollMonth();
    final before = _tokens[usage.model] ?? (0, 0);
    _tokens[usage.model] = (
      before.$1 + usage.inputTokens,
      before.$2 + usage.outputTokens,
    );
    if (usage.local) _local.add(usage.model);
    notifyListeners();
    await _save();
  }

  Future<void> setPrice(String model, ModelPrice? price) async {
    prices.setOverride(model, price);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        pricesKey,
        jsonEncode({
          for (final e in prices.overrides.entries) e.key: e.value.toJson(),
        }),
      );
    } catch (error) {
      debugPrint('UsageLedger: cannot persist prices: $error');
    }
  }

  Future<void> reset() async {
    _tokens.clear();
    _local.clear();
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        prefsKey,
        jsonEncode({
          'month': _month,
          'models': {
            for (final e in _tokens.entries)
              e.key: {
                'in': e.value.$1,
                'out': e.value.$2,
                'local': _local.contains(e.key),
              },
          },
        }),
      );
    } catch (error) {
      debugPrint('UsageLedger: cannot persist usage: $error');
    }
  }
}

/// "340" / "1.2k" / "2.5M" for a token count.
String formatTokens(int tokens) => tokens >= 1000000
    ? '${(tokens / 1e6).toStringAsFixed(1)}M'
    : tokens >= 1000
    ? '${(tokens / 1000).toStringAsFixed(1)}k'
    : '$tokens';

/// "$0.03" for a cost, with more digits for tiny amounts.
String formatCost(double dollars) => dollars < 0.01 && dollars > 0
    ? '<\$0.01'
    : '\$${dollars.toStringAsFixed(dollars < 1 ? 3 : 2)}';
