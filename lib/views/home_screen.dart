import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/instance_manager.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantcare/constant/assets.dart';
import 'package:plantcare/constant/colors.dart';
import 'package:plantcare/modelView/news_controllers.dart';
import 'package:plantcare/views/news_screen.dart';
import 'package:plantcare/views/weather_screen.dart';
import 'package:plantcare/views/scan_screen.dart';
import 'package:plantcare/modelView/weather_controller.dart';
import 'package:plantcare/modelView/user_controller.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    final WeatherController weatherController = Get.put(WeatherController());
    final NewsController newsController = Get.put(NewsController());
    final UserController userController = Get.put(UserController());
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12.h),
Obx(() => RichText(
  text: TextSpan(
    text: 'Welcome ',
    style: GoogleFonts.poppins(
      fontSize: 24.sp,
      fontWeight: FontWeight.w600,
      color: blackColor,
    ),
    children: [
      TextSpan(
        text: userController.isLoading.value
            ? 'Loading...'
            : (userController.user['name']?.toString() ?? 'User') + '!',
        style: GoogleFonts.poppins(
          fontSize: 28.sp,
          fontWeight: FontWeight.bold,
          color: greenColor,
        ),
      ),
    ],
  ),
))
,
                SizedBox(height: 22.h),
                SizedBox(
                  width: double.infinity,
                  height: 180.h,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: Image.asset(Assets.plantImg, fit: BoxFit.cover),
                  ),
                ),

                SizedBox(height: 22.h),
                GestureDetector(
                  onTap: () {
                    Get.to(() => ScanScreen());
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: greenColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(Assets.scaningIcon),
                        SizedBox(width: 12.w),
                        Text(
                          'Diagnose Your Plant',
                          style: GoogleFonts.poppins(
                            fontSize: 19.sp,
                            color: whiteColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 22.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Weather Forecasts',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        color: blackColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => WeatherScreen());
                      },
                      child: Text(
                        'See All',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          color: greyColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 22.h),
                
                // Weather Widget with real data
                Obx(() => GestureDetector(
                  onTap: () {
                    Get.to(() => WeatherScreen());
                  },
                  child: Container(
                    padding: EdgeInsets.all(30.r),
                    width: double.infinity,
                    height: 196,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(Assets.bgimg),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: weatherController.isLoading.value
                        ? Center(
                            child: CircularProgressIndicator(
                              color: whiteColor,
                              strokeWidth: 2,
                            ),
                          )
                        : weatherController.hasError.value
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: whiteColor.withOpacity(0.8),
                                      size: 32.sp,
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'Weather unavailable',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        color: whiteColor.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          weatherController.cityName.value.toUpperCase(),
                                          style: GoogleFonts.poppins(
                                            fontSize: 24.sp,
                                            fontWeight: FontWeight.w500,
                                            color: whiteColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 12.h),
                                        Text(
                                          _getCurrentTimeAndDate(),
                                          style: GoogleFonts.poppins(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: whiteColor.withOpacity(0.68),
                                          ),
                                        ),
                                        SizedBox(height: 12.h),
                                        Text(
                                          weatherController.currentTemp.value,
                                          style: GoogleFonts.poppins(
                                            fontSize: 64.sp,
                                            fontWeight: FontWeight.w500,
                                            color: whiteColor.withOpacity(0.68),
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          weatherController.weatherCondition.value,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w400,
                                            color: whiteColor.withOpacity(0.6),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Column(
                                    children: [
                                      // You can replace this with the weather icon or keep the cloud image
                                      weatherController.weatherIcon.value.isNotEmpty
                                          ? Image.network(
                                              'https:${weatherController.weatherIcon.value}',
                                              width: 80.w,
                                              height: 80.h,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Image.asset(
                                                  Assets.cloudImg,
                                                  width: 80.w,
                                                  height: 80.h,
                                                );
                                              },
                                            )
                                          : Image.asset(
                                              Assets.cloudImg,
                                              width: 80.w,
                                              height: 80.h,
                                            ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        'H:${weatherController.highTemp.value} L:${weatherController.lowTemp.value}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                          color: whiteColor.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                  ),
                )),
                
                SizedBox(height: 22.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Trending News',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        color: blackColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => NewsScreen());
                      },
                      child: Text(
                        'See All',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          color: greyColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 22.h),
                
                // Featured News Article with real data
                Obx(() {
                  if (newsController.isLoading.value) {
                    return Container(
                      height: 280.h,
                      child: Center(
                        child: CircularProgressIndicator(color: greenColor),
                      ),
                    );
                  }
                  
                  if (newsController.hasError.value || newsController.newsList.isEmpty) {
                    return Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 180.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.article_outlined,
                                  size: 40.sp,
                                  color: greyColor,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'News unavailable',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    color: greyColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 22.h),
                        Text(
                          'Unable to load latest news',
                          style: GoogleFonts.roboto(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: blackColor,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Plant Care News',
                              style: GoogleFonts.poppins(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w500,
                                color: greyColor,
                              ),
                            ),
                            Text(
                              'Today',
                              style: GoogleFonts.poppins(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w500,
                                color: greyColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }

                  // Get the first (most recent) news article
                  final featuredArticle = newsController.newsList.first;
                  
                  return GestureDetector(
                    onTap: () async {
                      // Open article URL in browser or navigate to full news screen
                      if (featuredArticle.url.isNotEmpty && await canLaunch(featuredArticle.url)) {
                        await launch(featuredArticle.url);
                      } else {
                        Get.to(() => NewsScreen());
                      }
                    },
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 180.h,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.r),
                            child: featuredArticle.imageUrl.isNotEmpty
                                ? Image.network(
                                    featuredArticle.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 40.sp,
                                            color: greyColor,
                                          ),
                                        ),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: greenColor,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: Icon(
                                        Icons.article_outlined,
                                        size: 40.sp,
                                        color: greyColor,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 22.h),
                        Text(
                          featuredArticle.title,
                          style: GoogleFonts.roboto(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: blackColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                featuredArticle.source,
                                style: GoogleFonts.poppins(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w500,
                                  color: greyColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              newsController.formatDate(featuredArticle.publishedAt),
                              style: GoogleFonts.poppins(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w500,
                                color: greyColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getCurrentTimeAndDate() {
    final now = DateTime.now();
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd/MM');
    
    return '${timeFormat.format(now)} • ${dateFormat.format(now)}';
  }
}