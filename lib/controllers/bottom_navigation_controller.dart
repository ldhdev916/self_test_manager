import 'package:get/get.dart';
import 'package:self_test_manager/screens/data_screen.dart';
import 'package:self_test_manager/screens/main_screen.dart';

class BottomNavigationController extends GetxController {
  final _index = 0.obs;

  int get index => _index.value;

  set index(int value) => _index(value);

  final children = [MainScreen(), const DataScreen()];
}
