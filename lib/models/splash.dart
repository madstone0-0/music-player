
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/screens/mainTab.dart';

class SplashViewModel extends GetxController {

  var scaffoldKey = GlobalKey<ScaffoldState>();

  void loadView() async {
    await Future.delayed(const Duration(seconds: 2) );
    Get.to( () => const MainTab() );
  }

  void openDrawer(){
    scaffoldKey.currentState?.openDrawer();
  }

  void closeDrawer(){
    scaffoldKey.currentState?.closeDrawer();
  }
}
