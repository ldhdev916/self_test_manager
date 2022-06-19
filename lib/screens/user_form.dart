import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:self_test_manager/api/api_data.dart';
import 'package:self_test_manager/api/api_util.dart';
import 'package:self_test_manager/data/user_data.dart';

import '../api/hcs_session.dart';

class UserForm extends GetResponsiveView {
  final void Function(UserData) onComplete;

  late final Rx<UserData> _data;

  UserForm({Key? key, required this.onComplete, UserData? initialData})
      : super(key: key) {
    _data = (initialData ??
            UserData(
                name: "",
                school: "",
                regionCode: null,
                stageCode: 0,
                birthday: DateTime(0),
                password: "",
                lastRegisteredAt: null))
        .obs;
  }

  bool _validate() {
    final data = _data.value;
    return data.name.isNotEmpty &&
        data.name.codeUnits.every((element) =>
            element >= "가".codeUnitAt(0) && element <= "힣".codeUnitAt(0)) &&
        data.school.isNotEmpty &&
        data.stageCode != 0 &&
        data.birthday.year != 0 &&
        data.password.length == 4 &&
        int.tryParse(data.password) != null;
  }

  void _openBirthdayPicker() async {
    final date = await showDatePicker(
        context: Get.context!,
        initialDate: DateTime(2006, 9, 16),
        firstDate: DateTime(1960, 1, 1),
        lastDate: DateTime(2022, 12, 31));
    if (date == null) return;
    _data(_data.value.copyWith(birthday: date));
  }

  Future<SchoolInfo> _tryPickSchoolInfo(List<SchoolInfo> schoolList) async {
    switch (schoolList.length) {
      case 0:
        throw "학교를 찾을 수 없습니다. 정보를 다시 입력해주세요";
      case 1:
        return schoolList.single;
      default:
        SchoolInfo? schoolInfo;
        await Get.defaultDialog(
            title: "학교 선택",
            content: SizedBox(
                width: screen.height * 0.4,
                height: screen.height * 0.4,
                child: ListView(
                  children: schoolList
                      .map((e) => TextButton(
                          onPressed: () {
                            schoolInfo = e;
                            Get.back();
                          },
                          child: Text(e.orgName)))
                      .toList(),
                )));

        if (schoolInfo == null) throw "학교를 선택해 주세요";

        return schoolInfo!;
    }
  }

  Future<String?> _apiValidateData() async {
    final data = _data.value;
    if (data.school.length < 2) return "학교 이름을 2글자 이상으로 입력해주세요";

    try {
      final session = HcsSession();
      final searchSchoolResponse = await session.searchSchool(
          orgName: data.school,
          regionCode: data.regionCode,
          stageCode: data.stageCode);
      session.schoolInfo =
          await _tryPickSchoolInfo(searchSchoolResponse.schoolList);

      final query = FindUserQuery.of(name: data.name, birthday: data.birthday);
      final FindUserResult findUserResponse;

      try {
        findUserResponse = await session.findUser(
            query, searchSchoolResponse.key, data.password);
      } catch (_) {
        throw "사용자 정보가 올바르지 않습니다. 정보를 다시 확인해주세요";
      }

      final users = await session.selectUserGroup(findUserResponse.token);
      if (users.length != 1) {
        throw "한 계정에 여러명의 사용자를 등록 한 경우 사용 불가능 합니다";
      }
      final user = users.single;

      final userInfo = await session.getUserInfo(user);

      _data(data
          .copyWith(school: user.orgName)
          .withRegisterDate(userInfo.registerDateTime));

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Widget builder() {
    return Flexible(
        child: SingleChildScrollView(
            child: SizedBox(
                height: screen.height * 0.6,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextField(
                          controller:
                              TextEditingController(text: _data.value.name),
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(), labelText: "이름"),
                          onChanged: (s) =>
                              _data(_data.value.copyWith(name: s))),
                      TextField(
                          controller:
                              TextEditingController(text: _data.value.school),
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(), labelText: "학교"),
                          onChanged: (s) =>
                              _data(_data.value.copyWith(school: s))),
                      DropdownButtonFormField<String>(
                          value: _data.value.regionCode,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "지역(선택)"),
                          items: regionCodes.entries
                              .map((e) => DropdownMenuItem(
                                  value: e.value, child: Text(e.key)))
                              .toList(),
                          onChanged: (e) {
                            if (e == null) return;
                            _data(_data.value.copyWith(regionCode: e));
                          }),
                      DropdownButtonFormField<int>(
                          value: _data.value.stageCode == 0
                              ? null
                              : _data.value.stageCode,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(), labelText: "학교 단계"),
                          items: stageCodes.entries
                              .map((e) => DropdownMenuItem(
                                  value: e.value, child: Text(e.key)))
                              .toList(),
                          onChanged: (e) {
                            if (e == null) return;
                            _data(_data.value.copyWith(stageCode: e));
                          }),
                      Obx(() => TextButton(
                          onPressed: _openBirthdayPicker,
                          child: Text(_data.value.birthday.year == 0
                              ? "생일 선택"
                              : DateFormat("yyyy년 M월 dd일")
                                  .format(_data.value.birthday)))),
                      TextField(
                          keyboardType: TextInputType.number,
                          controller:
                              TextEditingController(text: _data.value.password),
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(), labelText: "비밀번호"),
                          onChanged: (s) =>
                              _data(_data.value.copyWith(password: s))),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Obx(() => TextButton(
                            onPressed: _validate()
                                ? () async {
                                    final errorMessage =
                                        await _apiValidateData();
                                    if (errorMessage != null) {
                                      Get.snackbar("에러가 발생했습니다", errorMessage);
                                      return;
                                    }
                                    onComplete(_data.value);
                                    Get.back();
                                  }
                                : null,
                            child: const Text("완료")))
                      ])
                    ]))));
  }
}
