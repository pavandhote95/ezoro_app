import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app2/app/modules/experts_profile/controllers/experts_profile_controller.dart';
import 'package:travel_app2/app/modules/travellers/controllers/travellers_controller.dart';
import 'package:travel_app2/app/modules/travellers/views/all_expert_chat_model.dart';
import 'package:travel_app2/app/routes/app_pages.dart';

class TravellersView extends StatelessWidget {
  final int expertuserId;
  TravellersView({Key? key, required this.expertuserId}) : super(key: key);

  final TravellersController controller = Get.put(TravellersController());
  final ExpertsProfileController profileController = Get.put(
    ExpertsProfileController(),
  );

  @override
  Widget build(BuildContext context) {
    // Load expert detail here to ensure expertuserId is available
    profileController.fetchExpertDetail(expertuserId);

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // 🖥 Print travellers data in terminal
      print("✅ Loaded travellers for expertId: $expertuserId");
      for (var t in controller.travellers) {
        print(
          "Traveller => id:${t.userId}, name:${t.name}, profile:${t.profile}, lastMessage:${t.lastMessage}",
        );
      }

      // 🖥 Print expert data in terminal
      print("✅ Expert Data => ${profileController.expert}");

      return SafeArea(child: _buildTravellerList(controller.travellers));
    });
  }

  Widget _buildTravellerList(List<UserModel2> travellers) {
    if (travellers.isEmpty) {
      print("⚠️ No travellers found for this expert");
      return Center(
        child: Text(
          "No Travellers Found",
          style: GoogleFonts.inter(fontSize: 16, color: Colors.grey.shade500),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: travellers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final traveller = travellers[index];
        print("📌 Building Traveller Widget => ${traveller.name}");

        return GestureDetector(
          onTap: () {
            final priceToSend = traveller.price ?? "0"; // ✅ Use traveller’s price

            print("💰 Navigating to chat with Traveller: ${traveller.name}");
            print("💵 Price being sent: $priceToSend");

            Get.toNamed(
              Routes.TALK_TO_TRAVELLERS_CHAT,
              arguments: {
                "travellerId": traveller.userId,
                "travellerName": traveller.name,
                "travellerImage": traveller.profile,
                "price": priceToSend, // ✅ pass correct price
              },
            );
          },



          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F1F),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildAvatar(traveller.profile, traveller.name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        traveller.name,
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                    Text(
  traveller.lastMessage != null && traveller.lastMessage!.length > 20
      ? "${traveller.lastMessage!.substring(0, 5)}..."
      : (traveller.lastMessage ?? "Tap to chat"),
  style: GoogleFonts.inter(
    fontSize: 14,
    color: Colors.grey.shade500,
  ),
),

                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(String? imageUrl, String name) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.network(
          imageUrl,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print("❌ Failed to load image for $name");
            return _initialsAvatar(name);
          },
        ),
      );
    } else {
      print("ℹ️ No image for $name, showing initials");
      return _initialsAvatar(name);
    }
  }

  Widget _initialsAvatar(String name) {
    final initials = (name.isNotEmpty ? name[0] : "?").toUpperCase();
    final bgColors = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    final colorIndex = name.hashCode % bgColors.length;

    return CircleAvatar(
      radius: 24,
      backgroundColor: bgColors[colorIndex],
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}
