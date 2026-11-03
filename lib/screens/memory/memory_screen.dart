import 'package:flutter/material.dart';

import '../../agent/agent_memory.dart';
import '../../l10n/app_localizations.dart';

/// More → Trainer memory: everything the trainer remembers across chats,
/// with add and remove. Nothing is remembered that isn't listed here.
class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key, this.store});

  final AgentMemoryStore? store;

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  late final _store = widget.store ?? AgentMemoryStore.instance;
  final _input = TextEditingController();
  List<MemoryItem> _items = const [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _store.addListener(_reload);
    _reload();
  }

  @override
  void dispose() {
    _store.removeListener(_reload);
    _input.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final items = await _store.load();
    if (mounted) {
      setState(() {
        _items = items;
        _loaded = true;
      });
    }
  }

  Future<void> _add() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _store.add(_input.text);
      _input.clear();
    } on MemoryFullException {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.memoryFull(AgentMemoryStore.maxItems))),
      );
    }
  }

  Future<void> _clear() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.memoryClearConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            key: const ValueKey('memory-clear-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.memoryClear),
          ),
        ],
      ),
    );
    if (ok == true) await _store.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.memoryTitle),
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              key: const ValueKey('memory-clear'),
              tooltip: l10n.memoryClear,
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: _clear,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.memoryIntro, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('memory-input'),
                  controller: _input,
                  maxLength: AgentMemoryStore.maxLength,
                  decoration: InputDecoration(hintText: l10n.memoryAddHint),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _add(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                key: const ValueKey('memory-add'),
                onPressed: _add,
                child: Text(l10n.memoryAddButton),
              ),
            ],
          ),
          if (_items.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                l10n.memoryCount(_items.length, AgentMemoryStore.maxItems),
                style: theme.textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 8),
          if (_loaded && _items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text(l10n.memoryEmpty)),
            ),
          for (final item in _items)
            Card(
              key: ValueKey('memory-${item.id}'),
              child: ListTile(
                title: Text(item.text),
                subtitle: item.fromAgent ? Text(l10n.memoryFromTrainer) : null,
                trailing: IconButton(
                  tooltip: l10n.memoryDelete,
                  icon: const Icon(Icons.close),
                  onPressed: () => _store.remove(item.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
