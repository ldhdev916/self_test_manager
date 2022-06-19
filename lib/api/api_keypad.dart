import 'dart:convert';
import 'dart:math';

import 'package:convert/convert.dart';

import 'api_crypto.dart';

class KeyPair {
  final String first;
  final String second;

  KeyPair(this.first, this.second);

  @override
  String toString() => "($first, $second)";
}

class KeyPad {
  final Crypto crypto;
  final List<int> skipData;
  final List<KeyPair> keys;
  final String initTime;
  final String? decInitTime;
  final String keyIndex;

  const KeyPad({
    required this.crypto,
    required this.skipData,
    required this.keys,
    required this.initTime,
    required this.decInitTime,
    required this.keyIndex,
  });

  List<KeyPair> _getGeo(String message) =>
      message.codeUnits.map((e) => keys[skipData.indexOf(e)]).toList();

  String _hexWithComma(List<int> bytes) =>
      bytes.map((e) => e.toRadixString(16).padLeft(2, "0")).join(",");

  String _encryptGeos(List<KeyPair> geos) {
    final encryptedDecInitTime = decInitTime != null
        ? hex.encode(crypto.encryptSeed(ascii.encode(decInitTime!)))
        : null;

    final initTimeBytes = initTime.codeUnits
        .map((e) => int.tryParse(String.fromCharCode(e)) ?? e);

    final buffer = StringBuffer();
    for (final geo in geos) {
      buffer.write("\$");
      final x = geo.first;
      final y = geo.second;

      final xBytes = x.codeUnits.map((e) => int.parse(String.fromCharCode(e)));
      final yBytes = y.codeUnits.map((e) => int.parse(String.fromCharCode(e)));

      List<int> getData() {
        final space = " ".codeUnitAt(0);
        final arr = [
          ...xBytes,
          space,
          ...yBytes,
          space,
          ...initTimeBytes,
          space,
          "%".codeUnitAt(0),
          "b".codeUnitAt(0)
        ];

        final newArr = List.filled(48, 0);
        List.copyRange(newArr, 0, arr);
        final random = Random();
        for (var i = arr.length; i < newArr.length; i++) {
          newArr[i] = random.nextInt(101);
        }

        return newArr;
      }

      final data = getData();
      final encrypted = crypto.encryptSeed(data);
      buffer.write(_hexWithComma(encrypted));

      if (encryptedDecInitTime != null) {
        buffer.write("\$");
        buffer.write(encryptedDecInitTime);
      }
    }

    return buffer.toString();
  }

  String encryptPassword(String password) => _encryptGeos(_getGeo(password));
}
