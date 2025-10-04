import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app2/app/constants/custom_button.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends StatelessWidget {
  ForgotPasswordView({super.key});

  final controller = Get.put(ForgotPasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: AnimatedContainer(
        duration: const Duration(seconds: 3),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1B1B1B),
              Color(0xFF232526),
              Color(0xFF0F2027),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Forgot Password?',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter your email or phone number to receive an OTP',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 40),
        
                // Input field
      TextFormField(
  controller: controller.emailOrPhoneController,
  keyboardType: TextInputType.text,
  style: const TextStyle(color: Colors.white),
  decoration: InputDecoration(
    hintText: "Email or Phone",
    hintStyle: const TextStyle(color: Colors.white60),
    filled: true,
    fillColor: const Color(0xFF1E1E1E),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    prefixIcon: const Icon(
      Icons.alternate_email, // This shows the @ symbol
      color: Colors.white60,
    ),
  ),
),

                const SizedBox(height: 30),
        
   CustomButton(
  text: 'reset password',
  isLoading:controller.isLoading,
  onPressed:  controller.sendOtp,

)

              ],
            ),
          ),
        ),
      ),
    );
  }
}
