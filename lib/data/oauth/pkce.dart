import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// A PKCE (RFC 7636) verifier and its S256 challenge.
///
/// The verifier stays in the app; only the challenge goes to the browser. The
/// token request then proves it started the login by sending the verifier,
/// which is why a public client needs no secret.
class Pkce {
  const Pkce._(this.verifier, this.challenge);

  /// 43-128 characters from the unreserved set; this is 64 (48 random bytes).
  final String verifier;

  /// `base64url(sha256(verifier))`, no padding.
  final String challenge;

  static const method = 'S256';

  /// A fresh pair from a cryptographically secure source.
  factory Pkce.generate([Random? random]) =>
      Pkce.fromVerifier(randomUrlSafe(48, random));

  factory Pkce.fromVerifier(String verifier) =>
      Pkce._(verifier, challengeFor(verifier));

  static String challengeFor(String verifier) => base64UrlEncode(
    sha256.convert(ascii.encode(verifier)).bytes,
  ).replaceAll('=', '');
}

/// [byteCount] random bytes as unpadded base64url text — for the verifier
/// and the `state` value.
String randomUrlSafe(int byteCount, [Random? random]) {
  final source = random ?? Random.secure();
  final bytes = List<int>.generate(byteCount, (_) => source.nextInt(256));
  return base64UrlEncode(bytes).replaceAll('=', '');
}
