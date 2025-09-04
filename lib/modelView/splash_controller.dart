import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:plantcare/views/bottom_nav_bar.dart';
import 'package:plantcare/views/sign_in_screen.dart';


class SplashScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(seconds: 6), () {   
      if (FirebaseAuth.instance.currentUser == null) {
        Get.offAll(() => SignInScreen());;
      } else {
        Get.offAll(() => BottomNavigationBarScreen());
      }
    });
  }
}