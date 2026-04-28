import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plantcare/constant/assets.dart';
import 'package:plantcare/constant/colors.dart';
import 'package:plantcare/controllers/offline_model_controller.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OfflineModelController mangoController = Get.put(OfflineModelController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: blackColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Plant Disease Scanner',
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
            onPressed: mangoController.clear,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              
              // Model Status Indicator
              Obx(() {
                final status = mangoController.isLoading.value
                    ? 'Analyzing'
                    : mangoController.hasResult
                        ? 'Completed'
                        : 'Ready';
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: _getStatusBorderColor(status)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(status),
                        color: _getStatusIconColor(status),
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Model: $status',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: _getStatusTextColor(status),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              
              SizedBox(height: 20.h),
              
              // Header Section
              Text(
                'Plant Disease Scanner',
                style: GoogleFonts.poppins(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: blackColor,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Take a photo or upload an image to detect plant diseases',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: greyColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 30.h),
              
              // Image Preview Section
              Obx(() {
                if (mangoController.selectedImage.value != null) {
                  return Container(
                    width: double.infinity,
                    height: 300.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: greenColor, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18.r),
                      child: Image.file(
                        mangoController.selectedImage.value!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }
                return Container(
                  width: double.infinity,
                  height: 300.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        Assets.scaningIcon,
                        width: 80.w,
                        height: 80.h,
                        colorFilter: ColorFilter.mode(greyColor, BlendMode.srcIn),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'No Image Selected',
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          color: greyColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Choose an image to start diagnosis',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: greyColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              
              SizedBox(height: 30.h),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => mangoController.pickAndClassify(ImageSource.camera),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        decoration: BoxDecoration(
                          color: greenColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, color: whiteColor, size: 24.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'Camera',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: whiteColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => mangoController.pickAndClassify(ImageSource.gallery),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: greenColor, width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo_library, color: greenColor, size: 24.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'Gallery',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
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
              
              SizedBox(height: 4.h),
              
              // Loading State
              Obx(() {
                if (mangoController.isLoading.value) {
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(greenColor),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Analyzing image...',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                color: greenColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'This may take 5-6 seconds',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: greyColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                if (mangoController.errorMessage.value.isNotEmpty) {
                  return Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red, size: 20.sp),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'Image Analysis Failed',
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          mangoController.errorMessage.value,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.red[700],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        
                        // Helpful guidance for mango leaf images
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.lightbulb_outline, color: Colors.blue[600], size: 18.sp),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Tips for Mango Leaf Images:',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              _buildImageTip('Upload clear images of mango leaves only'),
                              _buildImageTip('Ensure good lighting and focus'),
                              _buildImageTip('Avoid blurry or unclear images'),
                              _buildImageTip('Focus on the leaf surface and edges'),
                              _buildImageTip('Take photos from multiple angles if needed'),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 16.h),
                        
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: mangoController.clear,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange[600],
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                child: Text(
                                  'Try Different Image',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => mangoController.pickAndClassify(ImageSource.gallery),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[600],
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                child: Text(
                                  'Retry Analysis',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                
                return SizedBox.shrink();
              }),
              
              SizedBox(height: 44.h),
              
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status.contains('Ready') || status.contains('completed')) {
      return Colors.green[50]!;
    } else if (status.contains('Loading') || status.contains('Processing') || status.contains('Analyzing')) {
      return Colors.blue[50]!;
    } else if (status.contains('failed') || status.contains('error')) {
      return Colors.red[50]!;
    } else {
      return Colors.grey[50]!;
    }
  }

  Color _getStatusBorderColor(String status) {
    if (status.contains('Ready') || status.contains('completed')) {
      return Colors.green[200]!;
    } else if (status.contains('Loading') || status.contains('Processing') || status.contains('Analyzing')) {
      return Colors.blue[200]!;
    } else if (status.contains('failed') || status.contains('error')) {
      return Colors.red[200]!;
    } else {
      return Colors.grey[200]!;
    }
  }

  Color _getStatusTextColor(String status) {
    if (status.contains('Ready') || status.contains('completed')) {
      return Colors.green[700]!;
    } else if (status.contains('Loading') || status.contains('Processing') || status.contains('Analyzing')) {
      return Colors.blue[700]!;
    } else if (status.contains('failed') || status.contains('error')) {
      return Colors.red[700]!;
    } else {
      return Colors.grey[700]!;
    }
  }

  Color _getStatusIconColor(String status) {
    if (status.contains('Ready') || status.contains('completed')) {
      return Colors.green[600]!;
    } else if (status.contains('Loading') || status.contains('Processing') || status.contains('Analyzing')) {
      return Colors.blue[600]!;
    } else if (status.contains('failed') || status.contains('error')) {
      return Colors.red[600]!;
    } else {
      return Colors.grey[600]!;
    }
  }

  IconData _getStatusIcon(String status) {
    if (status.contains('Ready') || status.contains('completed')) {
      return Icons.check_circle;
    } else if (status.contains('Loading') || status.contains('Processing') || status.contains('Analyzing')) {
      return Icons.hourglass_empty;
    } else if (status.contains('failed') || status.contains('error')) {
      return Icons.error;
    } else {
      return Icons.info;
    }
  }

  Widget _buildImageTip(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 24.w),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13.sp,
          color: greyColor.withOpacity(0.9),
        ),
      ),
    );
  }
}
