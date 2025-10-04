import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:travel_app2/app/routes/app_pages.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  final box = GetStorage();

  final List<Map<String, String>> pages = [
    {
      'title': 'Explore the World',
      'subtitle': 'Find amazing places and hidden gems from fellow travelers.',
    },
    {
      'title': 'Join the Community',
      'subtitle': 'Connect with people who share your passion for travel.',
    },
    {
      'title': 'Talk to Experts',
      'subtitle': 'Get guidance and tips from travel pros and locals.',
    },
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      // Optional: box.write('isFirstTime', false); already handled in splash
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
