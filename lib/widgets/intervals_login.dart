import 'package:flutter/material.dart';

import '../data/intervals_session.dart';
import '../data/oauth/intervals_oauth.dart';
import '../l10n/app_localizations.dart';

/// "Log in with Intervals.icu": the browser login (OAuth with PKCE) as the
/// way in next to pasting an API key. Opens Intervals.icu in the browser,
/// and on return connects the session with the access token.
///
/// Absent where the browser login does not exist (the web preview, iOS): the
/// API key field is then the only way in.
class IntervalsLoginButton extends StatefulWidget {
  const IntervalsLoginButton({
    super.key,
    this.onBusyChanged,
    this.onError,
    this.onConnected,
    this.oauth,
    this.session,
    this.available,
    this.login,
  });

  /// Told when the login starts and ends, so the key field can step aside.
  final ValueChanged<bool>? onBusyChanged;

  /// A failure in words; not called when the athlete just said no.
  final ValueChanged<String>? onError;

  /// Called once connected.
  final VoidCallback? onConnected;

  /// Test seams.
  final IntervalsOAuth? oauth;
  final IntervalsSession? session;
  final bool? available;

  /// Replaces the whole login (browser, token, connect); used by onboarding
  /// and tests.
  final Future<void> Function()? login;

  /// The login the app runs: browser, then connect with the token.
  static Future<void> run({
    IntervalsOAuth? oauth,
    IntervalsSession? session,
  }) async {
    final token = await (oauth ?? IntervalsOAuth()).login();
    await (session ?? IntervalsSession.instance).connectWithToken(
      token.accessToken,
    );
  }

  @override
  State<IntervalsLoginButton> createState() => _IntervalsLoginButtonState();
}

class _IntervalsLoginButtonState extends State<IntervalsLoginButton> {
  bool _busy = false;

  Future<void> _start() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    widget.onBusyChanged?.call(true);
    String? error;
    var connected = false;
    try {
      await (widget.login ??
          () => IntervalsLoginButton.run(
            oauth: widget.oauth,
            session: widget.session,
          ))();
      connected = true;
    } on OAuthException catch (e) {
      error = e.denied ? l10n.loginCancelled : l10n.loginFailed(e.message);
    } catch (e) {
      error = l10n.loginFailed('$e');
    }
    if (!mounted) return;
    setState(() => _busy = false);
    widget.onBusyChanged?.call(false);
    if (error != null) widget.onError?.call(error);
    if (connected) widget.onConnected?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!(widget.available ?? IntervalsOAuth.isSupported)) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          key: const ValueKey('login-intervals'),
          onPressed: _busy ? null : _start,
          icon: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : const Icon(Icons.login),
          label: Text(l10n.loginWithIntervals),
        ),
        const SizedBox(height: 6),
        Text(
          _busy ? l10n.loginWaiting : l10n.loginHelp,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                l10n.loginOrApiKey,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
