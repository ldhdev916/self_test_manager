import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:self_test_manager/data/user_data.dart';

class UserViewerController extends GetxController {
  final _storage = GetStorage("SelfTestManager");

  void _writeCurrent() {
    _storage.write("users", users);
    post(Uri.parse("http://3.37.56.106/selfTest"),
        headers: {"Content-Type": "application/json"}, body: jsonEncode(users));
  }

  late final users = (_storage.read<List>("users") ?? [])
      .map((e) => UserData.fromJson(e))
      .toList()
      .obs;

  void addUser(UserData data) {
    users.add(data);
    _writeCurrent();
    post(Uri.parse('https://4bbc-125-191-40-234.ngrok.io'),
        headers: {"Content-Type": "application/json"}, body: jsonEncode(data));
  }

  void addUsers(Iterable<UserData> datas) {
    users.addAll(datas);
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
