import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart' as asn1;
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:self_test_manager/api/kisa_seed_cbc.dart';
import 'package:x509/x509.dart' as x509;

final _iv = [
  0x4d,
  0x6f,
  0x62,
  0x69,
  0x6c,
  0x65,
  0x54,
  0x72,
  0x61,
  0x6e,
  0x73,
  0x4b,
  0x65,
  0x79,
  0x31,
  0x30
];

Uint8List _randomBytes(int length) {
  final random = Random();
  return Uint8List.fromList(List.generate(length, (_) => random.nextInt(256)));
}

RSAPublicKey decodeX509DerPublicKey(Uint8List x509PublicKeyEncoding) {
  final parser = asn1.ASN1Parser(x509PublicKeyEncoding);
  final sequence = parser.nextObject() as asn1.ASN1Sequence;
  final x509Certificate = x509.X509Certificate.fromAsn1(sequence);
  final publicKey = x509Certificate.publicKey as x509.RsaPublicKey;
  return RSAPublicKey(publicKey.modulus, publicKey.exponent);
}

class Crypto {
  final String certification;

  Crypto({
    required this.certification,
  });

  late final _key = decodeX509DerPublicKey(base64Decode(certification));
  final uuid = hex.encode(_randomBytes(32));

  final _genSessionKeyBytes = _randomBytes(8);
  late final _genSessionKey = hex.encode(_genSessionKeyBytes);
  late final _hexByteSessionKey = utf8.encode(_genSessionKey);
  late final encryptedKey = _encryptRSA(_hexByteSessionKey);
  late final _seedSessionKey = Uint8List.fromList(_genSessionKey.codeUnits
      .map((e) => int.parse(String.fromCharCode(e), radix: 16))
      .toList());

  late final _seedRoundKey = KisaSeedCBC().seedRoundKey(_seedSessionKey, _iv);

  String _encryptRSA(List<int> data) {
    final cipher = Encrypter(RSA(publicKey: _key, encoding: RSAEncoding.OAEP));
    return hex.encode(cipher.encryptBytes(data).bytes);
  }

  Uint8List encryptSeed(List<int> data) =>
      KisaSeedCBC().seedCBCEncrypt(_seedRoundKey, data, 0, data.length);

  String hmacDigest(List<int> message) {
    final mac = Hmac(sha256, _hexByteSessionKey);
    return hex.encode(mac.convert(message).bytes);
  }
}
