import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:plantcare/constant/colors.dart';
import 'package:plantcare/views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  

  
  // Configure Firestore settings
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
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