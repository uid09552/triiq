import 'package:flutter/material.dart';

import '../../data/intervals_session.dart';
import '../../data/pending_writes.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/athlete_avatar.dart';
import '../../widgets/section_card.dart';
import '../settings/settings_screen.dart';

/// Profile: Intervals.icu login/connection status, and a link to Settings.
///
/// The API key itself is entered here but owned by [IntervalsSession],
/// which auth-tests it against Intervals.icu before persisting it to
/// secure storage.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _apiKeyController = TextEditingController();
  final _session = IntervalsSession.instance;

  bool _connecting = false;
  String? _error;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    setState(() {
      _connecting = true;
      _error = null;
    });
    try {
      await _session.connect(_apiKeyController.text.trim());
      if (!mounted) return;
      setState(() => _connecting = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = AppLocalizations.of(
          context,
        )!.couldNotConnectGeneric(e.toString());
        _connecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleProfile)),
      body: ListenableBuilder(
        listenable: _session,
        builder: (context, _) {
          final connected = _session.isConnected;
          final restoring = _session.isRestoring;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colorScheme.primary, colorScheme.tertiary],
                  ),
                ),
                child: Column(
                  children: [
                    restoring
                        ? Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(18),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            ),
                          )
                        : const AthleteAvatar(size: 64),
                    const SizedBox(height: 12),
                    Text(
                      restoring
                          ? l10n.profileHeaderChecking
                          : connected
                          ? (_session.athleteName ?? l10n.connectedLabel)
                          : l10n.notConnected,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                icon: Icons.link,
                title: l10n.intervalsConnectionTitle,
                child: restoring
                    ? Text(l10n.checkingForSavedKey)
                    : connected
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.tonal(
                          onPressed: () async {
                            // Nothing made in this account may be sent to
                            // the next one connected.
                            await PendingWritesService.instance.clearAll();
                            await _session.disconnect();
                          },
                          child: Text(l10n.disconnectButton),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _session.remembersApiKey
                                ? l10n.apiKeyHelpSecure
                                : l10n.apiKeyHelpInsecure,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _apiKeyController,
                            obscureText: true,
                            enabled: !_connecting,
                            decoration: InputDecoration(
                              labelText: l10n.intervalsApiKeyLabel,
                            ),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ],
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ValueListenableBuilder(
                              valueListenable: _apiKeyController,
                              builder: (context, value, _) => FilledButton(
                                onPressed: value.text.isEmpty || _connecting
                                    ? null
                                    : _connect,
                                child: _connecting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(l10n.connectButton),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.settings_outlined,
                      color: colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    l10n.titleSettings,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
