import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import 'package:travel_app2/app/constants/custom_button.dart';
import 'package:travel_app2/app/modules/login/controllers/login_controller.dart';
import 'package:travel_app2/app/modules/phone_login/controllers/phone_login_controller.dart';


class PhoneLoginView extends GetView<PhoneAuthController> {
  PhoneLoginView({super.key});
  final controller = Get.put(PhoneAuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'Login with Phone',
                    style: GoogleFonts.roboto(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Phone Number Field
                  TextField(
                    controller: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      hintText: 'Enter your phone number',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.phone, color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Send OTP Button
                  CustomButton(
                    isLoading: controller.isLoading,
                    onPressed: controller.sendOtp,
                    text: 'Send OTP',
                    textColor: Colors.white,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
