import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

import '../api/api_data.dart';
import '../api/hcs_session.dart';

part 'user_data.g.dart';

@JsonSerializable()
class UserData {
  final String name;
  final String school;
  @JsonKey(name: "region_code")
  final String? regionCode;

  @JsonKey(name: "stage_code")
  final int stageCode;

  @BirthdayConverter()
  final DateTime birthday;
  final String password;

  @JsonKey(name: "last_registered_at")
  final DateTime? lastRegisteredAt;

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserDataToJson(this);

  Future<User> getUser(HcsSession session) async {
    final searchSchoolResponse = await session.searchSchool(
        orgName: school, regionCode: regionCode, stageCode: stageCode);
    session.schoolInfo = searchSchoolResponse.schoolList.single;
    final query = FindUserQuery.of(name: name, birthday: birthday);
    final findUserResult =
        await session.findUser(query, searchSchoolResponse.key, password);
    final user = (await session.selectUserGroup(findUserResult.token)).single;

    return user;
  }

  const UserData(
      {required this.name,
      required this.school,
      required this.regionCode,
      required this.stageCode,
      required this.birthday,
      required this.password,
      required this.lastRegisteredAt});

  UserData copyWith(
      {String? name,
      String? school,
      String? regionCode,
      int? stageCode,
      DateTime? birthday,
      String? password,
      bool? isReserved}) {
    return UserData(
        name: name ?? this.name,
        school: school ?? this.school,
        regionCode: regionCode ?? this.regionCode,
        stageCode: stageCode ?? this.stageCode,
        birthday: birthday ?? this.birthday,
        password: password ?? this.password,
        lastRegisteredAt: lastRegisteredAt);
  }

  UserData withRegisterDate(DateTime? lastRegisteredAt) => UserData(
      name: name,
      school: school,
      regionCode: regionCode,
      stageCode: stageCode,
      birthday: birthday,
      password: password,
      lastRegisteredAt: lastRegisteredAt);
}

class BirthdayConverter extends JsonConverter<DateTime, String> {
  const BirthdayConverter();

  static final _format = DateFormat.yMd();

  @override
  DateTime fromJson(String json) => _format.parse(json);

  @override
  String toJson(DateTime object) => _format.format(object);
}
