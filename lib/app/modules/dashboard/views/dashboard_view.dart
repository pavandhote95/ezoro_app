import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import 'package:travel_app2/app/modules/expert/views/expert_view.dart';
import 'package:travel_app2/app/modules/expert_user_profile/views/expert_user_profile_view.dart';

import '../../community_search/views/community_search_view.dart';
import '../../home/views/home_view.dart';
import '../../my_profile/views/my_profile_view.dart';
import '../../notifications/views/notifications_view.dart';
 // ✅ import user profile
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  DashboardView({super.key});

  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    // ✅ user_type check
    final String userType = box.read('user_type') ?? 'user';

    final List<Widget> pages = [
      HomeView(),
      CommunitySearchView(),
      userType == "expert"
          ? ExpertUserProfileView()
          : ExpertView(), // ✅ if expert → ExpertView, else → UserProfileView
      NotificationView(),
      MyProfileView(),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() => pages[controller.selectedIndex.value]),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: isKeyboardVisible
          ? null
          : GestureDetector(
              onTap: () => controller.changeTab(2),
              child: Transform.translate(
                offset: const Offset(0, 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.buttonBg,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        CupertinoIcons.star_fill,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userType == "user"
                          ? "Expert\nTraveler"
                          : "User\nProfile", // ✅ correct label
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.buttonBg,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

      bottomNavigationBar: Obx(
        () => SafeArea(
          child: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 12,
            color: Colors.black,
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTabIcon(
                    CupertinoIcons.house_fill,
                    0,
                    customColor:
                        controller.showSearchBar.value ? Colors.grey : null,
                  ),
                  _buildTabIcon(
                    CupertinoIcons.search,
                    1,
                    customColor: controller.showSearchBar.value
                        ? AppColors.icons
                        : null,
                  ),
                  const SizedBox(width: 48), // FAB space
                  _buildTabIcon(CupertinoIcons.bell, 3),
                  _buildTabIcon(CupertinoIcons.person, 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabIcon(IconData icon, int index, {Color? customColor}) {
    bool isActive = controller.selectedIndex.value == index;

    Color iconColor = customColor ??
        (isActive ? AppColors.buttonBg : Colors.white.withOpacity(0.5));

    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 26,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
