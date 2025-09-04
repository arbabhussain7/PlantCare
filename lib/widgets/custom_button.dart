
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantcare/constant/colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key, required this.text,
  });
final String text;
  @override
  Widget build(BuildContext context) {
    return Container(padding: EdgeInsets.symmetric(horizontal: 150.w,vertical: 12.h),
      decoration: BoxDecoration(
        color: greenColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 16.sp,
          color: whiteColor,
        ),
      ),
    );
  }
}
