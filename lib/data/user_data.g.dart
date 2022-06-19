// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData(
      name: json['name'] as String,
      school: json['school'] as String,
      regionCode: json['region_code'] as String?,
      stageCode: json['stage_code'] as int,
      birthday: const BirthdayConverter().fromJson(json['birthday'] as String),
      password: json['password'] as String,
      lastRegisteredAt: json['lastRegisteredAt'] == null
          ? null
          : DateTime.parse(json['lastRegisteredAt'] as String),
    );

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'name': instance.name,
      'school': instance.school,
      'region_code': instance.regionCode,
      'stage_code': instance.stageCode,
      'birthday': const BirthdayConverter().toJson(instance.birthday),
      'password': instance.password,
      'lastRegisteredAt': instance.lastRegisteredAt?.toIso8601String(),
    };
