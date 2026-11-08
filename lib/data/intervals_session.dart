import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../client/intervalls/intervalls_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'secure_key_store.dart';

/// Why [IntervalsSession.restore] did not end up connected.
enum RestoreFailure {
  /// Restore succeeded, or has not run.
  none,

  /// No key was stored.
  noKey,

  /// Intervals.icu rejected the stored key (401/403) and it was deleted.
  rejected,

  /// The key could not be checked (offline, timeout, 5xx); it was kept.
  network,
}

/// Holds the current Intervals.icu connection: the authenticated
/// [IntervallsClient] plus the athlete identity, shared across screens.
///
/// The API key is only ever written to the OS credential vault *after* it has
/// been proven to work (see [connect]) — a bad key never gets persisted. See
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

  /// Whether a verified key is saved — an install that was connected once.
  /// Never throws; false when the vault can't be read.
  Future<bool> hasSavedKey() async {
    try {
      return await _apiKeyStore.read().timeout(const Duration(seconds: 2)) !=
          null;
    } catch (_) {
      return false;
    }
  }

  /// If a previously-verified API key is in the vault, re-validates it (via
  /// [connect]) so the session comes back after an app restart. Safe to call
  /// once at startup; never throws.
  Future<void> restore() async {
    lastRestoreFailure = RestoreFailure.none;
    try {
      final savedKey = await _apiKeyStore.read();
      if (savedKey != null) {
        await connect(savedKey);
      } else {
        lastRestoreFailure = RestoreFailure.noKey;
      }
    } on DioException catch (error) {
      // Only drop the key when Intervals.icu actively rejects it (revoked or
      // regenerated). A timeout, DNS failure or 5xx says nothing about the
      // key's validity, so keep it and retry on the next launch instead of
      // making every offline start cost the user a re-entry.
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) {
        await _apiKeyStore.delete();
        lastRestoreFailure = RestoreFailure.rejected;
      } else {
        lastRestoreFailure = RestoreFailure.network;
      }
    } catch (_) {
      await _apiKeyStore.delete();
      lastRestoreFailure = RestoreFailure.rejected;
    } finally {
      isRestoring = false;
      notifyListeners();
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

    final response = await client.getAthletenApi().getAthleteProfile(id: '0');
    final athlete = response.data?.athlete;
    if (athlete?.id == null) {
      throw StateError('Intervals.icu did not return an athlete profile.');
    }

    await _apiKeyStore.write(apiKey);

    _client = client;
    athleteId = athlete!.id;
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
    await _apiKeyStore.delete();
    await _rememberAthlete(null);
    _client = null;
    athleteId = null;
    athleteName = null;
    athlete = null;
    notifyListeners();
  }
}
