import 'package:get/get.dart';

enum Tabs {
  HOME(0),
  LIBRARY(1),
  HISTORY(2),
  SCAN(3);

  final int val;

  factory Tabs.fromVal(int val) {
    return Tabs.values.firstWhere((tab) => tab.val == val, orElse: () => Tabs.HOME);
  }

  const Tabs(this.val);
}

class MainTabViewModel extends GetxController {
  final selectedIndex = Tabs.HOME.val.obs;

  void changeTab(Tabs tab) {
    selectedIndex.value = tab.val;
  }
}
