import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import 'package:travel_app2/app/modules/chat/controllers/chat_controller.dart';
import 'package:travel_app2/app/modules/expert/views/expert_view.dart';
import 'package:travel_app2/app/modules/travellers/views/travellers_view.dart';
import '../controllers/dm_controller.dart';
import 'user_model.dart';

class DmView extends StatelessWidget {
  const DmView({Key? key, this.initialIndex = 0}) : super(key: key);

  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    final DmController controller = Get.put(DmController());
    final ChatController chatController = Get.put(ChatController());

    // ✅ Example: Get expertId dynamically from arguments (if needed)
    final int expertuserId = Get.arguments?['id'] ?? 0;

    return DefaultTabController(
      length: 2,
      initialIndex: initialIndex,
      child: Scaffold(
        backgroundColor: AppColors.mainBg,
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: () {
                  Get.to(ExpertView()); // Navigate to Experts tab
                },
                child: Container(
                  height: 40,
                  width: 100,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.buttonBg,

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text("Experts", style: TextStyle(color: Colors.black54)),
                      SizedBox(width: 4),
                      const Icon(
                        CupertinoIcons.star_fill,
                        color: Colors.black54,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          backgroundColor: AppColors.mainBg,
          elevation: 0,
          title: Text(
            "Messages",
            style: GoogleFonts.openSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: AppColors.buttonBg,
            labelColor: AppColors.buttonBg,
            unselectedLabelColor: Colors.white70,
            labelStyle: GoogleFonts.openSans(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: "Users"),
              Tab(text: "Talk to Experts"),
            ],
          ),
        ),
        body: Column(
          children: [
            // 🔍 Search bar
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF252525),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  hintStyle: GoogleFonts.inter(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  icon: const Icon(Icons.search, color: AppColors.buttonBg),
                ),
              ),
            ),
          Expanded(
  child: TabBarView(
    children: [
      // 🔹 Users tab with pull-to-refresh
      RefreshIndicator(
        color: AppColors.buttonBg, // your theme color
        onRefresh: () async {
          await controller.fetchUsers(); // your existing fetch function
        },
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: SizedBox(
                height: 120,
                width: 120,
                child: Lottie.asset(
                  'assets/lottie/Loading.json', 
                  repeat: true,
                  animate: true,
                ),
              ),
            );
          }
          return _buildUserList(
            controller.users,
            "No Users Found",
            chatController,
          );
        }),
      ),

      // 🔹 Travellers tab with pull-to-refresh
      RefreshIndicator(
        color: AppColors.buttonBg, // your theme color
        onRefresh: () async {
          await controller.fetchTravellers(); // your existing fetch function
        },
        child: TravellersView(expertuserId: expertuserId),
      ),
    ],
  ),
),

          ],

        ),
      ),
    );
  }

  /// 🔹 Common User List
  Widget _buildUserList(
    List<UserModel> userList,
    String emptyMsg,
    ChatController chatController,
  ) {
    if (userList.isEmpty) {
      return Center(
        child: Text(
          emptyMsg,
          style: GoogleFonts.inter(fontSize: 16, color: Colors.grey.shade500),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: userList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = userList[index];

        return GestureDetector(
          onTap: () {
            chatController.startChatWithUser({
              "id": user.userId,
              "name": user.name,
              "profile": user.profile,
            });
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F1F),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildAvatar(user.profile, user.name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                     Text(
  user.lastMessage != null
      ? user.lastMessage!
          .split(' ')
          .take(10)
          .join(' ') +
          (user.lastMessage!.split(' ').length > 10 ? '...' : '')
      : "Tap to chat",
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

  /// 🔹 Avatar with fallback initials2
  Widget _buildAvatar(String? imageUrl, String name) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[800],
        backgroundImage: NetworkImage(imageUrl),
      );
    } else {
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
}
