import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import '../controllers/splash_controller.dart';


class SplashView extends GetView<SplashController> {
  const SplashView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      body: AnimatedBuilder(
        animation: controller.animationController,
        builder: (context, child) {
          return Center(
            child: Opacity(
              opacity: controller.fadeAnimation.value,
              child: Transform.scale(
                scale: controller.scaleAnimation.value,
                child: Text(
                  'Traveller',
                  style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.8,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 20,
                        color: AppColors.buttonBg.withOpacity(0.5),
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
