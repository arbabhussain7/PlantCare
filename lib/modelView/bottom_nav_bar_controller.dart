import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plantcare/views/home_screen.dart';
import 'package:plantcare/views/notification_screen.dart';
import 'package:plantcare/views/profile_screen.dart';
import 'package:plantcare/views/scan_screen.dart';

class BottomNavigationBarController extends GetxController {
  RxInt selectedIndex = 0.obs;
    Widget get currentWidget {
    switch (selectedIndex.value) {
      case 0:
        return HomeScreen();
      case 1:
        return ScanScreen();
      case 2:
        return NotificationScreen();
      case 3:
        return ProfileScreen();
      default:
        return HomeScreen();
    }
  }
  
  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}