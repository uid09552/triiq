import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/secure_key_store.dart';

/// Stands in for the OS credential vault behind `flutter_secure_storage`'s
/// platform channel, so these tests exercise [SecureKeyStore]'s own contract
/// (round-trip, and tolerance of a vault that refuses to cooperate) without a
/// real Keychain / Keystore / Credential Manager.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  final vault = <String, String>{};
  final calls = <String>[];
  // Method names the fake vault should fail on, as a real one does when the
  // secret service is missing or the ciphertext no longer decrypts.
  final failing = <String>{};

  setUp(() {
    vault.clear();
    calls.clear();
    failing.clear();

    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      if (failing.contains(call.method)) {
        throw PlatformException(
          code: 'Exception',
          message: 'vault unavailable',
        );
      }
      final args = (call.arguments as Map).cast<String, dynamic>();
      switch (call.method) {
        case 'read':
          return vault[args['key'] as String];
        case 'write':
          vault[args['key'] as String] = args['value'] as String;
          return null;
        case 'delete':
          vault.remove(args['key'] as String);
          return null;
        default:
          return null;
      }
    });
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('round-trips a secret through the vault', () async {
    final store = SecureKeyStore('test_key');

    expect(await store.read(), isNull);

    await store.write('s3cret');
    expect(await store.read(), 's3cret');

    await store.delete();
    expect(await store.read(), isNull);
  });

  test('persists across store instances sharing the same name', () async {
    await SecureKeyStore('test_key').write('s3cret');

    expect(await SecureKeyStore('test_key').read(), 's3cret');
    expect(await SecureKeyStore('other_key').read(), isNull);
  });

  test('treats an empty stored value as nothing stored', () async {
    vault['test_key'] = '';

    expect(await SecureKeyStore('test_key').read(), isNull);
  });

  test(
    'reports an unreadable vault as no value, and clears the entry',
    () async {
      vault['test_key'] = 's3cret';
      failing.add('read');

      expect(await SecureKeyStore('test_key').read(), isNull);
      // Cleared, so the next launch does not hit the same bad entry again.
      expect(calls, contains('delete'));
      expect(vault, isEmpty);
    },
  );

  test('a vault that refuses to store does not break the caller', () async {
    failing.add('write');

    await expectLater(SecureKeyStore('test_key').write('s3cret'), completes);
  });

  test('a vault that refuses to delete does not break the caller', () async {
    failing.add('delete');

    await expectLater(SecureKeyStore('test_key').delete(), completes);
  });

  test('reports itself as persistent on a native platform', () {
    expect(SecureKeyStore('test_key').isPersistent, isTrue);
  });
}
