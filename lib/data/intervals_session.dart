import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../client/intervalls/intervalls_client.dart';
import 'secure_key_store.dart';

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

  static final _apiKeyStore = SecureKeyStore('intervals_api_key');

  IntervallsClient? _client;
  String? athleteId;
  String? athleteName;

  /// True while [restore] is checking a saved key on app startup, so the UI
  /// can show a neutral "checking" state instead of flashing "not connected"
  /// right before flipping to connected.
  bool isRestoring = true;

  bool get isConnected => _client != null;

  /// Whether this platform can remember the key across restarts. False on
  /// web, where it is only held for the lifetime of the tab.
  bool get remembersApiKey => _apiKeyStore.isPersistent;

  /// The authenticated client, or `null` if not connected.
  IntervallsClient? get client => _client;

  /// If a previously-verified API key is in the vault, re-validates it (via
  /// [connect]) so the session comes back after an app restart. Safe to call
  /// once at startup; never throws.
  Future<void> restore() async {
    try {
      final savedKey = await _apiKeyStore.read();
      if (savedKey != null) {
        await connect(savedKey);
      }
    } on DioException catch (error) {
      // Only drop the key when Intervals.icu actively rejects it (revoked or
      // regenerated). A timeout, DNS failure or 5xx says nothing about the
      // key's validity, so keep it and retry on the next launch instead of
      // making every offline start cost the user a re-entry.
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) {
        await _apiKeyStore.delete();
      }
    } catch (_) {
      await _apiKeyStore.delete();
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
    notifyListeners();
  }

  Future<void> disconnect() async {
    await _apiKeyStore.delete();
    _client = null;
    athleteId = null;
    athleteName = null;
    notifyListeners();
  }
}
