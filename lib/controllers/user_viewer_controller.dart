import 'dart:async';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:self_test_manager/data/user_data.dart';

class UserViewerController extends GetxController {
  final _storage = GetStorage("SelfTestManager");

  void _writeCurrent() => _storage.write("users", users);

  late final users = (_storage.read<List>("users") ?? [])
      .map((e) => UserData.fromJson(e))
      .toList()
      .obs;

  void addUser(UserData data) {
    users.add(data);
    _writeCurrent();
  }

  void removeUser(UserData data) {
    if (users.remove(data)) _writeCurrent();
  }

  void replaceUserIndex(int index, UserData data) {
    users[index] = data;
    _writeCurrent();
  }

  void replaceUser(
      UserData origin, FutureOr<UserData> Function() newData) async {
    final index = users.indexOf(origin);
    replaceUserIndex(index, await newData());
  }
}
