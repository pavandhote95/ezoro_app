import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import 'package:travel_app2/app/constants/my_toast.dart';
import 'package:travel_app2/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:travel_app2/app/modules/dm/views/dm_view.dart';
import 'package:travel_app2/app/modules/home/controllers/community_controller.dart';
import 'package:travel_app2/app/modules/my_profile/controllers/my_profile_controller.dart';
import 'package:travel_app2/app/widgets/custom_appbar_controller.dart';

class HeaderWidget extends StatelessWidget {
  HeaderWidget({Key? key}) : super(key: key);

  final LocationController locationController = Get.put(LocationController());
  final RxBool isToggled = false.obs;
  final MyProfileController controller = Get.find<MyProfileController>();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            final dashboardController = Get.find<DashboardController>();
            dashboardController.selectedIndex.value = 4;
          },
          child:
          
        Obx(() {
  if (controller.profileImage.value.isEmpty && controller.isLoading.value) {
    return _buildShimmerAvatar(); // While loading
  }

  return CircleAvatar(
    radius: 26,
    backgroundColor: Colors.white24,
    child: controller.profileImage.value.isNotEmpty
        ? ClipOval(
            child: Image.network(
              controller.profileImage.value,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.person,
                size: 28,
                color: Colors.white70,
              ),
            ),
          )
        : const Icon(Icons.person, size: 28, color: Colors.white70),
  );
}),

      
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Inside HeaderWidget build()

FittedBox(
  fit: BoxFit.scaleDown,
  alignment: Alignment.centerLeft,
  child: Obx(() {
    String name = controller.firstname.value;

    if (name.isEmpty) {
      // Show "Loading..." instead of shimmer
      return Text(
        'Loading...',
        style: GoogleFonts.openSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade500,
        ),
      );
    }

    String displayName =
        name[0].toUpperCase() + name.substring(1).toLowerCase();

    return Text(
      'Hi, $displayName !',
      style: GoogleFonts.openSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.buttonBg,
      ),
    );
  }),

          
  
),
const SizedBox(height: 6),
Row(
  children: [
    const Icon(Icons.location_on, color: AppColors.buttonBg, size: 18),
    const SizedBox(width: 4),
    Expanded(
      child: Obx(() {
        final address = locationController.currentAddress.value;

        if (address.isEmpty) {
          // Show shimmer instead of blank
          return Shimmer.fromColors(
            baseColor: Colors.grey[800]!,
            highlightColor: Colors.grey[600]!,
            child: Container(
              height: 14,
              width: 140,
              color: Colors.grey[800],
            ),
          );
        }

        return Text(
          address,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.openSans(
            fontSize: 13,
            color: Colors.grey[400],
          ),
        );
      }),
    ),
  ],
),

           
            ],
          ),
        ),
     Obx(
              () => Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Mode Icon
              Icon(
                isToggled.value ? Icons.flight : Icons.home,
                color: AppColors.icons,
                size: 31,
              ),
              const SizedBox(width: 6),
              // Switch with custom theme
              Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  switchTheme: SwitchThemeData(
                    thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.blueGrey; // ON
                      }
                      return AppColors.buttonBg; // OFF
                    }),
                    trackColor: MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.selected)) {
                        return AppColors.buttonBg;
                      }
                      return AppColors.buttonBg.withOpacity(0.3);
                    }),
                    trackOutlineColor: MaterialStateProperty.all(AppColors.buttonBg),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                ),
                child: Transform.scale(
                  scale: 0.9,
                  child: Switch(
                    value: isToggled.value,
                    onChanged: (value) async {
                      isToggled.value = value;
                      final communityController = Get.find<CommunityController>();

                      communityController.setTravelingMode(value); // Notify controller of mode change

                      if (value) {
                        // Enable travel mode
                        CustomToast.showSuccessHome(context, "Traveling mode is ON");
                        await locationController.getCurrentLocation();
                        final city = locationController.city.value;
                        if (city.isNotEmpty) {
                          communityController.fetchPostsByLocation(city);
                        }
                      } else {
                        // Disable travel mode
                        CustomToast.showErrorHome(context, "Traveling mode is OFF");
                        communityController.fetchPosts();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 5),
              // Telegram Icon with Navigation to DM Page
              InkWell(
                onTap: () {
                  Get.to(() =>  DmView());
                },
                child: Image.asset(
                  'assets/icons/telegram.png',
                  height: 32,
                  width: 32,
                  fit: BoxFit.contain,
                  color: AppColors.buttonBg,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
    
      ],
    );
  }

  Widget _buildShimmerAvatar() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[600]!,
      child: const CircleAvatar(
        radius: 26,
        backgroundColor: Colors.grey,
      ),
    );
  }
}

class DMPage extends StatelessWidget {
  const DMPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        backgroundColor: AppColors.mainBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonBg),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Messages',
          style: GoogleFonts.openSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF252525),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                  ),
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
                child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Get.to(() => ChatScreen(userName: 'User $index'));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F1F1F),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _buildShimmerAvatarSmall(index),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'User $index',
                                    style: GoogleFonts.openSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Last message preview...',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '10:3${index % 9} AM',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerAvatarSmall(int index) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[600]!,
      child: const CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey,
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  final String userName;

  const ChatScreen({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        backgroundColor: AppColors.mainBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonBg),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            _buildShimmerAvatarSmall(),
            const SizedBox(width: 12),
            Text(
              userName,
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                itemBuilder: (context, index) {
                  bool isSentByMe = index % 2 == 0;
                  return Align(
                    alignment: isSentByMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSentByMe
                            ? AppColors.buttonBg
                            : const Color(0xFF252525),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Message $index',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                border: Border(top: BorderSide(color: Colors.grey.shade800)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF252525),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: GoogleFonts.inter(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send,
                        color: AppColors.buttonBg, size: 24),
                    onPressed: () {
                      CustomToast.showSuccessHome(context, 'Message sent');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerAvatarSmall() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[600]!,
      child: const CircleAvatar(
        radius: 18,
        backgroundColor: Colors.grey,
      ),
    );
  }
}
