import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantcare/constant/assets.dart';
import 'package:plantcare/constant/colors.dart';
import 'package:plantcare/modelView/model_controller.dart';

class ModelResults extends StatelessWidget {
  const ModelResults({super.key});

  @override
  Widget build(BuildContext context) {
    final ModelController modelController = Get.find<ModelController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: blackColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Mango Disease Results',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: blackColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: greenColor),
            onPressed: () {
              modelController.clearResults();
              Get.back();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (modelController.predictionResult.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.sp,
                  color: greyColor,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No results available',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    color: greyColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Please scan a mango leaf image first',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: greyColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        final result = modelController.predictionResult.value!;
        final confidence = result['confidence'] as double;
        final label = result['label'] as String;
        final diseaseInfo = result['diseaseInfo'] as Map<String, String>?;
        
        // Get additional information
        final symptoms = modelController.getSymptoms(label);
        final prevention = modelController.getPreventionTips(label);

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              
              // Uploaded Image
              if (modelController.selectedImage.value != null)
                Container(
                  width: double.infinity,
                  height: 250.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: Image.file(
                      modelController.selectedImage.value!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              
              SizedBox(height: 30.h),
              
              // Disease Name and Confidence
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: label == 'Healthy' ? Colors.green[600] : greenColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: confidence > 80 ? Colors.green[100] : 
                             confidence > 60 ? Colors.orange[100] : Colors.red[100],
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '${confidence.toStringAsFixed(1)}%',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: confidence > 80 ? Colors.green[700] : 
                               confidence > 60 ? Colors.orange[700] : Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 8.h),
              
              // Confidence Level Indicator
              Container(
                width: double.infinity,
                height: 8.h,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: confidence / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: confidence > 80 ? Colors.green : 
                             confidence > 60 ? Colors.orange : Colors.red,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 30.h),
              
              // Description Section
              Text(
                'Description',
                style: GoogleFonts.poppins(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: blackColor,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  diseaseInfo?['description'] ?? modelController.getDiseaseInfo(label),
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: blackColor,
                    height: 1.6,
                  ),
                ),
              ),
              
              SizedBox(height: 30.h),
              
              // Symptoms Section
              Text(
                'Symptoms',
                style: GoogleFonts.poppins(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  color: blackColor,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: Colors.orange[600],
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        symptoms,
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: blackColor,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 30.h),
              
              // Prevention Section
              Text(
                'Prevention Tips',
                style: GoogleFonts.poppins(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: blackColor,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.shield,
                      color: Colors.blue[600],
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        prevention,
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: blackColor,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 30.h),
              
              // Additional Tips
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.purple[600],
                          size: 24.sp,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Tips for Better Results',
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.purple[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildTip('Take photos in good lighting conditions'),
                    _buildTip('Focus on the affected area of the mango leaves'),
                    _buildTip('Ensure the image is clear and not blurry'),
                    _buildTip('Include both healthy and diseased parts if possible'),
                    _buildTip('Take photos from multiple angles for better accuracy'),
                  ],
                ),
              ),
              
              SizedBox(height: 40.h),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        modelController.clearResults();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Scan Another',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: blackColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // You can add sharing functionality here
                        Get.snackbar(
                          'Share',
                          'Sharing functionality can be implemented here',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: greenColor,
                          colorText: whiteColor,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: greenColor,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Share Results',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: whiteColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 20.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6.h),
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: Colors.purple[400],
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.purple[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
