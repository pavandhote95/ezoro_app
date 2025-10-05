import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app2/app/constants/constants.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import 'package:travel_app2/app/constants/custom_button.dart';
import 'package:travel_app2/app/modules/expert_user_profile/controllers/expert_user_profile_controller.dart';
import 'package:travel_app2/app/modules/my_profile/views/rewards_info_view.dart';
import '../controllers/my_profile_controller.dart';
import '../../edit_profile/views/edit_profile_view.dart';

class MyProfileView extends GetView<MyProfileController> {
  MyProfileView({super.key});
  final MyProfileController controller = Get.put(MyProfileController());


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.appbar,
        elevation: 0,
        title: Text(
          "My Profile",
          style: GoogleFonts.openSans(color: AppColors.titleText, fontSize: 20),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopHeader(),
              _buildPromoCard(),
              const SizedBox(height: 12),
              _buildUserPosts(),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.mainBg,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: const Color.fromARGB(255, 31, 18, 18)),
            child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      final imageUrl = controller.profileImage.value;
                      return CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white24,
                        child: imageUrl.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  imageUrl,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.person, size: 40, color: Colors.white70),
                                ),
                              )
                            : const Icon(Icons.person, size: 40, color: Colors.white70),
                      );
                    }),
                    const SizedBox(height: 10),
                    Text(
                      controller.username.value != ''
                          ? controller.username.value
                          : "Guest",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      controller.role.value != ''
                          ? controller.role.value
                          : "Traveler",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                )),
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.white),
            title: Text("Settings", style: GoogleFonts.poppins(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.verified_user, color: Colors.white),
            title: Text("My Badges", style: GoogleFonts.poppins(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.white),
            title: Text("Help & Support", style: GoogleFonts.poppins(color: Colors.white)),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Obx(() {
                    final imageUrl = controller.profileImage.value;
                    return CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white24,
                      child: imageUrl.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                imageUrl,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.person, size: 40, color: Colors.white70),
                              ),
                            )
                          : const Icon(Icons.person, size: 40, color: Colors.white70),
                    );
                  }),
                  const SizedBox(width: 24),
           Expanded(
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      _buildStatColumn("Posts", controller.totalPosts.value),
      Obx(() {
        final points = controller.userPoints.value;
        return _buildStatColumn("Points", points);
      }),
    ],
  ),
),

                ],
              ),
              const SizedBox(height: 16),
              Text(
                controller.username.value != '' ? controller.username.value : "Guest",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                controller.role.value != '' ? controller.role.value : "Traveler",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Get.to(() => EditProfileView());
                    // controller.fetchProfile(); // refresh after editing
                  },
                  icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                  label: Text(
                    "Edit Profile",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    backgroundColor: Colors.white.withOpacity(0.08),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              )
            ],
          )),
    );
  }

  Widget _buildUserPosts() {
    return Obx(() {
      if (controller.userPosts.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "No posts yet.",
            style: GoogleFonts.poppins(color: Colors.grey.shade400),
          ),
        );
      }

      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: controller.userPosts.length,
        itemBuilder: (context, index) {
          final post = controller.userPosts[index];
          final String? mainImage = post['image'];

          return Card(
            color: AppColors.centerright,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (mainImage != null && mainImage.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: baseUrl + mainImage,
                        placeholder: (context, url) =>
                            Container(height: 100, width: 100, color: Colors.black26),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error, color: Colors.redAccent),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.username.value.isNotEmpty
                              ? controller.username.value
                              : "Guest",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if ((post['title'] ?? '').isNotEmpty)
                          Text(
                            post['title'],
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: TextButton.icon(
                            onPressed: () => Get.defaultDialog(
                              title: "Confirm Delete",
                              middleText: "Are you sure you want to delete this post?",
                              textConfirm: "Yes",
                              textCancel: "No",
                              confirmTextColor: Colors.white,
                              onConfirm: () {
                                controller.deletePost(post['id']);
                                Get.back();
                              },
                            ),
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            label: Text(
                              "Delete",
                              style: GoogleFonts.poppins(color: Colors.redAccent),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
Widget _buildStatColumn(String label, int value) => SizedBox(
      width: 80,
      height: 72,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$value",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );

  Widget _buildPromoCard() => InkWell(
        onTap: () => Get.to(() => RewardsInfoView()),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.card_giftcard_rounded, color: Colors.redAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Ask, answer, earn - every question and reply gives you rewards",
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildLogoutButton() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: SizedBox(
          width: double.infinity,
          child: CustomButton(
            isLoading: controller.isLoading,
            onPressed: controller.logoutUser,
            text: 'Logout',
            textColor: Colors.white,
          ),
        ),
      );
}
