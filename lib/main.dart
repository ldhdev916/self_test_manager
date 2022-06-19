import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:self_test_manager/screens/root.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';

import 'controllers/bottom_navigation_controller.dart';
import 'controllers/user_viewer_controller.dart';

void main() async {
  await GetStorage.init("SelfTestManager");

  Intl.defaultLocale = "ko_KR";

  runApp(const MyApp());

  if (await _isOutdated()) {
    final String assetName;
    if (Platform.isAndroid) {
      assetName = "app.apk";
    } else if (Platform.isWindows) {
      assetName = "default.zip";
    } else {
      return;
    }
    final assetUrl = await _getAssetUrl(assetName);

    Get.defaultDialog(
        title: "업데이트",
        middleText: "새로운 버전의 업데이트가 있습니다\n다운로드 하시겠습니까?",
        confirm: TextButton(
            onPressed: () {
              launchUrl(assetUrl, mode: LaunchMode.externalApplication);
            },
            child: const Text("다운로드")));
  }
}

final _version = Version(1, 0, 0);

Future<bool> _isOutdated() async {
  final response = await get(Uri.parse(
      "https://api.github.com/repos/ldhdev916/self_test_manager/releases/latest"));
  final map = jsonDecode(response.body);
  final latestTag = map["tag_name"] as String?;
  if (latestTag == null) return false;
  return Version.parse(latestTag.substring(1)) > _version;
}

Future<Uri> _getAssetUrl(String asset) async {
  final response = await get(Uri.parse(
      "https://api.github.com/repos/ldhdev916/self_test_manager/releases/latest"));
  final map = jsonDecode(response.body);

  final assets = map["assets"] as List;

  return Uri.parse(assets.firstWhere(
      (element) => element["name"] == asset)["browser_download_url"]);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        initialRoute: "/",
        getPages: [
          GetPage(
              name: "/",
              page: () => Root(),
              binding: BindingsBuilder(() {
                Get.put(BottomNavigationController());
              }))
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: const [Locale("ko", "KR")],
        initialBinding: BindingsBuilder(() {
          Get.put(UserViewerController());
        }));
  }
}
