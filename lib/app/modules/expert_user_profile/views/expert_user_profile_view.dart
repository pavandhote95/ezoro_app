import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import '../controllers/expert_user_profile_controller.dart';

class ExpertUserProfileView extends GetView<ExpertUserProfileController> {
  ExpertUserProfileView({super.key});
  final ExpertUserProfileController controller =
      Get.put(ExpertUserProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        backgroundColor: AppColors.mainBg,
        centerTitle: true,
        elevation: 0,
        title: Text(
          "Expert Profile",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.profileData.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.redAccent),
          );
        }

        if (controller.profileData.isEmpty) {
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

        final data = controller.profileData;

        return RefreshIndicator(
          color: Colors.redAccent,
          onRefresh: () async {
            await controller.fetchExpertUserProfile();
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ---------------- Profile Image ----------------
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.buttonBg,
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.grey.shade900,
                    backgroundImage: (data["image"] != null &&
                            (data["image"] as String).isNotEmpty)
                        ? NetworkImage(data["image"])
                        : null,
                    child: (data["image"] == null ||
                            (data["image"] as String).isEmpty)
                        ? const Icon(Icons.person,
                            size: 60, color: Colors.white70)
                        : null,
                  ),
                ).animate().fadeIn(duration: 600.ms).scale(duration: 600.ms),

                const SizedBox(height: 16),

                // ---------------- Name ----------------
                Text(
                  data["expert_name"] ?? "No Name",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),

                // ---------------- Email & Phone ----------------
                Text(
                  data["email"] ?? "No Email",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  data["phone_number"] ?? "No Phone",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 20),

                // ---------------- Expert Info Card ----------------
                _detailCard(
                  title: data["title"],
                  subtitle: data["sub_title"],
                  price: data["price"],
                  Itinerary: data["days"],
                  guided: data["guided"],
                  location: data["location"],
                  languages: data["language"],
                ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.3, end: 0),

                const SizedBox(height: 20),

                // ---------------- About Section ----------------
              

                const SizedBox(height: 24),

                // ---------------- Reviews Section ----------------
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "User Reviews",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Obx(() {
                  final ratings =
                      (controller.profileData["ratings"] as RxList).toList();

                  if (ratings.isEmpty) {
                    return const Center(
                      child: Text(
                        "No reviews yet",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ratings.length,
                    itemBuilder: (context, index) {
                      final rating = ratings[index];
                      return Card(
                        color: const Color(0xFF2C2C2C),
                        elevation: 4,
                        shadowColor: Colors.redAccent.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                              AppColors.buttonBg,
                            child: Text(
                              (rating["reviewer_name"] ?? "U")[0]
                                  .toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color:    Colors.white,
                              ),
                            ),
                          ),
                          title: Text(
                            rating["reviewer_name"] ?? "Unknown",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            rating["review"] ?? "No review text",
                            style: GoogleFonts.poppins(
                              color: Colors.grey[300],
                              fontSize: 13,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              (rating["rating"] ?? 0),
                              (i) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 500.ms, delay: (index * 200).ms)
                          .slideX(begin: 0.3, end: 0);
                    },
                  );
                }),
                      const SizedBox(height: 10),
           const SizedBox(height: 10),
Align(
  alignment: Alignment.centerLeft,
  child: Text(
    "About the Expert",
    style: GoogleFonts.poppins(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),
),
const SizedBox(height: 8),

// ---------- About Text Container ----------
Container(
  height: 120, // fixed height, adjust as needed
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: const Color(0xFF2C2C2C),
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ],
  ),
  child: SingleChildScrollView(
    child: Text(
      data["about"] ?? "No about information available",
      style: GoogleFonts.poppins(
        color: Colors.white70,
        fontSize: 14,
        height: 1.5,
      ),
    ),
  ),
),

              ],
            ),
          ),
        );
      }),
    );
  }

  // ---------------- Helper Card ----------------
  Widget _detailCard({
    required String? title,
    required String? subtitle,
    required String? price,
    required dynamic Itinerary,
    required String? guided,
    required String? location,
    required List<dynamic>? languages,
  }) {
    return Card(
      color: const Color(0xFF2C2C2C),
      elevation: 4,
      shadowColor:    AppColors.buttonBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _infoRow(Icons.title, "Title", title),
            _infoRow(Icons.subtitles, "Subtitle", subtitle),
            _infoRow(Icons.currency_rupee, "Price", "₹${price ?? 'N/A'}"),
            _infoRow(Icons.calendar_today, "Itinerary", Itinerary?.toString()),
            _infoRow(Icons.people, "Guided", guided),
            _infoRow(Icons.place, "Location", location),
            _infoRow(
              Icons.language,
              "Languages",
              (languages != null && languages.isNotEmpty)
                  ? languages.map((e) => e['value']).join(', ')
                  : "N/A",
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color:   AppColors.buttonBg, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$label: ",
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value ?? "N/A",
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
