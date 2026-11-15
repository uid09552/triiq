import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../info/app_info.dart';
import '../../info/sbom.dart';
import '../../info/sbom_files.dart';
import '../../l10n/app_localizations.dart';
import '../../navigation/shell_tab.dart';
import '../../theme_controller.dart';
import '../../widgets/section_card.dart';
import '../settings/privacy_screen.dart';
import 'sbom_screen.dart';

/// More → Info: which version is running, where the project lives, the
/// open-source licenses and the software bill of materials (SBOM) — and a
/// "Copy version info" button for bug reports.
class InfoScreen extends StatefulWidget {
  const InfoScreen({
    super.key,
    this.info,
    this.openUrl,
    this.loadSbom,
    this.files,
    this.theme,
  });

  /// Test seam: the app info (default: read from the platform).
  final Future<AppInfo?>? info;

  /// Opens a link; defaults to the system browser.
  final Future<bool> Function(Uri url)? openUrl;

  /// Test seam: where the SBOM comes from (default: the bundled asset).
  final Future<Sbom> Function()? loadSbom;

  /// Test seam: how the SBOM is exported.
  final SbomFiles? files;

  /// Test seam: the theme choice the copied text names.
  final ThemeController? theme;

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  late final Future<AppInfo?> _info = widget.info ?? AppInfo.load();

  Future<void> _open(Uri url) async {
    final l10n = AppLocalizations.of(context)!;
    var ok = false;
    try {
      ok = await (widget.openUrl ?? (u) => launchUrl(u))(url);
    } catch (_) {}
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.infoLinkFailed(url.toString()))),
      );
    }
  }

  Future<void> _copy(AppInfo? info) async {
    final l10n = AppLocalizations.of(context)!;
    final text = versionInfoText(
      info: info,
      locale: Localizations.localeOf(context),
      theme: (widget.theme ?? ThemeController.instance).choice,
    );
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.infoCopied)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.infoTitle),
        actions: shellTabActions(context),
      ),
      body: FutureBuilder<AppInfo?>(
        future: _info,
        builder: (context, snapshot) {
          final info = snapshot.data;
          final loading = snapshot.connectionState != ConnectionState.done;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SectionCard(
                icon: Icons.info_outline,
                title: l10n.infoAppSection,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        loading ? 'TriIQ' : versionLineOf(info, l10n),
                        key: const ValueKey('info-version-line'),
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _Fact(l10n.infoNameLabel, 'TriIQ'),
                    if (info != null) ...[
                      _Fact(l10n.infoVersionLabel, info.version),
                      _Fact(l10n.infoBuildLabel, info.build),
                    ],
                    _Fact(l10n.infoPlatformLabel, platformName),
                    if (osDescription case final os?)
                      _Fact(l10n.infoOsLabel, os),
                    if (dartVersion case final dart?)
                      _Fact(l10n.infoDartLabel, dart),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      key: const ValueKey('info-copy'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                      icon: const Icon(Icons.copy_outlined),
                      label: Text(l10n.infoCopyButton),
                      onPressed: loading ? null : () => _copy(info),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.infoCopyHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SectionCard(
                icon: Icons.link,
                title: l10n.infoLinksSection,
                child: Column(
                  children: [
                    _LinkTile(
                      key: const ValueKey('info-github'),
                      icon: Icons.code,
                      title: l10n.infoGithub,
                      onTap: () => _open(githubUrl),
                    ),
                    _LinkTile(
                      key: const ValueKey('info-releases'),
                      icon: Icons.new_releases_outlined,
                      title: l10n.infoReleases,
                      onTap: () => _open(releasesUrl),
                    ),
                    _LinkTile(
                      key: const ValueKey('info-privacy'),
                      icon: Icons.privacy_tip_outlined,
                      title: l10n.pvTitle,
                      inApp: true,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const PrivacyScreen(),
                        ),
                      ),
                    ),
                    _LinkTile(
                      key: const ValueKey('info-license'),
                      icon: Icons.gavel_outlined,
                      title: l10n.infoLicenseLink,
                      onTap: () => _open(licenseUrl),
                    ),
                  ],
                ),
              ),
              SectionCard(
                icon: Icons.balance_outlined,
                title: l10n.infoLicensesSection,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.infoLicensesBody),
                    const SizedBox(height: 8),
                    FilledButton.tonalIcon(
                      key: const ValueKey('info-licenses'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                      icon: const Icon(Icons.article_outlined),
                      label: Text(l10n.infoLicensesButton),
                      onPressed: () => showLicensePage(
                        context: context,
                        applicationName: 'TriIQ',
                        applicationVersion: info == null
                            ? null
                            : '${info.version} (${info.build})',
                      ),
                    ),
                  ],
                ),
              ),
              SectionCard(
                icon: Icons.inventory_2_outlined,
                title: l10n.infoSbomSection,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.infoSbomBody),
                    const SizedBox(height: 8),
                    FilledButton.tonalIcon(
                      key: const ValueKey('info-sbom'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                      icon: const Icon(Icons.list_alt_outlined),
                      label: Text(l10n.infoSbomButton),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => SbomScreen(
                            load: widget.loadSbom,
                            files: widget.files,
                            openUrl: widget.openUrl,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A label above its value — stacked, so it never overflows at 2× text.
class _Fact extends StatelessWidget {
  const _Fact(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
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
            Text(value, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.inApp = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  /// An in-app page (chevron) rather than an external link.
  final bool inApp;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    minVerticalPadding: 8,
    leading: Icon(icon),
    title: Text(title),
    trailing: Icon(inApp ? Icons.chevron_right : Icons.open_in_new, size: 20),
    onTap: onTap,
  );
}
