import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasswordController extends GetxController {
  // Text controller for password field
  final TextEditingController passwordController = TextEditingController();
  
  // Observable for password visibility
  final RxBool isPasswordVisible = false.obs;
  
  // Method to toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
  
  // Password validation method
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    // Add more validation rules as needed
    // if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
    //   return 'Password must contain uppercase, lowercase and number';
    // }
    return null;
  }
  
  // Clear password field
  void clearPassword() {
    passwordController.clear();
  }
  
  // Dispose method to clean up resources
  @override
  void onClose() {
    passwordController.dispose();
    super.onClose();
  }
}