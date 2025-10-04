import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import 'package:travel_app2/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:travel_app2/app/modules/home/controllers/community_controller.dart' hide CommunityTab;
import 'package:travel_app2/app/modules/home/views/Tabes/CommunityTab.dart';
import 'package:travel_app2/app/widgets/custom_appbar.dart';

class HomeView extends GetView<DashboardController> {
  final DashboardController dashboardController = Get.find();
@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081B22),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
     
        child: Obx(() {  
          return dashboardController.showSearchBar.value
              ? AppBar(
                  toolbarHeight: 110,
                  backgroundColor: Colors.black,
                  elevation: 0,
                  automaticallyImplyLeading: false,
             title: Padding(
  padding: const EdgeInsets.only(top: 10),
  child: TextField(
    controller: dashboardController.searchController,
    onChanged: (value) {
      // Call search logic here
      final communityController = Get.find<CommunityController>();
      communityController.searchPosts(value);
    },
    decoration: InputDecoration(
      hintText: 'Search posts, places...',

      filled: true,
      fillColor: AppColors.cardBg,
      prefixIcon: const Icon(Icons.search),
      suffixIcon: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          dashboardController.showSearchBar.value = false;
          dashboardController.searchController.clear();

          Get.find<CommunityController>().searchPosts('');

        },
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide(color: AppColors.buttonBg, width: 0.1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide(color: AppColors.buttonBg, width: 0.1),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide(color: AppColors.buttonBg, width: 0.1),
      ),
    ),
  ),
),

                )
              : AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.black,
                  elevation: 0,

                  title: HeaderWidget(),
                  toolbarHeight: 110,
                );
        }),
      ),

      body: SafeArea(child: CommunityTab()),
    );
  }
}
