import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantcare/constant/assets.dart';
import 'package:plantcare/constant/colors.dart';
import 'package:plantcare/modelView/auth_controller%20.dart';
import 'package:plantcare/modelView/user_controller.dart'; // Add this import
import 'package:plantcare/views/sign_up_sceen.dart';
import 'package:plantcare/widgets/custom_button.dart';
import 'package:plantcare/widgets/custom_email_textfield.dart';
import 'package:plantcare/widgets/custom_pssword_textfield.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize UserController first to avoid dependency error
    Get.put(UserController());
    final AuthController authController = Get.put(AuthController());
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 250.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(200.r),
                  bottomLeft: Radius.circular(200.r),
                ),
                image: DecorationImage(
                  image: AssetImage(Assets.bgimg),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
                  Assets.logoIcon,
                  width: 200.w,
                  height: 110.h,
                ),
              ),
            ),
            SizedBox(height: 66.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 55.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome',
                    style: GoogleFonts.poppins(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w600,
                      color: blackColor,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Log in to your account',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: blackColor,
                    ),
                  ),
                  SizedBox(height: 22.h),
                  
                  // Email TextField
                  CustomEmailTextField(
                    text: 'Enter your email',
                    controller: authController.loginEmailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 22.h),

                  // Password TextField
                  CustomPasswordTextField(
                    label: 'Password',
                    hint: '************',
                    controller: authController.loginPasswordController,
                  ),

                  SizedBox(height: 12.h),
                  
                  // Forget Password
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Implement forgot password functionality
                        _showForgotPasswordDialog(context, authController);
                      },
                      child: Text(
                        'Forget Password?',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: greenColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 44.h),
                  
                  // Log In Button with loading state
                  Center(
                    child: Obx(() => authController.isLoading.value
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(greenColor),
                          )
                        : GestureDetector(  onTap: () {
                              // Validate fields before calling login
                              if (_validateLoginFields(authController)) {
                                authController.login();
                              }
                            },
                          child: CustomButton(
                              text: 'Log In',
                            
                            ),
                        )),
                  ),
                  SizedBox(height: 22.h),
                  
                  // Sign Up Navigation
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const SignUpScreen());
                    },
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          text: 'Don\'t have an account? ',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: greyColor,
                          ),
                          children: [
                            TextSpan(
                              text: 'Signup',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: greenColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to validate login fields
  bool _validateLoginFields(AuthController controller) {
    if (controller.loginEmailController.text.trim().isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Please enter your email",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    
    if (!GetUtils.isEmail(controller.loginEmailController.text.trim())) {
      Get.snackbar(
        "Validation Error",
        "Please enter a valid email",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    
    if (controller.loginPasswordController.text.trim().isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Please enter your password",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    
    return true;
  }

  // Helper method to show forgot password dialog
  void _showForgotPasswordDialog(BuildContext context, AuthController controller) {
    TextEditingController resetEmailController = TextEditingController();
    
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
              Text(
                'Reset Password',
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: blackColor,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Enter your email address to receive a password reset link',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: greyColor,
                ),
              ),
              SizedBox(height: 20.h),
              CustomEmailTextField(
                text: 'Enter your email',
                controller: resetEmailController,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Get.back();
                        resetEmailController.dispose();
                      },
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
                  SizedBox(width: 10.w),
                  // Expanded(
                  //   child: GestureDetector( onTap: () {
                  //       controller.forgotPassword(resetEmailController.text.trim());
                  //       Get.back();
                  //       resetEmailController.dispose();
                  //     },
                  //     child: CustomButton(
                  //       text: 'Send Reset Link',
                       
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to handle forgot password
  void _handleForgotPassword(String email) {
    if (email.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter your email address",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        "Error",
        "Please enter a valid email address",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // TODO: Implement password reset functionality
    // You can add this method to your AuthController
    Get.snackbar(
      "Success",
      "Password reset link sent to $email",
      backgroundColor: greenColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}