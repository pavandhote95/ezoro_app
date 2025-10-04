import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import 'package:travel_app2/app/constants/custom_button.dart';
import 'package:travel_app2/app/modules/login/controllers/login_controller.dart';

class OtpVerificationView extends GetView<LoginController> {
  final String phoneNumber;

  const OtpVerificationView({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    // Use controller from GetView<LoginController>
    
    final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());


    return Scaffold(
      backgroundColor: AppColors.mainBg,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Text(
                'OTP Verification',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Enter the 4-digit code sent to $phoneNumber',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white60,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 65,
                    child: TextField(
                      controller: controller.otpControllers[index],
                      focusNode: focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.buttonBg,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 3) {
                          focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Resend OTP Timer or Button
              Obx(
                () => controller.secondsRemaining.value > 0
                    ? Text(
                        'Resend code in 00:${controller.secondsRemaining.value.toString().padLeft(2, '0')}',
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      )
                    : TextButton(
                        onPressed: controller.resendOtp,
                        child: Text(
                          'Resend OTP',
                          style: GoogleFonts.poppins(
                            color: AppColors.buttonBg,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
            
            
              const SizedBox(height: 30),

              // Verify Button
              CustomButton(
                isLoading: controller.isLoading,
                onPressed: () => controller.verifyOtp(phoneNumber),
                text: 'Verify',
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
