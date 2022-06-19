import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:self_test_manager/api/api_token.dart';
import 'package:self_test_manager/api/api_util.dart';

part 'api_data.g.dart';

@JsonSerializable()
class SearchSchoolResult {
  @JsonKey(name: "schulList")
  final List<SchoolInfo> schoolList;
  final String key;

  SearchSchoolResult(this.schoolList, this.key);

  factory SearchSchoolResult.fromJson(Map<String, dynamic> json) =>
      _$SearchSchoolResultFromJson(json);

  @override
  String toString() {
    return 'SearchSchoolResult{schoolList: $schoolList, key: $key}';
  }
}

@JsonSerializable()
class SchoolInfo {
  @JsonKey(name: "kraOrgNm")
  final String orgName;
  @JsonKey(name: "orgCode")
  final String encryptedCode;

  @JsonKey(name: "juOrgCode")
  final String persistenceCode;

  @JsonKey(name: "atptOfcdcConctUrl")
  final String schoolUrl;

  @JsonKey(name: "lctnScCode")
  final String regionCode;

  SchoolInfo(this.orgName, this.encryptedCode, this.persistenceCode,
      this.schoolUrl, this.regionCode);

  factory SchoolInfo.fromJson(Map<String, dynamic> json) =>
      _$SchoolInfoFromJson(json);

  @override
  String toString() {
    return 'SchoolInfo{orgName: $orgName, encryptedCode: $encryptedCode, persistenceCode: $persistenceCode, schoolUrl: $schoolUrl, regionCode: $regionCode}';
  }
}

class FindUserQuery {
  final String name;
  final String birthday;

  const FindUserQuery({
    required this.name,
    required this.birthday,
  });

  factory FindUserQuery.of(
          {required String name, required DateTime birthday}) =>
      FindUserQuery(
          name: name, birthday: DateFormat("yyMMdd").format(birthday));
}

@JsonSerializable()
class FindUserResult {
  @UsersTokenConverter()
  final UsersToken token;

  FindUserResult(this.token);

  factory FindUserResult.fromJson(Map<String, dynamic> json) =>
      _$FindUserResultFromJson(json);
}

@JsonSerializable()
class User {
  final String orgCode;
  final String orgName;

  @JsonKey(name: "userPNo")
  final String userId;

  @UserTokenConverter()
  final UserToken token;

  @JsonKey(name: "userNameEncpt")
  final String name;

  User(this.orgCode, this.orgName, this.userId, this.token, this.name);

  @override
  String toString() {
    return 'User{orgCode: $orgCode, orgName: $orgName, userId: $userId, token: $token, name: $name}';
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class UserInfo {
  final String orgName;

  @JsonKey(name: "userPNo")
  final String userId;

  @JsonKey(name: "userName")
  final String name;

  @JsonKey(name: "registerDtm", required: false)
  final DateTime? registerDateTime;

  UserInfo(this.orgName, this.userId, this.name, this.registerDateTime);

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);

  @override
  String toString() {
    return 'UserInfo{orgName: $orgName, userId: $userId, name: $name, registerDateTime: $registerDateTime}';
  }
}

@JsonSerializable()
class ApiSurveyData {
  final String deviceUuid;
  @YesNoConverter()
  final bool rspns00;
  final String rspns01;
  final String rspns02;
  final String? rspns03;
  final String? rspns04;
  final String? rspns05;
  final String? rspns06;
  final String? rspns07;
  final String? rspns08;
  final String? rspns09;
  final String? rspns10;
  final String? rspns11;
  final String? rspns12;
  final String? rspns13;
  final String? rspns14;
  final String? rspns15;
  @UserTokenConverter()
  final UserToken upperToken;
  @JsonKey(name: "upperUserNameEncpt")
  final String name;
  final String clientVersion;

  const ApiSurveyData({
    this.deviceUuid = "",
    this.rspns00 = true,
    this.rspns01 = "1",
    this.rspns02 = "1",
    this.rspns03 = "1",
    this.rspns04,
    this.rspns05,
    this.rspns06,
    this.rspns07,
    this.rspns08,
    this.rspns09,
    this.rspns10,
    this.rspns11,
    this.rspns12,
    this.rspns13,
    this.rspns14,
    this.rspns15,
    required this.upperToken,
    required this.name,
    required this.clientVersion,
  });

  Map<String, dynamic> toJson() => _$ApiSurveyDataToJson(this);
}

enum QuickTestResult {
  none,
  positive,
  negative;

  String? get value {
    switch (this) {
      case none:
        return null;
      case QuickTestResult.negative:
        return "0";
      case QuickTestResult.positive:
        return "1";
    }
    return null;
  }
}

class SurveyData {
  final bool suspicious;
  final bool waitingResult;
  final QuickTestResult quickTest;

  const SurveyData({
    this.suspicious = false,
    this.waitingResult = false,
    this.quickTest = QuickTestResult.none,
  });

  ApiSurveyData toApi(User user, String clientVersion) {
    return ApiSurveyData(
        upperToken: user.token,
        name: user.name,
        clientVersion: clientVersion,
        rspns00: !suspicious &&
            !waitingResult &&
            quickTest != QuickTestResult.positive,
        rspns01: suspicious ? "2" : "1",
        rspns02: waitingResult ? "0" : "1",
        rspns03: quickTest == QuickTestResult.none ? "1" : null,
        rspns07: quickTest.value);
  }

  SurveyData copyWith({
    bool? suspicious,
    bool? waitingResult,
    QuickTestResult? quickTest,
  }) {
    return SurveyData(
      suspicious: suspicious ?? this.suspicious,
      waitingResult: waitingResult ?? this.waitingResult,
      quickTest: quickTest ?? this.quickTest,
    );
  }
}

@JsonSerializable()
class RegisterSurveyResult {
  @JsonKey(name: "registerDtm")
  final DateTime registerDate;

  RegisterSurveyResult(this.registerDate);

  factory RegisterSurveyResult.fromJson(Map<String, dynamic> json) =>
      _$RegisterSurveyResultFromJson(json);
}
