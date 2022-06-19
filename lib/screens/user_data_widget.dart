import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:self_test_manager/api/hcs_session.dart';
import 'package:self_test_manager/controllers/user_viewer_controller.dart';
import 'package:self_test_manager/data/user_data.dart';
import 'package:self_test_manager/screens/register_dialog.dart';
import 'package:self_test_manager/screens/user_form.dart';

final _format = DateFormat("yyyy년 M월 dd일 a h시 mm분 ss초");

class UserDataWidget extends GetResponsiveView<UserViewerController> {
  final UserData userData;

  UserDataWidget({Key? key, required this.userData}) : super(key: key);

  @override
  Widget builder() {
    return Container(
        height: screen.height * 0.2,
        margin: EdgeInsets.symmetric(
            horizontal:
                screen.isDesktop ? screen.width * 0.35 : screen.width * 0.04),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(10)),
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text("${userData.name}(${userData.school})"),
          Text(
              "마지막 제출: ${userData.lastRegisteredAt == null ? "미제출" : _format.format(userData.lastRegisteredAt!)}"),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            TextButton(
                onPressed: () => controller.removeUser(userData),
                child: const Text("삭제", style: TextStyle(color: Colors.red))),
            TextButton(
                onPressed: () {
                  Get.defaultDialog(
                      title: "사용자 수정",
                      content: UserForm(
                          onComplete: (data) =>
                              controller.replaceUser(userData, () => data),
                          initialData: userData));
                },
                child: const Text("수정")),
            TextButton(
                onPressed: () async {
                  final index = controller.users.indexOf(userData);

                  controller.replaceUserIndex(
                      index, userData.withRegisterDate(null));

                  final session = HcsSession();
                  final user = await userData.getUser(session);
                  final userInfo = await session.getUserInfo(user);

                  controller.replaceUserIndex(index,
                      userData.withRegisterDate(userInfo.registerDateTime));
                },
                child: const Text("제출 시각 확인")),
            TextButton(
                onPressed: () => Get.defaultDialog(
                    title: "자가진단 제출",
                    content: RegisterDialog(onRegister: (surveyData) async {
                      final session = HcsSession();
                      final user = await userData.getUser(session);
                      final registerSurveyResult = await session.registerSurvey(
                          surveyData.toApi(user, session.clientVersion));

                      controller.replaceUser(
                          userData,
                          () => userData.withRegisterDate(
                              registerSurveyResult.registerDate));
                    })),
                child: const Text("제출"))
          ])
        ]));
  }
}

class ReservationSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const ReservationSwitch(
      {Key? key, required this.value, required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Text("예약"),
      Switch(value: value, onChanged: onChanged)
    ]);
  }
}
