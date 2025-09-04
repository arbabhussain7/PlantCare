import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:plantcare/constant/assets.dart';
import 'package:plantcare/modelView/splash_controller.dart';

class SplashScreen extends StatelessWidget {
   SplashScreen({super.key});

  final SplashScreenController controller = Get.put(SplashScreenController());
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.bgimg),
          fit: BoxFit.cover,
        ),
      ),
   child: Center(child: SvgPicture.asset(Assets.logoIcon),), );
  }
}
