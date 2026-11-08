import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../client/intervalls/intervalls_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'secure_key_store.dart';

/// Why [IntervalsSession.restore] did not end up connected.
enum RestoreFailure {
  /// Restore succeeded, or has not run.
  none,

  /// No key or token was stored.
  noKey,

  /// Intervals.icu rejected the stored key or token (401/403) and it was
  /// deleted.
  rejected,

  /// The credential could not be checked (offline, timeout, 5xx); it was kept.
  network,
}

/// How the athlete signed in.
enum ConnectionMethod {
  /// A pasted API key.
  apiKey,

  /// "Log in with Intervals.icu": an OAuth access token.
  oauth,
}

/// Holds the current Intervals.icu connection: the authenticated
/// [IntervallsClient] plus the athlete identity, shared across screens.
///
/// The API key — or the OAuth access token from "Log in with Intervals.icu"
/// (see [connectWithToken]) — is only ever written to the OS credential vault
/// *after* it has been proven to work (see [connect]); a bad one never gets
/// persisted. One credential at a time: connecting one replaces the other. See
/// [SecureKeyStore] for which vault that is per platform, and why the web
/// build deliberately persists nothing.
class IntervalsSession extends ChangeNotifier {
  IntervalsSession._();

  static final IntervalsSession instance = IntervalsSession._();

  @visibleForTesting
  factory IntervalsSession.forTesting({
    bool connected = false,
    IntervallsClient? client,
    String? athleteId,
  }) {
    final session = IntervalsSession._().._setConnectedForTesting(connected);
    if (client != null) session._client = client;
    session.athleteId = athleteId;
    return session;
  }

  void _setConnectedForTesting(bool connected) {
    _client = connected ? IntervallsClient() : null;
  }

  /// Flips a [forTesting] session between connected and not, notifying
  /// listeners like the real [connect]/[disconnect] do.
  @visibleForTesting
  void debugSetConnected(bool connected) {
    _setConnectedForTesting(connected);
    notifyListeners();
  }

  static final _apiKeyStore = SecureKeyStore('intervals_api_key');
  static final _tokenStore = SecureKeyStore('intervals_oauth_token');

  /// Name of the bearer scheme in the generated client (`AccessToken`).
  static const _bearerScheme = 'AccessToken';

  /// How the current connection was made; null while disconnected.
  ConnectionMethod? method;

  IntervallsClient? _client;
  String? athleteId;
  String? athleteName;

  /// The full athlete record — profile picture, body stats and the per-sport
  /// settings (FTP, LTHR, max HR, threshold pace, zones) that Intervals.icu
  /// holds *now*, as opposed to the ones frozen into each past activity.
  /// Loaded after [connect] succeeds; `null` until then, and never fatal —
  /// a connection that works is not lost because this second call failed.
  WithSportSettings? athlete;

  /// True while [restore] is checking a saved key on app startup, so the UI
  /// can show a neutral "checking" state instead of flashing "not connected"
  /// right before flipping to connected.
  bool isRestoring = true;

  /// Why the last [restore] did not connect — lets a background run tell a
  /// revoked key (needs the athlete) from a flaky network (just retry).
  RestoreFailure lastRestoreFailure = RestoreFailure.none;

  bool get isConnected => _client != null;

  /// Whether this platform can remember the key across restarts. False on
  /// web, where it is only held for the lifetime of the tab.
  bool get remembersApiKey => _apiKeyStore.isPersistent;

  /// The authenticated client, or `null` if not connected.
  IntervallsClient? get client => _client;

  /// Absolute URL of the athlete's profile picture, or `null` if they have
  /// none. Intervals.icu returns either a full URL (pictures synced from
  /// Strava) or a site-relative path, so relative ones are resolved here
  /// rather than in every widget that shows an avatar.
  String? get athleteAvatarUrl {
    final picture = athlete?.profileMedium;
    if (picture == null || picture.isEmpty) return null;
    if (picture.startsWith('http://') || picture.startsWith('https://')) {
      return picture;
    }
    return 'https://intervals.icu'
        '${picture.startsWith('/') ? '' : '/'}$picture';
  }

  /// The athlete's settings for [sport] (`Ride`, `Run`, `Swim`, …), or
  /// `null` if they have none configured for it.
  SportSettings? settingsForSport(String sport) {
    final normalized = sport.toLowerCase();
    for (final settings in athlete?.sportSettings ?? const <SportSettings>[]) {
      final types = settings.types ?? const [];
      if (types.any((type) => type.value.toLowerCase() == normalized)) {
        return settings;
      }
    }
    return null;
  }

  /// Whether a verified key or token is saved — an install that was
  /// connected once. Never throws; false when the vault can't be read.
  Future<bool> hasSavedKey() async {
    try {
      const wait = Duration(seconds: 2);
      return await _tokenStore.read().timeout(wait) != null ||
          await _apiKeyStore.read().timeout(wait) != null;
    } catch (_) {
      return false;
    }
  }

