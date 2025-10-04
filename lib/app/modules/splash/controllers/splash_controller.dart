import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:travel_app2/app/routes/app_pages.dart';
import 'package:flutter/material.dart';

class SplashController extends GetxController with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;

  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();

    // Animation setup
    animationController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    scaleAnimation = Tween<double>(begin: 2.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOutBack),
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );

    animationController.forward();

    // Navigate after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      _navigateUser();
    });
  }

  void _navigateUser() {
    // Check if first time opening app
    final isFirstTime = box.read('isFirstTime') ?? true;
    final isLoggedIn = box.read('isLoggedIn') ?? false;

    if (isFirstTime) {
      box.write('isFirstTime', false); // Mark that onboarding has been shown
      Get.offAllNamed(Routes.ONBOARDING);
    } else if (isLoggedIn) {
         Get.offAllNamed(Routes.DASHBOARD);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}

