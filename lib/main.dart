import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:self_test_manager/screens/root.dart';

import 'controllers/user_viewer_controller.dart';

void main() async {
  await GetStorage.init("SelfTestManager");

  Intl.defaultLocale = "ko_KR";

  runApp(const MyApp());
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
          )
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
