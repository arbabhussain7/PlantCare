import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantcare/constant/assets.dart';
import 'package:plantcare/constant/colors.dart';
import 'package:get/get.dart';
import 'package:plantcare/modelView/weather_controller.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WeatherController controller = Get.put(WeatherController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.bgimg),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            // Show loading indicator
            if (controller.isLoading.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: whiteColor,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Loading weather data...',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        color: whiteColor,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Show error state
            if (controller.hasError.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.sp,
                      color: whiteColor,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Failed to load weather data',
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        color: whiteColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: whiteColor.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () => controller.refreshWeather(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: whiteColor.withOpacity(0.2),
                        padding: EdgeInsets.symmetric(
                          horizontal: 32.w,
                          vertical: 12.h,
                        ),
                      ),
                      child: Text(
                        'Retry',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          color: whiteColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Main weather content
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Column(
                children: [
                  // Header with back button and refresh
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: whiteColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: SvgPicture.asset(Assets.backIcon),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => controller.refreshWeather(),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: whiteColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.refresh,
                            color: whiteColor,
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 44.h),
                  
                  // City Name
                  Text(
                    controller.cityName.value,
                    style: GoogleFonts.poppins(
                      fontSize: 34.sp,
                      fontWeight: FontWeight.w400,
                      color: whiteColor,
                    ),
                  ),

                  SizedBox(height: 12.h),
                  
                  // Current Temperature
                  Text(
                    controller.currentTemp.value,
                    style: GoogleFonts.poppins(
                      fontSize: 123.sp,
                      fontWeight: FontWeight.w200,
                      color: whiteColor,
                    ),
                  ),
                  
                  SizedBox(height: 22.h),
                  
                  // Weather Condition and High/Low
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: controller.weatherCondition.value,
                      style: GoogleFonts.poppins(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w400,
                        color: whiteColor,
                      ),
                      children: [
                        TextSpan(
                          text: '\nH:${controller.highTemp.value}   L:${controller.lowTemp.value}',
                          style: GoogleFonts.poppins(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            color: whiteColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Additional weather info
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildWeatherStat('Humidity', '${controller.humidity.value}%'),
                      _buildWeatherStat('Wind', controller.windSpeed.value),
                      _buildWeatherStat('UV Index', controller.uvIndex.value.toString()),
                    ],
                  ),
                  
                  Spacer(),
                  
                  // Bottom Container with Calendar and Forecast
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    width: double.infinity,
                    height: 450.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(33.r),
                        topRight: Radius.circular(33.r),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff4F7569).withOpacity(0.6),
                          Color(0xff4F7569).withOpacity(0.6),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 12.h),
                        
                        // Forecast Toggle Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => controller.setHourlyForecast(),
                              child: Text(
                                'Hourly Forecast',
                                style: GoogleFonts.poppins(
                                  fontSize: 18.sp,
                                  color: controller.showHourlyForecast.value 
                                      ? cWhiteColor 
                                      : cWhiteColor.withOpacity(0.6),
                                  fontWeight: controller.showHourlyForecast.value 
                                      ? FontWeight.w600 
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => controller.setWeeklyForecast(),
                              child: Text(
                                'Weekly Forecast',
                                style: GoogleFonts.poppins(
                                  fontSize: 18.sp,
                                  color: !controller.showHourlyForecast.value 
                                      ? cWhiteColor 
                                      : cWhiteColor.withOpacity(0.6),
                                  fontWeight: !controller.showHourlyForecast.value 
                                      ? FontWeight.w600 
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),

                        Divider(color: Color(0xff4F7569)),
                        
                        SizedBox(height: 16.h),
                        
                        // Calendar Widget (only show for hourly forecast)
                        if (controller.showHourlyForecast.value) ...[
                          EasyDateTimeLine(
                            initialDate: controller.selectedDate.value,
                            onDateChange: (selectedDate) {
                              controller.updateSelectedDate(selectedDate);
                            },
                            headerProps: EasyHeaderProps(
                              monthPickerType: MonthPickerType.switcher,
                              dateFormatter: DateFormatter.fullDateDMY(),
                              showHeader: true,
                              monthStyle: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: aWhiteColor,
                              ),
                            ),
                            dayProps: EasyDayProps(
                              height: 60.h,
                              width: 50.w,
                              dayStructure: DayStructure.dayStrDayNum,
                              inactiveDayStyle: DayStyle(
                                borderRadius: 12.r,
                                dayNumStyle: GoogleFonts.poppins(
                                  fontSize: 28.sp,
                                  color: whiteColor.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                                dayStrStyle: GoogleFonts.poppins(
                                  fontSize: 10.sp,
                                  color: whiteColor.withOpacity(0.5),
                                  fontWeight: FontWeight.w400,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              activeDayStyle: DayStyle(
                                borderRadius: 12.r,
                                dayNumStyle: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: whiteColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                dayStrStyle: GoogleFonts.poppins(
                                  fontSize: 10.sp,
                                  color: Color(0xff2D4A3F),
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: BoxDecoration(
                                  color: cWhiteColor,
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              todayStyle: DayStyle(
                                borderRadius: 12.r,
                                dayNumStyle: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: cWhiteColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                dayStrStyle: GoogleFonts.poppins(
                                  fontSize: 10.sp,
                                  color: cWhiteColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xff4F7569).withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: cWhiteColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                            locale: 'en_US',
                          ),
                          SizedBox(height: 20.h),
                        ],
                        
                        // Weather Content based on selected view
                        Expanded(
                          child: controller.showHourlyForecast.value
                              ? _buildHourlyForecast(controller)
                              : _buildWeeklyForecast(controller),
                        ),
                      ],
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

  // Weather stat widget
  Widget _buildWeatherStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: whiteColor,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: whiteColor.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  // Hourly Forecast Widget
  Widget _buildHourlyForecast(WeatherController controller) {
    final hourlyWeather = controller.getHourlyWeather();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weather for ${controller.selectedDate.value.day}/${controller.selectedDate.value.month}',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            color: cWhiteColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 16.h),
        if (hourlyWeather.isEmpty)
          Center(
            child: Text(
              'No hourly data available',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                color: cWhiteColor.withOpacity(0.7),
              ),
            ),
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: hourlyWeather.map((weather) => 
              _buildWeatherInfo(
                weather['time']!,
                weather['temp']!,
                weather['icon']!,
              )
            ).toList(),
          ),
      ],
    );
  }

  // Weekly Forecast Widget
  Widget _buildWeeklyForecast(WeatherController controller) {
    final weeklyWeather = controller.getWeeklyWeather();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '7-Day Forecast',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            color: cWhiteColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 16.h),
        if (weeklyWeather.isEmpty)
          Center(
            child: Text(
              'No weekly data available',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                color: cWhiteColor.withOpacity(0.7),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: weeklyWeather.length,
              itemBuilder: (context, index) {
                final weather = weeklyWeather[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          weather['day']!,
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            color: cWhiteColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          weather['icon']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24.sp),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          weather['temp']!,
                          textAlign: TextAlign.end,
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            color: cWhiteColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // Weather Info Widget for hourly forecast
  Widget _buildWeatherInfo(String time, String temp, String icon) {
    return Column(
      children: [
        Text(
          time,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            color: whiteColor.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          icon,
          style: TextStyle(fontSize: 32.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          temp,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            color: whiteColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}