import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantcare/constant/colors.dart';
import 'package:plantcare/modelView/user_controller.dart';
import 'package:plantcare/views/bottom_nav_bar.dart';
import 'package:plantcare/views/home_screen.dart';
import 'package:plantcare/views/sign_in_screen.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController loginEmailController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  
  UserController get userController => Get.put(UserController());
  var user = {}.obs;

  Future<void> createUser(String uid) async {
    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        print("Attempting to create user document (attempt ${retryCount + 1})...");
        
        // Initialize Firestore settings if needed
        if (retryCount == 0) {
          await _initializeFirestore();
        }
        
        await firestore
            .collection("users")
            .doc(uid)
            .set({
              'name': usernameController.text.trim(),
              'email': emailController.text.trim(),
              'phoneNumber': phoneController.text.trim(),
              'imageUrl': "",
              'uid': uid,
              'token': "",
              'createdAt': FieldValue.serverTimestamp(),
            })
            .timeout(const Duration(seconds: 15));
        
        print("User document created successfully");
        return; // Success, exit the retry loop
        
      } catch (e) {
        retryCount++;
        print("Error creating user document (attempt $retryCount): $e");
        
        if (retryCount >= maxRetries) {
          throw e; // Re-throw after max attempts
        }
        
        // Wait before retrying
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }
  }

  Future<void> _initializeFirestore() async {
    try {
      // Enable offline persistence
      // await firestore.enablePersistence();
      print("Firestore persistence enabled");
    } catch (e) {
      print("Firestore persistence already enabled or error: $e");
    }
  }

  void register() async {
    try {
      isLoading(true);
      
      // Validate input first
      if (!_validateRegistrationInput()) {
        return;
      }

      print("Starting registration process...");
      
      // Create Firebase Auth user
      var credentials = await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      
      print("Firebase Auth user created: ${credentials.user!.uid}");
      
      // Try to create user document in Firestore
      try {
        await createUser(credentials.user!.uid);
        print("User document created successfully");
      } catch (firestoreError) {
        print("Firestore error, but auth user created: $firestoreError");
        // Show warning but continue with registration
        Get.snackbar(
          "Warning",
          "Account created but profile sync failed. You can update your profile later.",
          backgroundColor: Colors.orange,
          snackPosition: SnackPosition.BOTTOM,
          titleText: Text(
            "Partial Success",
            style: GoogleFonts.poppins(fontSize: 14.sp, color: whiteColor),
          ),
          messageText: Text(
            "Account created but profile sync failed. You can update your profile later.",
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: whiteColor,
            ),
          ),
        );
      }
      
      // Clear form fields
      _clearRegistrationFields();
      
      // Navigate to home
      Get.offAll(() => const HomeScreen());
      
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(e);
    } catch (e) {
      _handleGenericError(e);
    } finally {
      isLoading(false);
    }
  }

  void login() async {
    try {
      isLoading(true);
      
      if (!_validateLoginInput()) {
        return;
      }

      print("Starting login process...");
      
      await auth.signInWithEmailAndPassword(
        email: loginEmailController.text.trim(),
        password: loginPasswordController.text.trim(),
      );
      
      print("Login successful");
      
      // Get user data after successful login
      userController.getUser();
      
      Get.offAll(() => BottomNavigationBarScreen());
      
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(e);
    } catch (e) {
      _handleGenericError(e);
    } finally {
      isLoading(false);
    }
  }

  void logout() async {
    try {
      isLoading(true);
      
      // Sign out from Firebase
      await auth.signOut();
      
      // Clear user data
      user.clear();
      
      // Clear all text controllers
      _clearAllControllers();
      
      // Show success message
      Get.snackbar(
        "Success",
        "Logged out successfully",
        backgroundColor: greenColor,
        snackPosition: SnackPosition.BOTTOM,
        titleText: Text(
          "Success",
          style: GoogleFonts.poppins(fontSize: 14.sp, color: whiteColor),
        ),
        messageText: Text(
          "Logged out successfully",
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: whiteColor,
          ),
        ),
      );
      
      // Navigate to sign in screen
      Get.offAll(() => const SignInScreen());
      
    } catch (e) {
      _showErrorSnackbar("Logout Error", "Failed to logout. Please try again.");
      print("Error during logout: $e");
    } finally {
      isLoading(false);
    }
  }

  void _clearAllControllers() {
    usernameController.clear();
    emailController.clear();
    loginEmailController.clear();
    loginPasswordController.clear();
    phoneController.clear();
    passwordController.clear();
  }

  // Forgot Password functionality
  Future<void> forgotPassword(String email) async {
    try {
      if (email.trim().isEmpty) {
        _showErrorSnackbar("Error", "Please enter your email address");
        return;
      }

      if (!GetUtils.isEmail(email.trim())) {
        _showErrorSnackbar("Error", "Please enter a valid email address");
        return;
      }

      await auth.sendPasswordResetEmail(email: email.trim());
      
      Get.snackbar(
        "Success",
        "Password reset link sent to $email",
        backgroundColor: greenColor,
        snackPosition: SnackPosition.BOTTOM,
        titleText: Text(
          "Success",
          style: GoogleFonts.poppins(fontSize: 14.sp, color: whiteColor),
        ),
        messageText: Text(
          "Password reset link sent to $email",
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: whiteColor,
          ),
        ),
      );
      
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(e);
    } catch (e) {
      _handleGenericError(e);
    }
  }

  // Validation methods
  bool _validateRegistrationInput() {
    if (usernameController.text.trim().isEmpty) {
      _showErrorSnackbar("Validation Error", "Please enter your name");
      return false;
    }
    
    if (emailController.text.trim().isEmpty) {
      _showErrorSnackbar("Validation Error", "Please enter your email");
      return false;
    }
    
    if (!GetUtils.isEmail(emailController.text.trim())) {
      _showErrorSnackbar("Validation Error", "Please enter a valid email");
      return false;
    }
    
    if (phoneController.text.trim().isEmpty) {
      _showErrorSnackbar("Validation Error", "Please enter your phone number");
      return false;
    }
    
    if (passwordController.text.trim().isEmpty) {
      _showErrorSnackbar("Validation Error", "Please enter your password");
      return false;
    }
    
    if (passwordController.text.length < 6) {
      _showErrorSnackbar("Validation Error", "Password must be at least 6 characters");
      return false;
    }
    
    return true;
  }

  bool _validateLoginInput() {
    if (loginEmailController.text.trim().isEmpty) {
      _showErrorSnackbar("Validation Error", "Please enter your email");
      return false;
    }
    
    if (!GetUtils.isEmail(loginEmailController.text.trim())) {
      _showErrorSnackbar("Validation Error", "Please enter a valid email");
      return false;
    }
    
    if (loginPasswordController.text.trim().isEmpty) {
      _showErrorSnackbar("Validation Error", "Please enter your password");
      return false;
    }
    
    return true;
  }

  // Error handling methods
  void _handleFirebaseAuthError(FirebaseAuthException e) {
    String errorMessage;
    switch (e.code) {
      case 'weak-password':
        errorMessage = 'The password provided is too weak.';
        break;
      case 'email-already-in-use':
        errorMessage = 'The account already exists for that email.';
        break;
      case 'user-not-found':
        errorMessage = 'No user found for that email.';
        break;
      case 'wrong-password':
        errorMessage = 'Wrong password provided for that user.';
        break;
      case 'invalid-email':
        errorMessage = 'The email address is invalid.';
        break;
      case 'user-disabled':
        errorMessage = 'This user account has been disabled.';
        break;
      case 'too-many-requests':
        errorMessage = 'Too many requests. Try again later.';
        break;
      default:
        errorMessage = 'Authentication failed: ${e.message}';
    }
    
    _showErrorSnackbar("Authentication Error", errorMessage);
    print("FirebaseAuth Error: ${e.code} - ${e.message}");
  }

  void _handleFirestoreError(FirebaseException e) {
    String errorMessage;
    switch (e.code) {
      case 'permission-denied':
        errorMessage = 'Permission denied. Please check Firestore security rules.';
        break;
      case 'unavailable':
        errorMessage = 'Firestore service is currently unavailable. Please try again.';
        break;
      case 'deadline-exceeded':
        errorMessage = 'Request timeout. Please check your internet connection.';
        break;
      default:
        errorMessage = 'Database error: ${e.message}';
    }
    
    _showErrorSnackbar("Database Error", errorMessage);
    print("Firestore Error: ${e.code} - ${e.message}");
  }

  void _handleGenericError(dynamic e) {
    _showErrorSnackbar("Error", "Something went wrong. Please try again.");
    print("Generic Error: $e");
  }

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

  void _clearRegistrationFields() {
    usernameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
  }

  @override
  void onClose() {
    // Dispose controllers
    usernameController.dispose();
    emailController.dispose();
    loginEmailController.dispose();
    loginPasswordController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}