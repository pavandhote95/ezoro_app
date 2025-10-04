import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import 'package:travel_app2/app/modules/chat_with_expert/views/expertt_chat_view.dart';

import '../controllers/experts_profile_controller.dart';

class ExpertsProfileView extends StatelessWidget {
  final int expertId;
  final int expertuserId;
  const ExpertsProfileView({
    super.key,
    required this.expertId,
    required this.expertuserId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExpertsProfileController());

    // Load expert detail
    controller.fetchExpertDetail(expertId);

    print("🟢 Opened Expert Profile ID: $expertId");

    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        backgroundColor: AppColors.mainBg,
        title: Text(
          'Expert Profile',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: SizedBox(
              height: 120,
              width: 120,
              child: Lottie.asset(
                'assets/lottie/Loading.json', // ✅ apna asset path yaha do
                repeat: true,
                animate: true,
              ),
            ),
          );
        }

        final expert = controller.expert;
        if (expert.isEmpty) {
          return const Center(
            child: Text("No data found", style: TextStyle(color: Colors.white)),
          );
        }

        final imageUrl =
            expert['image']?.toString() ??
            "https://via.placeholder.com/600x400";

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header image
              Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  alignment: Alignment.bottomLeft,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    expert['expert_name']?.toString() ?? 'Expert',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.3),

              const SizedBox(height: 20),

              // Profile Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expert['title']?.toString() ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.buttonBg,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(
                          Icons.place,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            expert['location']?.toString() ?? '',
                            style: GoogleFonts.poppins(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(
                          Icons.language,
                          color: Colors.white54,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            (expert['language'] as List<dynamic>?)
                                    ?.map((lang) => lang['value'].toString())
                                    .join(', ') ??
                                '',
                            style: GoogleFonts.poppins(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Divider(color: Colors.white24),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Icon(
                          Icons.map,
                          color: AppColors.buttonBg,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            expert['days']?.toString() ?? '0',
                            style: GoogleFonts.openSans(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(
                          Icons.people,
                          color: AppColors.buttonBg,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          expert['guided']?.toString() ?? '',
                          style: GoogleFonts.poppins(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Divider(color: Colors.white24),
                    const SizedBox(height: 12),

                    Text(
                      'About the Expert',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      expert['about']?.toString() ?? '',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.3),
              ),

              const SizedBox(height: 100),
            ],
          ),
        );
      }),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Obx(() {
            if (controller.expert.isEmpty) {
              return const SizedBox();
            }

            final expertPrice = controller.expert['price']?.toString() ?? "0";

            return ElevatedButton.icon(
              onPressed: () {
                final expertPrice =
                    controller.expert['price']?.toString() ?? "0";

                Get.to(
                  () => ChatWithExpertView(
                    expertId: expertuserId,
                    expertName:
                        controller.expert['expert_name']?.toString() ??
                        'Expert',
                    expertImage: controller.expert['image']?.toString() ?? '',
                    expertPrice: expertPrice, // ✅ yaha direct pass hoga
                  ),
                );
              },
              icon: const Icon(Icons.chat),
              label: Text(
                'Chat with Expert (₹$expertPrice)',
                style: GoogleFonts.openSans(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonBg,
                foregroundColor: AppColors.appbar,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
