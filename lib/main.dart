import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:plantcare/constant/colors.dart';
import 'package:plantcare/firebase_options.dart';
import 'package:plantcare/modelView/auth_controller.dart';
import 'package:plantcare/modelView/user_controller.dart';
import 'package:plantcare/views/splash_screen.dart';

/// Registers auth/profile controllers once so they are not disposed during
/// [Get.offAll] navigation (avoids TextEditingControllers used after dispose).
void _ensureCoreControllers() {
  if (!Get.isRegistered<UserController>()) {
    Get.put(UserController(), permanent: true);
  }
  if (!Get.isRegistered<AuthController>()) {
    Get.put(AuthController(), permanent: true);
  }
}

/// Initializes Firebase. Handles hot-restart cases where the Pigeon channel to
/// native code is not ready on the first frame ([PlatformException] code `channel-error`).
Future<void> _initializeFirebase() async {
  if (Firebase.apps.isNotEmpty) {
    return;
  }
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } on PlatformException catch (e) {
    if (e.code == 'channel-error') {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
    } else {
      rethrow;
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();
   await dotenv.load(fileName: '.env');

  // Configure Firestore settings
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  _ensureCoreControllers();

  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return ScreenUtilInit(
      designSize: const Size(521    , 926),
      minTextAdapt: true,
      splitScreenMode: true,
      
      builder: (_ , child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'PlantCare',
          
          theme: ThemeData(scaffoldBackgroundColor: whiteColor,
            primarySwatch: Colors.blue,
            textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
          ),
          home: SplashScreen(),
        );
      },
    );
  }
}