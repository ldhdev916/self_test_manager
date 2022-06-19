import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:self_test_manager/api/hcs_session.dart';
import 'package:self_test_manager/controllers/user_viewer_controller.dart';
import 'package:self_test_manager/screens/user_data_widget.dart';
import 'package:self_test_manager/screens/user_form.dart';

class Root extends GetResponsiveView<UserViewerController> {
  Root({Key? key}) : super(key: key);

  @override
  Widget builder() {
    return Scaffold(
        appBar:
            AppBar(title: const Text("자가진단 관리"), centerTitle: true, actions: [
          IconButton(
              onPressed: () {
                for (final element in controller.users) {
                  Future(() async {
                    final index = controller.users.indexOf(element);

                    controller.replaceUserIndex(
                        index, element.withRegisterDate(null));

                    final session = HcsSession();
                    final user = await element.getUser(session);
                    final userInfo = await session.getUserInfo(user);

                    controller.replaceUserIndex(index,
                        element.withRegisterDate(userInfo.registerDateTime));
                  });
                }
              },
              icon: const Icon(Icons.refresh)),
          IconButton(
              onPressed: () => Get.defaultDialog(
                  title: "사용자 추가",
                  content:
                      UserForm(onComplete: (data) => controller.addUser(data))),
              icon: const Icon(Icons.add))
        ]),
        body: Center(
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: screen.height * 0.04),
                child: Obx(() => ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (_, index) =>
                        UserDataWidget(userData: controller.users[index]),
                    separatorBuilder: (_, __) =>
                        SizedBox(height: screen.height * 0.02),
                    itemCount: controller.users.length)))));
  }
}
