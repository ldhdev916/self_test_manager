import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';

final _rsaPublicKey = RSAPublicKey(
    BigInt.parse(
        "30718937712611605689191751047964347711554702318809238360089112453166217803395521606458190795722565177328746277011809492198037993902927400109154434682159584719442248913593972742086295960255192532052628569970645316811605886842040898815578676961759671712587342568414746446165948582657737331468733813122567503321355924190641302039446055143553127897636698729043365414410208454947672037202818029336707554263659582522814775377559532575089915217472518288660143323212695978110773753720635850393399040827859210693969622113812618481428838504301698541638186158736040620420633114291426890790215359085924554848097772407366395041461"),
    BigInt.parse("65537"));

final _encrypter = Encrypter(RSA(publicKey: _rsaPublicKey));

String encrypt(String s) => base64Encode(_encrypter.encrypt(s).bytes);
