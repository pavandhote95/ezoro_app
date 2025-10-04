import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import '../../../constants/custom_button.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:AppColors.mainBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: controller.pages.length,
                onPageChanged: controller.onPageChanged,
                itemBuilder: (context, index) {
                  final page = controller.pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          index == 0
                              ? Icons.public
                              : index == 1
                              ? Icons.people_alt
                              : Icons.support_agent,
                          color: AppColors.buttonBg,
                          size: 120,
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page['title']!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          page['subtitle']!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
      
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                controller.pages.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  height: 8,
                  width: controller.currentPage.value == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: controller.currentPage.value == index
                        ? AppColors.buttonBg
                        : Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            )),
      
            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: CustomButton(
                isLoading: false.obs, // Agar loading control chahiye to controller se connect karo
                onPressed: controller.nextPage,
                text: controller.currentPage.value == controller.pages.length - 1
                    ? 'Get Started'
                    : 'Continue',
                backgroundColor: AppColors.buttonBg,
                textColor: Colors.black,
              ),
            ),


            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
