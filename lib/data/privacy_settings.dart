import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The athlete's privacy choices, kept on the device with plain
/// `shared_preferences`:
///
/// * **AI consent** — whether training and health data may be sent to the
///   configured AI provider (Claude, Ollama Cloud or their own Ollama
///   server). Off until the athlete agrees; without it the AI trainer is not
///   available (see `LlmSettings.isConfigured`). The date it was given is
///   kept, so the choice is a record, not just a flag.
/// * **Map tiles** — whether route maps may fetch tiles from OpenStreetMap,
///   which sees the requesting IP address and the area shown. On by default,
///   since a map is something the athlete asks for by opening a route.
class PrivacySettings extends ChangeNotifier {
  PrivacySettings._();

  static final PrivacySettings instance = PrivacySettings._();

  @visibleForTesting
  factory PrivacySettings.forTesting() = PrivacySettings._;

  static const _aiConsentKey = 'privacy.ai_consent_at';
  static const _mapTilesKey = 'privacy.map_tiles';

  DateTime? _aiConsentAt;
  bool _mapTiles = true;
  bool _loaded = false;

  /// Whether data may be sent to the AI provider.
  bool get aiConsent => _aiConsentAt != null;

  /// When the AI consent was given, or null.
  DateTime? get aiConsentAt => _aiConsentAt;

  bool get mapTiles => _mapTiles;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_aiConsentKey);
      _aiConsentAt = stored == null ? null : DateTime.tryParse(stored);
      _mapTiles = prefs.getBool(_mapTilesKey) ?? true;
    } catch (error) {
      debugPrint('PrivacySettings: cannot read stored choices: $error');
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> setAiConsent(bool granted, {DateTime? now}) async {
    if (granted == aiConsent) return;
    _aiConsentAt = granted ? (now ?? DateTime.now()) : null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (granted) {
        await prefs.setString(_aiConsentKey, _aiConsentAt!.toIso8601String());
      } else {
        await prefs.remove(_aiConsentKey);
      }
    } catch (error) {
      debugPrint('PrivacySettings: cannot store consent: $error');
    }
  }

  Future<void> setMapTiles(bool on) async {
    if (on == _mapTiles) return;
    _mapTiles = on;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_mapTilesKey, on);
    } catch (error) {
      debugPrint('PrivacySettings: cannot store choice: $error');
    }
  }

  /// Back to the defaults (after all local data was erased).
  void resetInMemory() {
    _aiConsentAt = null;
    _mapTiles = true;
    notifyListeners();
  }
}
