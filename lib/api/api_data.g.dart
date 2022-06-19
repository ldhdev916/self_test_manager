// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchSchoolResult _$SearchSchoolResultFromJson(Map<String, dynamic> json) =>
    SearchSchoolResult(
      (json['schulList'] as List<dynamic>)
          .map((e) => SchoolInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['key'] as String,
    );

Map<String, dynamic> _$SearchSchoolResultToJson(SearchSchoolResult instance) =>
    <String, dynamic>{
      'schulList': instance.schoolList,
      'key': instance.key,
    };

SchoolInfo _$SchoolInfoFromJson(Map<String, dynamic> json) => SchoolInfo(
      json['kraOrgNm'] as String,
      json['orgCode'] as String,
      json['juOrgCode'] as String,
      json['atptOfcdcConctUrl'] as String,
      json['lctnScCode'] as String,
    );

Map<String, dynamic> _$SchoolInfoToJson(SchoolInfo instance) =>
    <String, dynamic>{
      'kraOrgNm': instance.orgName,
      'orgCode': instance.encryptedCode,
      'juOrgCode': instance.persistenceCode,
      'atptOfcdcConctUrl': instance.schoolUrl,
      'lctnScCode': instance.regionCode,
    };

FindUserResult _$FindUserResultFromJson(Map<String, dynamic> json) =>
    FindUserResult(
      const UsersTokenConverter().fromJson(json['token'] as String),
    );

Map<String, dynamic> _$FindUserResultToJson(FindUserResult instance) =>
    <String, dynamic>{
      'token': const UsersTokenConverter().toJson(instance.token),
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      json['orgCode'] as String,
      json['orgName'] as String,
      json['userPNo'] as String,
      const UserTokenConverter().fromJson(json['token'] as String),
      json['userNameEncpt'] as String,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'orgCode': instance.orgCode,
      'orgName': instance.orgName,
      'userPNo': instance.userId,
      'token': const UserTokenConverter().toJson(instance.token),
      'userNameEncpt': instance.name,
    };

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => UserInfo(
      json['orgName'] as String,
      json['userPNo'] as String,
      json['userName'] as String,
      json['registerDtm'] == null
          ? null
          : DateTime.parse(json['registerDtm'] as String),
    );

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
      'orgName': instance.orgName,
      'userPNo': instance.userId,
      'userName': instance.name,
      'registerDtm': instance.registerDateTime?.toIso8601String(),
    };

ApiSurveyData _$ApiSurveyDataFromJson(Map<String, dynamic> json) =>
    ApiSurveyData(
      deviceUuid: json['deviceUuid'] as String? ?? "",
      rspns00: json['rspns00'] == null
          ? true
          : const YesNoConverter().fromJson(json['rspns00'] as String),
      rspns01: json['rspns01'] as String? ?? "1",
      rspns02: json['rspns02'] as String? ?? "1",
      rspns03: json['rspns03'] as String? ?? "1",
      rspns04: json['rspns04'] as String?,
      rspns05: json['rspns05'] as String?,
      rspns06: json['rspns06'] as String?,
      rspns07: json['rspns07'] as String?,
      rspns08: json['rspns08'] as String?,
      rspns09: json['rspns09'] as String?,
      rspns10: json['rspns10'] as String?,
      rspns11: json['rspns11'] as String?,
      rspns12: json['rspns12'] as String?,
      rspns13: json['rspns13'] as String?,
      rspns14: json['rspns14'] as String?,
      rspns15: json['rspns15'] as String?,
      upperToken:
          const UserTokenConverter().fromJson(json['upperToken'] as String),
      name: json['upperUserNameEncpt'] as String,
      clientVersion: json['clientVersion'] as String,
    );

Map<String, dynamic> _$ApiSurveyDataToJson(ApiSurveyData instance) =>
    <String, dynamic>{
      'deviceUuid': instance.deviceUuid,
      'rspns00': const YesNoConverter().toJson(instance.rspns00),
      'rspns01': instance.rspns01,
      'rspns02': instance.rspns02,
      'rspns03': instance.rspns03,
      'rspns04': instance.rspns04,
      'rspns05': instance.rspns05,
      'rspns06': instance.rspns06,
      'rspns07': instance.rspns07,
      'rspns08': instance.rspns08,
      'rspns09': instance.rspns09,
      'rspns10': instance.rspns10,
      'rspns11': instance.rspns11,
      'rspns12': instance.rspns12,
      'rspns13': instance.rspns13,
      'rspns14': instance.rspns14,
      'rspns15': instance.rspns15,
      'upperToken': const UserTokenConverter().toJson(instance.upperToken),
      'upperUserNameEncpt': instance.name,
      'clientVersion': instance.clientVersion,
    };

RegisterSurveyResult _$RegisterSurveyResultFromJson(
        Map<String, dynamic> json) =>
    RegisterSurveyResult(
      DateTime.parse(json['registerDtm'] as String),
    );

Map<String, dynamic> _$RegisterSurveyResultToJson(
        RegisterSurveyResult instance) =>
    <String, dynamic>{
      'registerDtm': instance.registerDate.toIso8601String(),
    };
