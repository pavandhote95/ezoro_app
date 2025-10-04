import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import 'package:travel_app2/app/constants/custom_button.dart';
import 'package:travel_app2/app/routes/app_pages.dart';
import '../controllers/register_controller.dart';

class RegisterView extends StatelessWidget {
  RegisterView({super.key});

  final RegisterController controller = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: AppColors.mainBg,
      body: Center(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  Text(
                    'Traveler',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Create your account',
                    style: GoogleFonts.poppins(
                      color: Colors.white60,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Full Name
                  TextField(
                    controller: controller.nameController,
                    keyboardType: TextInputType.name,
                    style: const TextStyle(color: Colors.white),
                    decoration: inputDecoration(Icons.person, 'Full Name'),
                  ),
                  const SizedBox(height: 20),
                  // Email or Phone
                  TextField(
                    controller: controller.emailOrPhoneController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: inputDecoration(Icons.alternate_email, 'Email or Phone'),
                  ),
                  const SizedBox(height: 20),
                  // Password
                  TextField(
                    controller: controller.passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: inputDecoration(Icons.lock, 'Password'),
                  ),
                  const SizedBox(height: 30),
                  // Register Button
      const SizedBox(height: 30),
      CustomButton(
        isLoading: controller.isLoading,
        onPressed: controller.register,
        text: 'Register',
      ),
                 
                  const SizedBox(height: 20),
                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Colors.white24)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "OR",
                          style: GoogleFonts.poppins(color: Colors.white54),
                        ),
                      ),
                      const Expanded(child: Divider(color: Colors.white24)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Google Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      icon: Image.asset('assets/icons/google.png', height: 24),
                      onPressed: () {
                        Fluttertoast.showToast(
                          msg: 'Google Login Coming soon!',
                          backgroundColor: Colors.blueGrey,
                          textColor: Colors.white,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        foregroundColor: Colors.white,
                      ),
                      label: Text(
                        'Login with Google',
                        style: GoogleFonts.poppins(fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Apple Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      icon: Image.asset('assets/icons/apple.png', height: 24),
                      onPressed: () {
                        Fluttertoast.showToast(
                          msg: 'Apple Login Coming soon!',
                          backgroundColor: Colors.blueGrey,
                          textColor: Colors.white,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        foregroundColor: Colors.white,
                      ),
                      label: Text(
                        'Login with Apple',
                        style: GoogleFonts.poppins(fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Already have an account?
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.LOGIN);
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account ?  ",
                        style: GoogleFonts.poppins(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: GoogleFonts.poppins(
                              color: AppColors.buttonBg,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Terms
                  Text(
                    'By registering, you agree to our Terms & Privacy Policy',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(IconData icon, String hint) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      prefixIcon: Icon(icon, color: Colors.white54),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide.none,
      ),
    );
  }
}