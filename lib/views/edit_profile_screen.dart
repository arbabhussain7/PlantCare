import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plantcare/constant/assets.dart';
import 'package:plantcare/constant/colors.dart';
import 'package:plantcare/modelView/user_controller.dart';
import 'package:plantcare/views/bottom_nav_bar.dart';
import 'package:plantcare/views/profile_screen.dart';
import 'package:plantcare/widgets/custom_profile_textField.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserController userController = Get.put(UserController());
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  
  // Text controllers for form fields
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  
  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data
    nameController = TextEditingController(text: userController.user['name'] ?? '');
    emailController = TextEditingController(text: userController.user['email'] ?? '');
    phoneController = TextEditingController(text: userController.user['phoneNumber'] ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 22.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: SvgPicture.asset(Assets.backIcon),
                    ),
                    Text(
                      'Edit Profile',
                      style: GoogleFonts.poppins(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: blackColor,
                      ),
                    ),
                    Icon(Icons.cabin, color: Colors.transparent),
                  ],
                ),
                SizedBox(height: 44.h),

                // Profile Image Section
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 77.r,
                        backgroundImage: _getImageProvider(),
                        backgroundColor: Colors.grey[300],
                        child: _selectedImage == null && (userController.user['imageUrl'] == null || userController.user['imageUrl'].toString().isEmpty)
                            ? Icon(
                                Icons.person,
                                size: 80.sp,
                                color: Colors.grey[600],
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showImagePickerDialog,
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: greenColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 22.h),
                
                // Name Field
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
                  text: 'Enter your name',
                  controller: nameController,
                ),
                SizedBox(height: 22.h),
                
                // Email Field
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
                  text: 'Enter your email',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 22.h),
                
                // Phone Number Field
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
                  text: 'Enter your phone number',
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                ),

                SizedBox(height: 88.h),
                
                // Save Changes Button
                Obx(() => userController.isLoading.value
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(greenColor),
                        ),
                      )
                    : GestureDetector(
                        onTap: _saveChanges,
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
                                'Save Changes',
                                style: GoogleFonts.poppins(
                                  fontSize: 19.sp,
                                  color: whiteColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Get image provider based on selected image or user profile image
  ImageProvider _getImageProvider() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    } else if (userController.user['imageUrl'] != null && 
               userController.user['imageUrl'].toString().isNotEmpty) {
      return NetworkImage(userController.user['imageUrl']);
    } else {
      return AssetImage(Assets.userImg);
    }
  }

  // Show image picker dialog
  void _showImagePickerDialog() {
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
                'Select Profile Photo',
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: blackColor,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImagePickerOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                  _buildImagePickerOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                  if (_selectedImage != null || 
                      (userController.user['imageUrl'] != null && 
                       userController.user['imageUrl'].toString().isNotEmpty))
                    _buildImagePickerOption(
                      icon: Icons.delete,
                      label: 'Remove',
                      onTap: _removeImage,
                      color: Colors.red,
                    ),
                ],
              ),
              SizedBox(height: 20.h),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: greyColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build image picker option widget
  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: (color ?? greenColor).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color ?? greenColor,
              size: 30.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: color ?? blackColor,
            ),
          ),
        ],
      ),
    );
  }

  // Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        Get.back(); // Close the dialog
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to pick image: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Remove selected image
  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
    Get.back(); // Close the dialog
  }

  // Save changes to Firestore
  void _saveChanges() {
    if (!_validateFields()) {
      return;
    }

    userController.updateUserProfile(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      imageFile: _selectedImage,
    );
    Get.off(()=>BottomNavigationBarScreen());
  }

  // Validate form fields
  bool _validateFields() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Please enter your name",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Please enter your email",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar(
        "Validation Error",
        "Please enter a valid email",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Please enter your phone number",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }
}