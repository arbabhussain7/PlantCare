import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantcare/constant/assets.dart';
import 'package:plantcare/constant/colors.dart';
import 'package:plantcare/modelView/bottom_nav_bar_controller.dart';

class BottomNavigationBarScreen extends StatelessWidget {
  BottomNavigationBarScreen({super.key});
  
  final BottomNavigationBarController controller =
      Get.put(BottomNavigationBarController());

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.7),
        extendBody: true,
        body: Obx(() => controller.currentWidget), // Fixed: Direct access to getter
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 22.w),
          margin: EdgeInsets.symmetric(vertical: 9.h, horizontal: 22.w),
          decoration: BoxDecoration(
            color: greenColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(33.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Home Nav Item
              Obx(() => GestureDetector(
                onTap: () => controller.changeIndex(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      Assets.homeIcon,
                      width: 36.w,
                      height: 36.h,
                      colorFilter: ColorFilter.mode(
                        controller.selectedIndex.value == 0 ? whiteColor : whiteColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    Text(
                      'Home',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: controller.selectedIndex.value == 0 ? whiteColor : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              )),

              // Scan Nav Item
              Obx(() => GestureDetector(
                onTap: () => controller.changeIndex(1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      Assets.scanIcon,
                      width: 36.w,
                      height: 36.h,
                      colorFilter: ColorFilter.mode(
                        controller.selectedIndex.value == 1 ? whiteColor : whiteColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    Text(
                      'Scan',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: controller.selectedIndex.value == 1 ? whiteColor : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              )),

              // Notifications Nav Item
              Obx(() => GestureDetector(
                onTap: () => controller.changeIndex(2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      Assets.notificationIcon,
                      width: 36.w,
                      height: 36.h,
                      colorFilter: ColorFilter.mode(
                        controller.selectedIndex.value == 2 ? whiteColor : whiteColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    Text(
                      'Notifications',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: controller.selectedIndex.value == 2 ? whiteColor : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              )),

              // Profile Nav Item
              Obx(() => GestureDetector(
                onTap: () => controller.changeIndex(3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      Assets.profileIcon,
                      width: 36.w,
                      height: 36.h,
                      color: controller.selectedIndex.value == 3 ? whiteColor : whiteColor,
                    ),
                    Text(
                      'Profile',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: controller.selectedIndex.value == 3 ? whiteColor : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}