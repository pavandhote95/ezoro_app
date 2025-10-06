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
    controller.fetchExpertDetail(expertId);

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
              child: Lottie.asset('assets/lottie/Loading.json'),
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
            expert['image']?.toString() ?? "https://via.placeholder.com/600x400";
        final double averageRating =
            double.tryParse(expert['average_rating']?.toString() ?? "0") ?? 0.0;

        return RefreshIndicator(
          color: Colors.redAccent,
          onRefresh: () async {
            await controller.fetchExpertDetail(expertId);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Image
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
                      // Title
                      Text(
                        expert['title']?.toString() ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.buttonBg,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Average Rating
                      Row(
                        children: [
                          Wrap(
                            spacing: 2,
                            children: List.generate(5, (index) {
                              return Icon(
                                index < averageRating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 18,
                              );
                            }),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "(${averageRating.toStringAsFixed(1)})",
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Location
                      Row(
                        children: [
                          const Icon(Icons.place,
                              color: Colors.redAccent, size: 18),
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

                      // Languages
                      Row(
                        children: [
                          const Icon(Icons.language,
                              color: Colors.white54, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              controller.getLanguages(),
                              style: GoogleFonts.poppins(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Divider(color: Colors.white24),
                      const SizedBox(height: 12),

                      // Days & Guided
                     Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
              const Icon(Icons.map,
                              color: AppColors.buttonBg, size: 18),
                          const SizedBox(width: 6),
    Text(
      "Itinerary: ",
      style: GoogleFonts.openSans(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    Expanded(
      child: Text(
        "${expert['days']?.toString() ?? '0'} ",
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
                          const Icon(Icons.people,
                              color: AppColors.buttonBg, size: 18),
                          const SizedBox(width: 6),
                             Text(
      "Guided: ",
      style: GoogleFonts.openSans(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
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

                      // About
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

                      const SizedBox(height: 20),
                      Divider(color: Colors.white24),
                      const SizedBox(height: 10),

                      // Reviews
                      Text(
                        "User Reviews",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Obx(() {
                        if (controller.ratings.isEmpty) {
                          return const Text(
                            "No reviews yet",
                            style: TextStyle(color: Colors.grey),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.ratings.length,
                          itemBuilder: (context, index) {
                            final rating = controller.ratings[index];
                            return Card(
                              color: const Color(0xFF2C2C2C),
                              elevation: 3,
                              shadowColor: Colors.redAccent.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      Colors.redAccent.withOpacity(0.2),
                                  child: Text(
                                    (rating["reviewer_name"] ?? "U")[0]
                                        .toUpperCase(),
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  rating["reviewer_name"] ?? "Unknown",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Text(
                                  rating["review"] ?? "",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[300],
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    (rating["rating"] ?? 0),
                                    (i) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(
                                duration: 500.ms, delay: (index * 200).ms)
                              .slideX(begin: 0.3, end: 0);
                          },
                        );
                      }),
                    ],
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.3),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Obx(() {
            if (controller.expert.isEmpty) return const SizedBox();

            final expertPrice = controller.expert['price']?.toString() ?? "0";

            return ElevatedButton.icon(
              onPressed: () {
                Get.to(
                  () => ChatWithExpertView(
                    expertId: expertuserId,
                    expertName: controller.expert['expert_name']?.toString() ?? 'Expert',
                    expertImage: controller.expert['image']?.toString() ?? '',
                    expertPrice: expertPrice,
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
