import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantcare/constant/colors.dart';

class CustomProfileTextField extends StatelessWidget {
  final String text;
  final bool isReadOnly;
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const CustomProfileTextField({
    super.key,
    required this.text,
    this.isReadOnly = false,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 14.h,
      ),
      decoration: BoxDecoration(
        color: isReadOnly ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isReadOnly ? Colors.grey[300]! : greyColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (prefixIcon != null) ...[
            prefixIcon!,
            SizedBox(width: 12.w),
          ],
          Expanded(
            child: isReadOnly
                ? Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: blackColor,
                    ),
                  )
                : TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    onChanged: onChanged,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: blackColor,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: hintText ?? text,
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: greyColor,
                      ),
                    ),
                  ),
          ),
          if (suffixIcon != null) ...[
            SizedBox(width: 12.w),
            suffixIcon!,
          ],
        ],
      ),
    );
  }
} 