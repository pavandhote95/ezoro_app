import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app2/app/modules/chat_both/views/chat_both_view.dart';
import '../../../constants/app_color.dart';
import '../controllers/user_profile_controller.dart';
// ✅ ChatBothView import

class UserProfileView extends StatelessWidget {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final UserProfileController controller = Get.put(UserProfileController());

    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        backgroundColor: AppColors.appbar,
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = controller.profile;

        // 🔹 Safely extract fields
        final String name = profile['name'] ?? "N/A";

        final String rawImage = profile['image_url'] ?? "";
        final String profileImage = rawImage.isNotEmpty
            ? (rawImage.startsWith('http')
                ? rawImage
                : "https://kotiboxglobaltech.com/$rawImage")
            : "https://via.placeholder.com/150";

        final String location =
            profile['travel_detail']?['location'] ?? "Unknown";
        final String joinedDate = profile['created_at'] ?? "Unknown";
        final String bio = profile['bio'] ?? "No bio available.";
        final String email = profile['email'] ?? "No email provided";
        final String phone = profile['phone_number'] ?? "No phone provided";
        final String travelInterest =
            profile['travel_detail']?['travel_interest'] ?? "Not specified";
        final String visitedPlaces =
            profile['travel_detail']?['visited_place'] ?? "Not specified";
        final String dreamDestination =
            profile['travel_detail']?['dream_destination'] ?? "Not specified";
        final String language =
            profile['travel_detail']?['language'] ?? "Not specified";
        final String travelType =
            profile['travel_detail']?['travel_type']?.toString() ??
                "Not specified";
        final String travelMode =
            profile['travel_detail']?['travel_mode'] ?? "Not specified";

        // 🔹 Stats
        final int posts = (profile['posts'] as List<dynamic>?)?.length ?? 0;
        final int points = profile['user_points'] ?? 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Profile Image & Basic Info
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade800,
                      child: profileImage.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                profileImage,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white70,
                                  );
                                },
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white70,
                            ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: GoogleFonts.openSans(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      location,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Joined: $joinedDate",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ✅ Message Button
                ElevatedButton.icon(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.buttonBg,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  onPressed: () {
    Get.to(() => ChatBothView(
          currentUser: controller.currentUserId.toString(), // ✅ Now works
          otherUser: name,
          otherUserImage: profileImage,
          otherUserId: profile['id'].toString(),
          chatId:
              "${controller.currentUserId}_${profile['id']}", // unique chat id
          isExpert: false,
        ));
  },
  icon: const Icon(Icons.message, color: Colors.white),
  label: Text(
    "Message",
    style: GoogleFonts.openSans(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
),

                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStat("Posts", posts),
                  _buildStat("Points", points),
                ],
              ),
              const Divider(color: Colors.grey, height: 32),

              // 🔹 Personal Information
              _buildCard(
                title: "Personal Information",
                children: [
                  _buildInfoRow("Bio", bio),
                  _buildInfoRow("Email", email),
                  _buildInfoRow("Phone", phone),
                ],
              ),
              const SizedBox(height: 20),

              // 🔹 Travel Details
              _buildCard(
                title: "Travel Details",
                children: [
                  _buildInfoRow("Location", location),
                  _buildInfoRow("Travel Interest", travelInterest),
                  _buildInfoRow("Visited Places", visitedPlaces),
                  _buildInfoRow("Dream Destination", dreamDestination),
                  _buildInfoRow("Language", language),
                ],
              ),
              const SizedBox(height: 20),

              // 🔹 Travel Preferences
              _buildCard(
                title: "Travel Preferences",
                children: [
                  _buildInfoRow("Travel Type", travelType),
                  _buildInfoRow("Travel Mode", travelMode),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStat(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: GoogleFonts.openSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
