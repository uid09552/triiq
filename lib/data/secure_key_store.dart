import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// One named secret at rest, held in whatever credential vault the host OS
/// provides rather than in a file or in shared preferences:
///
/// | Platform | Backend                                                          |
/// |----------|------------------------------------------------------------------|
/// | Android  | `EncryptedSharedPreferences` — AES-256-GCM under a key in the (hardware-backed, where available) Android Keystore |
/// | Windows  | Credential Manager (`CredWriteW`), encrypted with DPAPI under the logged-in Windows account |
/// | iOS      | Keychain, `kSecClassGenericPassword`                             |
/// | Web      | *nothing is persisted*, see [_MemoryKeyStore]                    |
///
/// Android and Windows are the supported targets; iOS still builds, so its
/// options are kept configured. Linux and macOS are no longer targets.
///
/// In every native case the ciphertext is bound to this app and this OS user
/// account: another local user, or a copy of the app data lifted onto another
/// machine, cannot decrypt it.
///
/// Reads and deletes are failure-tolerant. A vault can be unavailable (a
/// Windows account with a broken credential store), locked, or hold ciphertext
/// that no longer decrypts (Android Keystore reset after a restored backup).
/// All of those are reported as "nothing stored" instead of thrown,
/// because the recovery is the same in each case: ask the user for the secret
/// again. A failed [write] is likewise swallowed — the caller has a working
/// secret in hand and should keep using it for this run even if the vault
/// refused to remember it.
abstract class SecureKeyStore {
  /// Picks the strongest store the current platform actually offers.
  factory SecureKeyStore(String name) =>
      kIsWeb ? _MemoryKeyStore() : _VaultKeyStore(name);

  /// Whether a written value survives an app restart. False only on web.
  bool get isPersistent;

  /// The stored secret, or `null` if there is none (or it can't be read).
  Future<String?> read();

  Future<void> write(String value);

  Future<void> delete();
}

/// Native platforms: the OS credential vault, via `flutter_secure_storage`.
class _VaultKeyStore implements SecureKeyStore {
  _VaultKeyStore(this._name);

  /// Vault entry name. The plugin prefixes it per app, which matters in
  /// shared vaults like Windows Credential Manager that list every app's
  /// secrets side by side.
  final String _name;

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      // Opt in to androidx.security's EncryptedSharedPreferences (needs API
      // 23+; our minSdk is Flutter's 24). Off by default in this plugin
      // version, which would otherwise fall back to its own older
      // RSA-wrapped-AES scheme in plaintext SharedPreferences.
      encryptedSharedPreferences: true,
      // If the Keystore key backing the ciphertext is gone — Keystore reset,
      // lock-screen credentials cleared, app data restored onto a different
      // device — drop the unreadable blob instead of throwing on every read
      // forever. The user re-enters the key; nothing else is stored here.
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      // Readable after the device's first unlock since boot rather than only
      // while unlocked, so a future background refresh can still reach the
      // key; `_this_device` keeps the item out of encrypted backups, so it is
      // never restored onto a different phone.
      accessibility: KeychainAccessibility.first_unlock_this_device,
      // No iCloud Keychain sync: the key stays on the device it was typed on.
      synchronizable: false,
    ),
  );

  @override
  bool get isPersistent => true;

  @override
  Future<String?> read() async {
    try {
      final value = await _storage.read(key: _name);
      return (value == null || value.isEmpty) ? null : value;
    } catch (error) {
      debugPrint('SecureKeyStore: cannot read "$_name" from the OS vault: $error');
      // Clear the entry so the next launch starts clean rather than hitting
      // the same unreadable value again.
      await delete();
      return null;
    }
  }

  @override
  Future<void> write(String value) async {
    try {
      await _storage.write(key: _name, value: value);
    } catch (error) {
      debugPrint('SecureKeyStore: cannot store "$_name" in the OS vault: $error');
    }
  }

  @override
  Future<void> delete() async {
    try {
      await _storage.delete(key: _name);
    } catch (error) {
      debugPrint('SecureKeyStore: cannot delete "$_name" from the OS vault: $error');
    }
  }
}

/// Web: the secret lives in this tab's memory and nowhere else.
///
/// Browsers have no keychain equivalent. `flutter_secure_storage`'s web
/// backend AES-GCM-encrypts the value into `localStorage` — but it writes the
/// raw AES key into `localStorage` right beside it, so anything that can read
/// one can read the other. That is obfuscation, not storage security: an XSS
/// bug, a malicious extension, or anyone at the keyboard with devtools open
/// walks off with a long-lived Intervals.icu API key. IndexedDB and cookies
/// are no better; a `HttpOnly` cookie would be, but that needs a backend to
/// set it, and this app talks to Intervals.icu directly.
///
/// So the web build keeps the key in memory only: it is re-entered after a
/// reload and gone when the tab closes.
class _MemoryKeyStore implements SecureKeyStore {
  String? _value;

  @override
  bool get isPersistent => false;

  @override
  Future<String?> read() async => _value;

  @override
  Future<void> write(String value) async => _value = value;

  @override
  Future<void> delete() async => _value = null;
}
