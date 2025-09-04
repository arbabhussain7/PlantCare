import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantcare/constant/assets.dart';
import 'package:plantcare/constant/colors.dart';
import 'package:plantcare/modelView/auth_controller%20.dart';
import 'package:plantcare/modelView/user_controller.dart';
import 'package:plantcare/views/sign_in_screen.dart';
import 'package:plantcare/widgets/custom_button.dart';
import 'package:plantcare/widgets/custom_email_textfield.dart';
import 'package:plantcare/widgets/custom_pssword_textfield.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

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
                    'Register to your account',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: blackColor,
                    ),
                  ),
                  SizedBox(height: 22.h),
                  
                  // Name TextField
                  CustomEmailTextField(
                    text: 'Enter your name',
                    controller: authController.usernameController,
                  ),
                  SizedBox(height: 22.h),
                  
                  // Email TextField
                  CustomEmailTextField(
                    text: 'Enter your email',
                    controller: authController.emailController,
                  ),
                  SizedBox(height: 22.h),
                  
                  // Phone TextField (Added since it's required in your controller)
                  CustomEmailTextField(
                    text: 'Enter your phone number',
                    controller: authController.phoneController,
                  ),
                  SizedBox(height: 22.h),

                  // Password TextField
                  CustomPasswordTextField(
                    label: 'Password',
                    hint: '************',
                    controller: authController.passwordController,
                  ),
                  SizedBox(height: 20.h),
                  
                  // Confirm Password TextField (You might want to add a separate controller for this)
                  const CustomPasswordTextField(
                    label: 'Confirm Password',
                    hint: '************',
                  ),

                  SizedBox(height: 44.h),
                  
                  // Sign Up Button with loading state
                  Center(
                    child: Obx(() => authController.isLoading.value
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(greenColor),
                          )
                        : GestureDetector(  onTap: () {
                              // Validate fields before calling register
                              if (_validateFields(authController)) {
                                authController.register();
                              }
                            },
                          child: CustomButton(
                              text: 'Sign Up',
                            
                            ),
                        )),
                  ),
                  SizedBox(height: 22.h),
                  
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const SignInScreen());
                    },
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: greyColor,
                          ),
                          children: [
                            TextSpan(
                              text: 'Login',
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

  // Helper method to validate fields
  bool _validateFields(AuthController controller) {
    if (controller.usernameController.text.trim().isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Please enter your name",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    
    if (controller.emailController.text.trim().isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Please enter your email",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    
    if (!GetUtils.isEmail(controller.emailController.text.trim())) {
      Get.snackbar(
        "Validation Error",
        "Please enter a valid email",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    
    if (controller.phoneController.text.trim().isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Please enter your phone number",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    
    if (controller.passwordController.text.trim().isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Please enter your password",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    
    if (controller.passwordController.text.length < 6) {
      Get.snackbar(
        "Validation Error",
        "Password must be at least 6 characters",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    
    return true;
  }
}