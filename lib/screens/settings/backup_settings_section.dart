import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/backup/backup_files.dart';
import '../../data/backup/backup_service.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/plan_changes.dart';
import '../../data/sync/auto_sync_service.dart';

/// Settings → Backup: export everything to a JSON file, restore it
/// (replacing local data) on this or another device.
class BackupSettingsSection extends StatefulWidget {
  const BackupSettingsSection({super.key, this.files, this.service});

  final BackupFiles? files;
  final BackupService? service;

  @override
  State<BackupSettingsSection> createState() => _BackupSettingsSectionState();
}

class _BackupSettingsSectionState extends State<BackupSettingsSection> {
  late final _service = widget.service ?? BackupService();
  late final _files = widget.files ?? BackupFiles(service: _service);
  bool _caches = false;
  bool _busy = false;

  void _say(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      final path = await _files.export(includeCaches: _caches);
      if (!mounted) return;
      _say(path == null ? l10n.backupShared : l10n.backupExported(path));
    } catch (e) {
      if (mounted) _say(l10n.backupFailed('$e'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      final json = await _files.pick();
      if (json == null || !mounted) return;
      final s = _service.inspect(json);
      final date = s.createdAt == null
          ? l10n.backupUnknownDate
          : DateFormat.yMMMd(
              Localizations.localeOf(context).toString(),
            ).format(s.createdAt!);
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.backupRestoreTitle),
          content: Text(
            l10n.backupRestoreBody(
              date,
              s.activities,
              s.plans,
              s.total,
              s.settings,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            FilledButton(
              key: const ValueKey('backup-restore-confirm'),
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.backupRestoreConfirm),
            ),
          ],
        ),
      );
      if (ok != true) return;
      await _service.restore(json);
      PlanChanges.instance.notify();
      AutoSyncService.instance.notifyCacheChanged();
      if (mounted) _say(l10n.backupRestored);
    } catch (e) {
      if (mounted) _say(l10n.backupFailed('$e'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (kIsWeb) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.backupIntro),
        SwitchListTile(
          key: const ValueKey('backup-caches'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.backupIncludeCaches),
          subtitle: Text(l10n.backupIncludeCachesHelp),
          value: _caches,
          onChanged: (v) => setState(() => _caches = v),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              key: const ValueKey('backup-export'),
              onPressed: _busy ? null : _export,
              icon: const Icon(Icons.upload_file_outlined),
              label: Text(l10n.backupExport),
            ),
            OutlinedButton.icon(
              key: const ValueKey('backup-restore'),
              onPressed: _busy ? null : _restore,
              icon: const Icon(Icons.download_outlined),
              label: Text(l10n.backupRestore),
            ),
          ],
        ),
      ],
    );
  }
}
