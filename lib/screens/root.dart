import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:self_test_manager/controllers/bottom_navigation_controller.dart';

class Root extends GetResponsiveView<BottomNavigationController> {
  Root({Key? key}) : super(key: key);

  @override
  Widget builder() {
    return Scaffold(
        body: Obx(() => controller.children[controller.index]),
        bottomNavigationBar: Obx(() => BottomNavigationBar(
                onTap: (index) => controller.index = index,
                currentIndex: controller.index,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.data_object), label: "데이터")
                ])));
  }
}
