import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantcare/constant/colors.dart';

class UserController extends GetxController {
  var isLoading = false.obs;
  var user = {}.obs;

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  @override
  onInit() {
    super.onInit();
    getUser();
  }

  Future<void> getUser() async {
    try {
      isLoading(true);
      if (auth.currentUser != null) {
        var usr = await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .get();
        print(usr.data());
        user(usr.data());

        // Update text controllers with user data
        nameController.text = user['name'] ?? '';
        emailController.text = user['email'] ?? '';
        phoneController.text = user['phoneNumber'] ?? '';
      } else {
        user.clear();
        nameController.clear();
        emailController.clear();
        phoneController.clear();
      }
    } catch (e) {
      print(e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Update user profile with image upload
  Future<void> updateUserProfile({
    required String name,
    required String email,
    required String phoneNumber,
    File? imageFile,
  }) async {
    try {
      isLoading(true);

      if (auth.currentUser == null) {
        _showErrorSnackbar("Error", "User not authenticated");
        return;
      }

      String? imageUrl;
      
      // Upload image if provided
      if (imageFile != null) {
        imageUrl = await _uploadProfileImage(imageFile);
      }

      // Prepare update data
      Map<String, dynamic> updateData = {
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add imageUrl to update data if new image was uploaded
      if (imageUrl != null) {
        updateData['imageUrl'] = imageUrl;
      }

      // Update Firestore document
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .update(updateData);

      // Update local user data
      user.addAll(updateData);

      _showSuccessSnackbar("Success", "Profile updated successfully");
      
      // Go back to previous screen
      Get.back();

    } catch (e) {
      print("Error updating profile: $e");
      _handleUpdateError(e);
    } finally {
      isLoading(false);
    }
  }

  // Upload profile image to Firebase Storage
  Future<String?> _uploadProfileImage(File imageFile) async {
    try {
      String fileName = 'profile_images/${auth.currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Create a reference to Firebase Storage
      Reference storageRef = storage.ref().child(fileName);
      
      // Upload file
      UploadTask uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
        ),
      );

      // Wait for upload to complete
      TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      print("Image uploaded successfully: $downloadUrl");
      return downloadUrl;

    } catch (e) {
      print("Error uploading image: $e");
      throw e;
    }
  }

  // Delete old profile image from storage
  Future<void> _deleteOldProfileImage(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty && imageUrl.contains('firebase')) {
        Reference storageRef = storage.refFromURL(imageUrl);
        await storageRef.delete();
        print("Old profile image deleted");
      }
    } catch (e) {
      print("Error deleting old image: $e");
      // Don't throw error as this is not critical
    }
  }

  // Update specific user field
  Future<void> updateUserField(String field, dynamic value) async {
    try {
      if (auth.currentUser == null) return;

      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .update({
            field: value,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Update local user data
      user[field] = value;

    } catch (e) {
      print("Error updating $field: $e");
      _showErrorSnackbar("Error", "Failed to update $field");
    }
  }

  // Delete user profile image
  Future<void> deleteProfileImage() async {
    try {
      isLoading(true);

      if (auth.currentUser == null) return;

      String? currentImageUrl = user['imageUrl'];
      
      // Delete image from storage if exists
      if (currentImageUrl != null && currentImageUrl.isNotEmpty) {
        await _deleteOldProfileImage(currentImageUrl);
      }

      // Update Firestore document
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .update({
            'imageUrl': '',
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Update local user data
      user['imageUrl'] = '';

      _showSuccessSnackbar("Success", "Profile image removed");

    } catch (e) {
      print("Error deleting profile image: $e");
      _showErrorSnackbar("Error", "Failed to remove profile image");
    } finally {
      isLoading(false);
    }
  }

  // Handle different types of update errors
  void _handleUpdateError(dynamic error) {
    String errorMessage;
    
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          errorMessage = 'Permission denied. Please check your account permissions.';
          break;
        case 'unavailable':
          errorMessage = 'Service temporarily unavailable. Please try again later.';
          break;
        case 'deadline-exceeded':
          errorMessage = 'Request timeout. Please check your internet connection.';
          break;
        default:
          errorMessage = 'Update failed: ${error.message}';
      }
    } else {
      errorMessage = 'Failed to update profile. Please try again.';
    }
    
    _showErrorSnackbar("Update Failed", errorMessage);
  }

  // Show success snackbar
  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: greenColor,
      snackPosition: SnackPosition.BOTTOM,
      titleText: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 14.sp, color: whiteColor),
      ),
      messageText: Text(
        message,
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: whiteColor,
        ),
      ),
    );
  }

  // Show error snackbar
  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red,
      snackPosition: SnackPosition.BOTTOM,
      titleText: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 14.sp, color: whiteColor),
      ),
      messageText: Text(
        message,
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: whiteColor,
        ),
      ),
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}