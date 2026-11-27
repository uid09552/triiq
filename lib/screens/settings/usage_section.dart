import 'package:flutter/material.dart';

import '../../agent/usage.dart';
import '../../l10n/app_localizations.dart';

/// Settings → AI trainer → Usage: this month's tokens and estimated cost
/// per model, kept on this device. Prices are estimates from list prices;
/// a model with no known price shows tokens only until a price is set here.
class UsageSection extends StatelessWidget {
  UsageSection({super.key, UsageLedger? ledger})
    : ledger = ledger ?? UsageLedger.instance;

  final UsageLedger ledger;

  Future<void> _setPrice(BuildContext context, String model) async {
    final result = await showDialog<_PriceResult>(
      context: context,
      builder: (context) => _PriceDialog(
        model: model,
        current: ledger.prices.priceOf(model),
        canClear: ledger.prices.overrides.containsKey(model),
      ),
    );
    switch (result) {
      case _PriceResult(clear: true):
        await ledger.setPrice(model, null);
      case _PriceResult(:final price?):
        await ledger.setPrice(model, price);
      case _:
        break;
    }
  }

  Future<void> _reset(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.usageResetTitle),
        content: Text(l10n.usageResetBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.usageReset),
          ),
        ],
      ),
    );
    if (ok == true) await ledger.reset();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return ListenableBuilder(
      listenable: ledger,
      builder: (context, _) {
        final models = ledger.byModel;
        final (cost, incomplete) = ledger.cost;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.usageIntro, style: muted),
            const SizedBox(height: 12),
            if (models.isEmpty)
              Text(
                l10n.usageNothing,
                key: const ValueKey('usage-empty'),
                style: theme.textTheme.bodyMedium,
              )
            else ...[
              for (final e in models.entries)
                _ModelRow(
                  model: e.key,
                  inputTokens: e.value.$1,
                  outputTokens: e.value.$2,
                  local: ledger.isLocalModel(e.key),
                  price: ledger.prices.priceOf(e.key),
                  onSetPrice: () => _setPrice(context, e.key),
                ),
              const Divider(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.usageMonthTotal,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  Text(
                    incomplete
                        ? l10n.usageAtLeast(formatCost(cost))
                        : formatCost(cost),
                    key: const ValueKey('usage-total'),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  key: const ValueKey('usage-reset'),
                  onPressed: () => _reset(context),
                  child: Text(l10n.usageReset),
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(l10n.usageNote, style: muted),
          ],
        );
      },
    );
  }
}

/// What the price dialog returns: a new price, or [clear] to go back to the
/// built-in one.
class _PriceResult {
  const _PriceResult({this.price, this.clear = false});

  final ModelPrice? price;
  final bool clear;
}

class _PriceDialog extends StatefulWidget {
  const _PriceDialog({
    required this.model,
    required this.current,
    required this.canClear,
  });

  final String model;
  final ModelPrice? current;
  final bool canClear;

  @override
  State<_PriceDialog> createState() => _PriceDialogState();
}

class _PriceDialogState extends State<_PriceDialog> {
  late final _input = TextEditingController(
    text: widget.current == null ? '' : '${widget.current!.inputPerMillion}',
  );
  late final _output = TextEditingController(
    text: widget.current == null ? '' : '${widget.current!.outputPerMillion}',
  );

  @override
  void dispose() {
    _input.dispose();
    _output.dispose();
    super.dispose();
  }

  double? _parse(TextEditingController c) {
    final v = double.tryParse(c.text.trim().replaceAll(',', '.'));
    return v == null || v < 0 ? null : v;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.usagePriceTitle(widget.model)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.usagePriceHelp),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('usage-price-in'),
            controller: _input,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.usagePriceInput),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const ValueKey('usage-price-out'),
            controller: _output,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.usagePriceOutput),
          ),
        ],
      ),
      actions: [
        if (widget.canClear)
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(const _PriceResult(clear: true)),
            child: Text(l10n.usagePriceDefault),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(
          key: const ValueKey('usage-price-save'),
          onPressed: () {
            final i = _parse(_input), o = _parse(_output);
            Navigator.of(context).pop(
              i == null || o == null
                  ? null
                  : _PriceResult(price: ModelPrice(i, o)),
            );
          },
          child: Text(l10n.saveButton),
        ),
      ],
    );
  }
}

class _ModelRow extends StatelessWidget {
  const _ModelRow({
    required this.model,
    required this.inputTokens,
    required this.outputTokens,
    required this.local,
    required this.price,
    required this.onSetPrice,
  });

  final String model;
  final int inputTokens;
  final int outputTokens;
  final bool local;
  final ModelPrice? price;
  final VoidCallback onSetPrice;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final tokens = l10n.usageTokens(
      formatTokens(inputTokens),
      formatTokens(outputTokens),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        key: ValueKey('usage-row-$model'),
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(model, style: theme.textTheme.bodyMedium),
                Text(
                  tokens,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (local)
            Text(l10n.usageLocalFree)
          else if (price == null)
            TextButton(
              key: ValueKey('usage-set-price-$model'),
              onPressed: onSetPrice,
              child: Text(l10n.usageSetPrice),
            )
          else ...[
            Text(
              formatCost(price!.costOf(inputTokens, outputTokens)),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            IconButton(
              key: ValueKey('usage-edit-price-$model'),
              tooltip: l10n.usageSetPrice,
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: onSetPrice,
            ),
          ],
        ],
      ),
    );
  }
}