  /// If a previously-verified token or API key is in the vault, re-validates
  /// it (via [connectWithToken] / [connect]) so the session comes back after
  /// an app restart. Safe to call once at startup; never throws.
  Future<void> restore() async {
    lastRestoreFailure = RestoreFailure.none;
    try {
      final token = await _tokenStore.read();
      final key = token == null ? await _apiKeyStore.read() : null;
      if (token != null) {
        await _restoreFrom(_tokenStore, () => connectWithToken(token));
      } else if (key != null) {
        await _restoreFrom(_apiKeyStore, () => connect(key));
      } else {
        lastRestoreFailure = RestoreFailure.noKey;
      }
    } finally {
      isRestoring = false;
      notifyListeners();
    }
  }

  Future<void> _restoreFrom(
    SecureKeyStore store,
    Future<void> Function() connectNow,
  ) async {
    try {
      await connectNow();
    } on DioException catch (error) {
      // Only drop the credential when Intervals.icu actively rejects it
      // (revoked or regenerated). A timeout, DNS failure or 5xx says nothing
      // about its validity, so keep it and retry on the next launch instead
      // of making every offline start cost the user a re-login.
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) {
        await store.delete();
        lastRestoreFailure = RestoreFailure.rejected;
      } else {
        lastRestoreFailure = RestoreFailure.network;
      }
    } catch (_) {
      await store.delete();
      lastRestoreFailure = RestoreFailure.rejected;
    }
  }

  /// Auth test: validates [apiKey] against Intervals.icu by actually
  /// fetching data with it — the athlete profile, via the `0` "current
  /// athlete" alias — rather than just checking the key's shape. Only on
  /// success is the client kept connected and the key handed to the vault
  /// for next launch.
  Future<void> connect(String apiKey) async {
    final client = IntervallsClient();
    client.setBasicAuth('APIKey', 'API_KEY', apiKey);
    final athlete = await _verify(client);

    await _apiKeyStore.write(apiKey);
    await _tokenStore.delete();
    await _adopt(client, athlete, ConnectionMethod.apiKey);
  }

  /// The same, for the access token of "Log in with Intervals.icu".
  Future<void> connectWithToken(String accessToken) async {
    final client = IntervallsClient();
    client.setBearerAuth(_bearerScheme, accessToken);
    final athlete = await _verify(client);

    await _tokenStore.write(accessToken);
    await _apiKeyStore.delete();
    await _adopt(client, athlete, ConnectionMethod.oauth);
  }

  /// The athlete the credential on [client] belongs to.
  Future<AthleteForProfile> _verify(IntervallsClient client) async {
    final response = await client.getAthletenApi().getAthleteProfile(id: '0');
    final athlete = response.data?.athlete;
    if (athlete?.id == null) {
      throw StateError('Intervals.icu did not return an athlete profile.');
    }
    return athlete!;
  }

  Future<void> _adopt(
    IntervallsClient client,
    AthleteForProfile athlete,
    ConnectionMethod how,
  ) async {
    _client = client;
    method = how;
    athleteId = athlete.id;
    athleteName = athlete.name;
    await _rememberAthlete(athleteId);
    notifyListeners();

    await refreshAthlete();
  }

  /// Reloads the full athlete record (picture, body stats, per-sport
  /// settings). Best-effort: a failure leaves the previous record in place
  /// and the session connected, since none of this is needed to sync.
  Future<void> refreshAthlete() async {
    final client = _client;
    if (client == null) return;
    try {
      final response = await client.getAthletenApi().getAthlete(id: '0');
      athlete = response.data;
      notifyListeners();
    } catch (error) {
      debugPrint('IntervalsSession: could not load athlete details: $error');
    }
  }

  /// Key under which the last connected athlete's id is kept, so writes made
  /// offline (also right after an offline start, before the session could
  /// reconnect) are tied to the account they were made in.
  static const lastAthleteKey = 'intervals.last_athlete_id';

  /// The athlete connected now, else the one connected last on this device.
  static Future<String?> lastKnownAthleteId() async {
    final current = instance.athleteId;
    if (current != null) return current;
    try {
      return (await SharedPreferences.getInstance()).getString(lastAthleteKey);
    } catch (_) {
      return null;
    }
  }

  static Future<void> _rememberAthlete(String? id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (id == null) {
        await prefs.remove(lastAthleteKey);
      } else {
        await prefs.setString(lastAthleteKey, id);
      }
    } catch (error) {
      debugPrint('IntervalsSession: cannot remember the athlete: $error');
    }
  }

  Future<void> disconnect() async {
    // A login made with OAuth is revoked at Intervals.icu as well, so the app
    // disappears from the athlete's connected apps. Best effort: offline, the
    // token is still forgotten here.
    if (method == ConnectionMethod.oauth) {
      try {
        await _client?.getOAuthServerControllerApi().disconnectApp().timeout(
          const Duration(seconds: 5),
        );
      } catch (error) {
        debugPrint('IntervalsSession: could not revoke the token: $error');
      }
    }
    await _apiKeyStore.delete();
    await _tokenStore.delete();
    await _rememberAthlete(null);
    method = null;
    _client = null;
    athleteId = null;
    athleteName = null;
    athlete = null;
    notifyListeners();
  }
}
