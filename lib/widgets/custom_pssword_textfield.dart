import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantcare/constant/colors.dart';

class CustomPasswordTextField extends StatefulWidget {
  const CustomPasswordTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.onChanged,
    this.validator,
    this.initialObscureText = true,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool initialObscureText;

  @override
  State<CustomPasswordTextField> createState() => _CustomPasswordTextFieldState();
}

class _CustomPasswordTextFieldState extends State<CustomPasswordTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.initialObscureText;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: aWhiteColor,
        borderRadius: BorderRadius.circular(17.r),
      ),
      child: TextFormField(
        style: GoogleFonts.poppins(
          fontSize: 16.sp,
          color: blackColor,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: widget.label,
          hintStyle: GoogleFonts.poppins(
            fontSize: 16.sp,
            color: greyColor,
            fontWeight: FontWeight.w600,
          ),
          contentPadding: EdgeInsets.only(left: 12.w, top: 12.h),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: greyColor,
            ),
            onPressed: _togglePasswordVisibility,
          ),
        ),
        controller: widget.controller,
        obscureText: _obscureText,
        onChanged: widget.onChanged,
        validator: widget.validator,
      ),
    );
  }
}