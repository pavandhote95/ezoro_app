import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_color.dart';

class CustomButton extends StatelessWidget {
  final RxBool isLoading;
  final VoidCallback onPressed;
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const CustomButton({
    Key? key,
    required this.isLoading,
    required this.onPressed,
    required this.text,
    this.backgroundColor = AppColors.buttonBg, // Default TealAccent
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: isLoading.value ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            disabledBackgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: isLoading.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
        ),
      ),
    );
  }
}
