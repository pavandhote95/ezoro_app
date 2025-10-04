import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/app_color.dart';
import '../../../constants/text_fonts.dart';
import '../controllers/community_search_controller.dart';

class CommunitySearchView extends GetView<CommunitySearchController> {
  @override
  final CommunitySearchController controller = Get.put(CommunitySearchController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg, // Match dashboard background
      appBar: AppBar(
        backgroundColor: AppColors.appbar,
        foregroundColor: AppColors.buttonBg,
        elevation: 2,
        title: Text(
          'Explore Communities',
          style: KTextStyle.montSerrat(
            fs: 20,
            fw: FontWeight.bold,
            c: AppColors.titleText,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextFormField(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'Search destinations or interests...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: const Icon(CupertinoIcons.search, color: AppColors.buttonBg),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                  filled: true,
                  fillColor: const Color(0xFF1C1C1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade600),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade600),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade400, width: 0.1),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/search_image.png',
                    width: 180,
                    color: AppColors.buttonBg,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "No results found",
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

    );
  }
}