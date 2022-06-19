import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:self_test_manager/api/api_crypto.dart';

import 'api_keypad.dart';

final _sGetTokenRegex = RegExp(r"var TK_requestToken=(.*);");

final _sDecInitTimeRegex = RegExp(r"var decInitTime='(\d*)';");
final _sInitTimeRegex = RegExp(r"var initTime='([\da-fA-F]*)';");

final _sKeyInfoPointRegex = RegExp(r"key\.addPoint\((\d+), (\d+)\)");

Future<Transkey> getTranskey(String servletUrl) async {
  final token = _sGetTokenRegex
      .firstMatch((await http.get(Uri.parse(servletUrl)
              .replace(queryParameters: {"op": "getToken"})))
          .body)!
      .group(1)!;

  final getInitTimeResult = (await http.get(Uri.parse(servletUrl)
          .replace(queryParameters: {"op": "getInitTime"})))
      .body;

  final decInitTime =
      _sDecInitTimeRegex.firstMatch(getInitTimeResult)?.group(1);
  final initTime = _sInitTimeRegex.firstMatch(getInitTimeResult)!.group(1)!;

  final certification = (await http.post(Uri.parse(servletUrl).replace(
          queryParameters: {"op": "getPublicKey", "TK_requestToken": token})))
      .body;

  final crypto = Crypto(certification: certification);

  final keyInfo =
      (await http.post(Uri.parse(servletUrl).replace(queryParameters: {
    "op": "getKeyInfo",
    "key": crypto.encryptedKey,
    "transkeyUuid": crypto.uuid,
    "useCert": "true",
    "TK_requestToken": token,
    "mode": "common"
  })))
          .body;

  final num = keyInfo.split("var number = new Array();")[1];
  final numberKeysBefore = num.split("number.push(key);")..removeLast();
  final numberKeys = numberKeysBefore.map((e) {
    final match = _sKeyInfoPointRegex.firstMatch(e)!;
    return KeyPair(match.group(1)!, match.group(2)!);
  }).toList();

  return Transkey(
      servletUrl: servletUrl,
      token: token,
      decInitTime: decInitTime,
      initTime: initTime,
      crypto: crypto,
      numberKeys: numberKeys);
}

class Transkey {
  final String servletUrl;
  final String token;
  final String? decInitTime;
  final String initTime;
  final Crypto crypto;
  final List<KeyPair> numberKeys;

  Transkey({
    required this.servletUrl,
    required this.token,
    required this.decInitTime,
    required this.initTime,
    required this.crypto,
    required this.numberKeys,
  });

  final allocIndex = Random().nextInt(0xffffffff);

  Future<KeyPad> newKeypad() async {
    final commonData = {
      "name": "password",
      "keyType": "single",
      "keyboardType": "number",
      "fieldType": "number",
      "inputName": "password",
      "transkeyUuid": crypto.uuid,
      "exE2E": "false",
      "isCrt": "false",
      "allocationIndex": allocIndex.toString(),
      "initTime": initTime,
      "TK_requestToken": token,
      "parentKeyboard": "false",
      "talkBack": "true"
    };

    final keyIndex = (await http.post(Uri.parse(servletUrl)
            .replace(queryParameters: {...commonData, "op": "getKeyIndex"})))
        .body;
    final skipData = (await http.post(Uri.parse(servletUrl).replace(
            queryParameters: {
          ...commonData,
          "op": "getDummy",
          "keyIndex": keyIndex
        })))
        .body;

    final skip = skipData.split(",").map((e) => e.codeUnits.single).toList();

    return KeyPad(
        crypto: crypto,
        skipData: skip,
        keys: numberKeys,
        initTime: initTime,
        decInitTime: decInitTime,
        keyIndex: keyIndex);
  }

  String hmacDigest(List<int> message) => crypto.hmacDigest(message);
}
