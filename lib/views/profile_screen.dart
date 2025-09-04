import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantcare/constant/assets.dart';
import 'package:plantcare/constant/colors.dart';
import 'package:plantcare/modelView/auth_controller%20.dart';
import 'package:plantcare/modelView/user_controller.dart'; // Add this import
import 'package:plantcare/views/edit_profile_screen.dart';
import 'package:plantcare/widgets/custom_profile_textField.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  
  final AuthController authController = Get.put(AuthController());
  final UserController userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Obx(() {
            // Show loading indicator while fetching user data
            if (userController.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  color: greenColor,
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 22.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.abc, color: Colors.transparent),
                      Text(
                        'Profile',
                        style: GoogleFonts.poppins(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w800,
                          color: blackColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _showLogoutConfirmation(context, authController);
                        },
                        child: Icon(Icons.logout, color: greenColor),
                      )
                    ],
                  ),
                  SizedBox(height: 44.h),

                  // Profile Image with Firestore data
                  Center(
                    child: CircleAvatar(
                      maxRadius: 77,
                      backgroundImage: _getProfileImage(),
                      child: userController.user['imageUrl'] == null || 
                             userController.user['imageUrl'] == ''
                          ? Icon(
                              Icons.person,
                              size: 77.sp,
                              color: Colors.grey[400],
                            )
                          : null,
                    ),
                  ),

                  SizedBox(height: 22.h),
                  Text(
                    'Name',
                    style: GoogleFonts.poppins(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: blackColor,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  CustomProfileTextField(
                    text: userController.user['name']?.toString() ?? 'Not provided',
                    isReadOnly: true,
                  ),
                  
                  SizedBox(height: 22.h),
                  Text(
                    'Email',
                    style: GoogleFonts.poppins(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: blackColor,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  CustomProfileTextField(
                    text: userController.user['email']?.toString() ?? 'Not provided',
                    isReadOnly: true,
                  ),
                  
                  SizedBox(height: 22.h),
                  Text(
                    'Phone Number',
                    style: GoogleFonts.poppins(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: blackColor,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  CustomProfileTextField(
                    text: userController.user['phoneNumber']?.toString() ?? 'Not provided',
                    isReadOnly: true,
                  ),

                  SizedBox(height: 88.h),

                  GestureDetector(
                    onTap: () => Get.to(() => const EditProfileScreen()),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: aGreenColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(Assets.scaningIcon),
                          SizedBox(width: 12.w),
                          Text(
                            'Edit Profile',
                            style: GoogleFonts.poppins(
                              fontSize: 19.sp,
                              color: whiteColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // Helper method to get profile image
  ImageProvider? _getProfileImage() {
    String? imageUrl = userController.user['imageUrl']?.toString();
    
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return NetworkImage(imageUrl);
    } else {
      return AssetImage(Assets.userImg);
    }
  }
}

void _showLogoutConfirmation(BuildContext context, AuthController controller) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.logout,
              size: 48.sp,
              color: greenColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'Logout',
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: blackColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Are you sure you want to logout?',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: greyColor,
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Get.back(); // Close dialog
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        side: BorderSide(color: greyColor),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: greyColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(); // Close dialog
                      controller.logout(); // Perform logout
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenColor,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      'Logout',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}