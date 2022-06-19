import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:self_test_manager/api/api_data.dart';
import 'package:self_test_manager/api/api_encrypt.dart';
import 'package:self_test_manager/api/api_token.dart';
import 'package:self_test_manager/api/api_util.dart';

import 'api_transkey.dart';

class HcsSession {
  var _clientVersion = "";

  String get clientVersion => _clientVersion;
  var _cookie = "";

  late SchoolInfo schoolInfo;

  String get _schoolUrl => "https://${schoolInfo.schoolUrl}";

  Future<SearchSchoolResult> searchSchool(
      {required String orgName,
      String? regionCode,
      required int stageCode}) async {
    final parameters = {
      "orgName": orgName,
      "schulCrseScCode": stageCode.toString()
    };
    if (regionCode != null) parameters["lctnScCode"] = regionCode;

    final uri = Uri.parse("$apiUrl/v2/searchSchool")
        .replace(queryParameters: parameters);

    final response = await http.get(uri);

    _clientVersion = response.headers["x-client-version"]!;

    return SearchSchoolResult.fromJson(jsonDecode(response.body));
  }

  Future<FindUserResult> findUser(
      FindUserQuery query, String searchKey, String password) async {
    assert(password.length == 4);
    final encryptedName = encrypt(query.name);
    final encryptedBirthday = encrypt(query.birthday);

    Future<String> getRaonPassword() async {
      final transkey = await getTranskey(transkeyUrl);
      final keyPad = await transkey.newKeypad();

      final encrypted = keyPad.encryptPassword(password);
      final hm = transkey.hmacDigest(utf8.encode(encrypted));
      final json = {
        "raon": [
          {
            "id": "password",
            "enc": encrypted,
            "hmac": hm,
            "keyboardType": "number",
            "keyIndex": keyPad.keyIndex,
            "fieldType": "password",
            "seedKey": transkey.crypto.encryptedKey,
            "initTime": transkey.initTime,
            "ExE2E": "false"
          }
        ]
      };

      return jsonEncode(json);
    }

    final raonPassword = await getRaonPassword();
    final body = {
      "orgCode": schoolInfo.encryptedCode,
      "orgName": schoolInfo.orgName,
      "name": encryptedName,
      "birthday": encryptedBirthday,
      "loginType": "school",
      "searchKey": searchKey,
      "deviceUuid": "",
      "lctnScCode": schoolInfo.regionCode,
      "makeSession": "true",
      "password": raonPassword
    };

    final response = await http.post(Uri.parse("$_schoolUrl/v3/findUser"),
        headers: {"Content-Type": "application/json;charset=utf-8"},
        body: jsonEncode(body));

    _cookie = response.headers["set-cookie"]!.split(",").join(";");

    return FindUserResult.fromJson(jsonDecode(response.body));
  }

  Future<List<User>> selectUserGroup(UsersToken token) async {
    final response = await http.post(
        Uri.parse("$_schoolUrl/v2/selectUserGroup"),
        headers: {"Authorization": token.token, "cookie": _cookie},
        body: "{}");

    return (jsonDecode(response.body) as List)
        .map((e) => User.fromJson(e))
        .toList();
  }

  Future<UserInfo> getUserInfo(User user) async {
    final response = await http.post(Uri.parse("$_schoolUrl/v2/getUserInfo"),
        headers: {
          "Authorization": user.token.token,
          "Content-Type": "application/json;charset=utf-8",
          "cookie": _cookie
        },
        body: jsonEncode(user));

    return UserInfo.fromJson(jsonDecode(response.body));
  }

  Future<RegisterSurveyResult> registerSurvey(
      ApiSurveyData apiSurveyData) async {
    final response = await http.post(Uri.parse("$_schoolUrl/registerServey"),
        headers: {
          "Authorization": apiSurveyData.upperToken.token,
          "Content-Type": "application/json;charset=utf-8",
          "cookie": _cookie
        },
        body: jsonEncode(apiSurveyData));

    return RegisterSurveyResult.fromJson(jsonDecode(response.body));
  }
}
