import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_responsive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:self_test_manager/api/hcs_session.dart';
import 'package:self_test_manager/controllers/user_viewer_controller.dart';

import '../data/user_data.dart';

class MainButton extends GetResponsiveView {
  final VoidCallback onPressed;
  final Icon icon;
  final String labelText;
  final Color color;

  MainButton(
      {Key? key,
      required this.onPressed,
      required this.icon,
      required this.labelText,
      required this.color})
      : super(key: key);

  @override
  Widget builder() {
    final width = screen.width * 0.5;
    return SizedBox(
        width: width,
        height: screen.height * 0.06,
        child: ElevatedButton.icon(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(color),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(width)))),
            onPressed: onPressed,
            icon: icon,
            label: Text(labelText)));
  }
}

class DataScreen extends GetView<UserViewerController> {
  const DataScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("사용자 데이터"), centerTitle: true),
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
            MainButton(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ["json"],
                      withData: true);
                  if (result == null) return;
                  try {
                    final file = result.files.single;
                    final decoded = jsonDecode(utf8.decode(file.bytes!));
                    if (decoded is! List) throw "올바르지 않은 데이터 입니다";
                    final list = decoded.map((e) async {
                      final UserData userData = UserData.fromJson(e);
                      final session = HcsSession();
                      final user = await userData.getUser(session);
                      final userInfo = await session.getUserInfo(user);

                      return userData
                          .withRegisterDate(userInfo.registerDateTime);
                    });

                    controller.addUsers(await Future.wait(list));

                    Get.snackbar(
                        "받아오기 성공", "성공적으로 ${list.length}개의 데이터를 불러왔습니다");
                  } catch (e) {
                    Get.snackbar("받아오기 실패", "데이터를 받아오는데 실패했습니다: $e");
                  }
                },
                icon: const Icon(Icons.add),
                labelText: "데이터 받아오기",
                color: Colors.green),
            MainButton(
                onPressed: () async {
                  final directory = (await (Platform.isAndroid
                      ? getExternalStorageDirectory()
                      : getDownloadsDirectory()))!;

                  if (!(await directory.exists())) {
                    directory.create(recursive: true);
                  }

                  await File("${directory.path}/자가진단 데이터.json")
                      .writeAsString(jsonEncode(controller.users));
                  Get.snackbar("추출 성공", "자가진단 사용자 데이터가 폴더에 저장되었습니다");
                },
                icon: const Icon(Icons.output),
                labelText: "데이터 추출",
                color: Colors.indigo)
          ])),
    );
  }
}
