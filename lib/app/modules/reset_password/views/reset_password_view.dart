import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app2/app/constants/custom_button.dart';
import '../controllers/reset_password_controller.dart';

class ResetPasswordView extends StatelessWidget {
  ResetPasswordView({super.key});

  final controller = Get.put(ResetPasswordController());

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
                  'Reset Password',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter your email and new password to reset',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 40),

                // Email Input
                TextFormField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Email",
                    hintStyle: const TextStyle(color: Colors.white60),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Colors.white60,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password Input
                TextFormField(
                  controller: controller.passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "New Password",
                    hintStyle: const TextStyle(color: Colors.white60),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Colors.white60,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Reset Button
                CustomButton(
                  text: 'Reset Password',
                  isLoading: controller.isLoading,
                  onPressed: controller.resetPassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
