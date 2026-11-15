import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../info/sbom.dart';
import '../../info/sbom_files.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/section_card.dart';

String sbomKindLabel(AppLocalizations l10n, SbomKind kind) => switch (kind) {
  SbomKind.direct => l10n.sbomKindDirect,
  SbomKind.dev => l10n.sbomKindDev,
  SbomKind.transitive => l10n.sbomKindTransitive,
};

/// Info → SBOM: the bundled CycloneDX list of every package the app is built
/// from — a summary, a searchable list, a page per package, and an export of
/// the JSON. The native Android (Gradle) libraries and the Flutter engine are
/// not in it, as in the CI SBOM.
class SbomScreen extends StatefulWidget {
  const SbomScreen({super.key, this.load, this.files, this.openUrl});

  /// Test seam: where the SBOM comes from (default: the bundled asset).
  final Future<Sbom> Function()? load;

  /// Test seam: how the JSON leaves the app (share sheet / save dialog).
  final SbomFiles? files;

  final Future<bool> Function(Uri url)? openUrl;

  @override
  State<SbomScreen> createState() => _SbomScreenState();
}

class _SbomScreenState extends State<SbomScreen> {
  late Future<Sbom> _sbom = _load();
  final _search = TextEditingController();
  String _query = '';
  bool _busy = false;

  Future<Sbom> _load() => (widget.load ?? Sbom.load)();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _say(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _export(Sbom sbom) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      final path = await (widget.files ?? const SbomFiles()).export(
        sbom.raw,
        appVersion: sbom.appVersion,
      );
      if (!mounted) return;
      _say(path == null ? l10n.sbomShared : l10n.sbomExported(path));
    } catch (e) {
      if (mounted) _say(l10n.sbomExportFailed('$e'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openPubDev(Uri url) async {
    final l10n = AppLocalizations.of(context)!;
    var ok = false;
    try {
      ok = await (widget.openUrl ?? (u) => launchUrl(u))(url);
    } catch (_) {}
    if (!ok && mounted) _say(l10n.infoLinkFailed(url.toString()));
  }

  void _details(SbomPackage p) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) {
        final theme = Theme.of(sheet);
        Widget row(String label, String? value) => value == null
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Semantics(
                  container: true,
                  label: '$label: $value',
                  excludeSemantics: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(value),
                    ],
                  ),
                ),
              );
        final url = p.pubDevUrl;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              key: const ValueKey('sbom-details'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(p.name, style: theme.textTheme.titleLarge),
                ),
                const SizedBox(height: 8),
                row(l10n.sbomDetailVersion, p.version),
                row(l10n.sbomDetailKind, sbomKindLabel(l10n, p.kind)),
                row(l10n.sbomDetailSource, p.source),
                row(l10n.sbomDetailScope, p.scope),
                row(l10n.sbomDetailPurl, p.purl),
                row(l10n.sbomDetailHash, p.sha256),
                if (url != null) ...[
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    key: const ValueKey('sbom-pubdev'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(48, 48),
                    ),
                    icon: const Icon(Icons.open_in_new),
                    label: Text(l10n.sbomOpenPubDev),
                    onPressed: () => _openPubDev(url),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sbomTitle)),
      body: FutureBuilder<Sbom>(
        future: _sbom,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return _LoadError(
              error: '${snapshot.error}',
              onRetry: () => setState(() {
                _sbom = _load();
              }),
            );
          }
          return _content(context, l10n, snapshot.data!);
        },
      ),
    );
  }

  Widget _content(BuildContext context, AppLocalizations l10n, Sbom sbom) {
    final theme = Theme.of(context);
    final shown = sbom.search(_query);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: shown.isEmpty ? 3 : shown.length + 2,
      itemBuilder: (context, i) {
        if (i == 0) {
          return SectionCard(
            icon: Icons.inventory_2_outlined,
            title: l10n.infoSbomSection,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    l10n.sbomSummary(
                      sbom.packages.length,
                      sbom.count(SbomKind.direct),
                      sbom.count(SbomKind.dev),
                      sbom.count(SbomKind.transitive),
                    ),
                    key: const ValueKey('sbom-summary'),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.sbomFormatLine(sbom.specVersion, sbom.appVersion),
                  key: const ValueKey('sbom-format'),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.sbomNotCovered,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const ValueKey('sbom-export'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(48, 48),
                  ),
                  icon: const Icon(Icons.ios_share),
                  label: Text(l10n.sbomExport),
                  onPressed: _busy ? null : () => _export(sbom),
                ),
              ],
            ),
          );
        }
        if (i == 1) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SearchBar(
              key: const ValueKey('sbom-search'),
              controller: _search,
              hintText: l10n.sbomSearchHint,
              leading: const Icon(Icons.search),
              trailing: [
                if (_query.isNotEmpty)
                  IconButton(
                    tooltip: l10n.clearButton,
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _search.clear();
                      setState(() => _query = '');
                    },
                  ),
              ],
              onChanged: (v) => setState(() => _query = v),
            ),
          );
        }
        if (shown.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.sbomNoMatch(_query.trim()),
              textAlign: TextAlign.center,
            ),
          );
        }
        final p = shown[i - 2];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            key: ValueKey('sbom-package-${p.name}'),
            minVerticalPadding: 8,
            title: Text(p.name),
            subtitle: Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(p.version),
                Text('· ${p.source}'),
                _KindChip(kind: p.kind),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _details(p),
          ),
        );
      },
    );
  }
}

class _KindChip extends StatelessWidget {
  const _KindChip({required this.kind});

  final SbomKind kind;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (kind) {
      SbomKind.direct => (scheme.primaryContainer, scheme.onPrimaryContainer),
      SbomKind.dev => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      SbomKind.transitive => (
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        sbomKindLabel(l10n, kind),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 40,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.sbomLoadFailed(error),
              key: const ValueKey('sbom-error'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: const ValueKey('sbom-retry'),
              style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
              onPressed: onRetry,
              child: Text(l10n.sbomRetry),
            ),
          ],
        ),
      ),
    );
  }
}
