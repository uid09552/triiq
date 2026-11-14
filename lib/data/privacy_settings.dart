import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The athlete's privacy choices, kept on the device with plain
/// `shared_preferences`:
///
/// * **AI consent** — whether training and health data may be sent to the
///   configured AI provider (Claude, Ollama Cloud or their own Ollama
///   server). Off until the athlete agrees; without it the AI trainer is not
///   available (see `LlmSettings.isConfigured`). The date it was given is
///   kept, so the choice is a record, not just a flag, and so are the
///   third-party hosts it was given for: a model entry on a host that is
///   not in [aiConsentHosts] needs the athlete to agree again (a server on
///   their own network is covered by the consent itself — nothing leaves
///   it).
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

  /// The hosts the AI consent was given for. Device-local: never exported
  /// to a backup (a backup file must not grant consent for a server).
  static const aiConsentHostsPref = 'privacy.ai_consent_hosts';

  DateTime? _aiConsentAt;
  Set<String> _aiConsentHosts = {};
  bool _mapTiles = true;
  bool _loaded = false;

  /// Whether data may be sent to the AI provider.
  bool get aiConsent => _aiConsentAt != null;

  /// When the AI consent was given, or null.
  DateTime? get aiConsentAt => _aiConsentAt;

  /// The third-party hosts the consent covers.
  Set<String> get aiConsentHosts => Set.unmodifiable(_aiConsentHosts);

  /// Whether data may go to [host]: consent given, and for that host — or
  /// the server is [local] (the athlete's own machine or network).
  bool aiConsentCovers(String host, {bool local = false}) =>
      aiConsent && (local || _aiConsentHosts.contains(host.toLowerCase()));

  bool get mapTiles => _mapTiles;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_aiConsentKey);
      _aiConsentAt = stored == null ? null : DateTime.tryParse(stored);
      _aiConsentHosts = {
        for (final h in prefs.getStringList(aiConsentHostsPref) ?? const [])
          h.toLowerCase(),
      };
      _mapTiles = prefs.getBool(_mapTilesKey) ?? true;
    } catch (error) {
      debugPrint('PrivacySettings: cannot read stored choices: $error');
    }
    _loaded = true;
    notifyListeners();
  }

  /// Gives (for [hosts], added to those already covered) or withdraws the
  /// AI consent. Withdrawing forgets every host.
  Future<void> setAiConsent(
    bool granted, {
    DateTime? now,
    Iterable<String> hosts = const [],
  }) async {
    final add = {for (final h in hosts) h.toLowerCase()};
    if (granted == aiConsent &&
        (!granted || _aiConsentHosts.containsAll(add))) {
      return;
    }
    if (granted) {
      _aiConsentAt ??= now ?? DateTime.now();
      _aiConsentHosts = {..._aiConsentHosts, ...add};
    } else {
      _aiConsentAt = null;
      _aiConsentHosts = {};
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (granted) {
        await prefs.setString(_aiConsentKey, _aiConsentAt!.toIso8601String());
        await prefs.setStringList(aiConsentHostsPref, _aiConsentHosts.toList());
      } else {
        await prefs.remove(_aiConsentKey);
        await prefs.remove(aiConsentHostsPref);
      }
    } catch (error) {
      debugPrint('PrivacySettings: cannot store consent: $error');
    }
  }

  /// One-off upgrade from the single-model app, whose consent named one
  /// provider and recorded no host: an existing consent is taken to cover
  /// the host of the model it was given for ([hosts]), and nothing else.
  /// Works whether or not [load] has run yet. No-op without a consent or
  /// once hosts are recorded.
  Future<void> adoptLegacyConsentHosts(Iterable<String> hosts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString(_aiConsentKey) == null ||
          prefs.containsKey(aiConsentHostsPref)) {
        return;
      }
      final adopted = {for (final h in hosts) h.toLowerCase()};
      await prefs.setStringList(aiConsentHostsPref, adopted.toList());
      if (_loaded && aiConsent) {
        _aiConsentHosts = {..._aiConsentHosts, ...adopted};
        notifyListeners();
      }
    } catch (error) {
      debugPrint('PrivacySettings: cannot adopt consent hosts: $error');
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
    _aiConsentHosts = {};
    _mapTiles = true;
    notifyListeners();
  }
}
