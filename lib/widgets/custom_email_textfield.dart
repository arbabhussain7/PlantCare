import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantcare/constant/colors.dart';

class CustomEmailTextField extends StatelessWidget {
  const CustomEmailTextField({
    super.key, 
    required this.text,
    this.controller,
    this.keyboardType,
    this.validator,
  });
  
  final String text;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: aWhiteColor,
        borderRadius: BorderRadius.circular(17.r),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType ?? TextInputType.text,
        validator: validator,
        style: GoogleFonts.poppins(
          fontSize: 16.sp,
          color: blackColor,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: text,
          hintStyle: GoogleFonts.poppins(
            fontSize: 16.sp,
            color: greyColor,
            fontWeight: FontWeight.w600,
          ),
          contentPadding: EdgeInsets.only(left: 12.w),
          border: InputBorder.none,
        ),  
      ),
    );
  }
}