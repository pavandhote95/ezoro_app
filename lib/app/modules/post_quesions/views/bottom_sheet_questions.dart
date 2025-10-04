import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import 'package:travel_app2/app/constants/custom_button.dart';
import 'package:travel_app2/app/modules/post_quesions/controllers/bottom_sheet_controller.dart';

class BottomSheetQuestionsView extends GetView<BottomSheetQuestionsController> {

  BottomSheetQuestionsController controller = Get.put(BottomSheetQuestionsController());

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F2027),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),  
          ),
        ],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildTextField(),
            const SizedBox(height: 20),
            _buildImagePicker(),
            const SizedBox(height: 20),
            //   _buildDropdown(["Japan", "India", "USA"]),
            _buildCitySearchField(),
            const SizedBox(height: 24),
            SafeArea(
              child: CustomButton(
                isLoading: controller.isLoading,
                onPressed: controller.submitPost,
                text: "Post",
                textColor: Colors.white,

              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Create a Post",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close, color: Colors.white70, size: 24),
        ),
      ],
    );
  }

  Widget _buildTextField() {
    return TextField(
      onChanged: controller.updateQuestion,
      maxLines: 5,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: "What's on your mind?",
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16),
        filled: true,
        fillColor: const Color(0xFF1F1F1F),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.buttonBg, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildCitySearchField() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller.locationController,
            onChanged: (value) {
              controller.updateLocation(value);   // keep Rx + controller in sync
              controller.fetchLocations(value);   // fetch suggestions from Nominatim
            },
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              labelText: "Location",
              labelStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
              floatingLabelStyle: TextStyle(color: AppColors.buttonBg, fontSize: 14),
              filled: true,
              fillColor: const Color(0xFF1F1F1F),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.buttonBg, width: 1.5),
              ),
              suffixIcon: controller.isSearching.value
                  ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
                  : const Icon(Icons.search, color: Colors.white70),
            ),
          ),

          // Suggestions dropdown
          if (controller.searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: controller.searchResults.length,
                itemBuilder: (context, index) {
                  final place = controller.searchResults[index];
                  return ListTile(
                    title: Text(place, style: const TextStyle(color: Colors.white)),
                    onTap: () {
                      controller.updateLocation(place);    // set location
                      controller.searchResults.clear();     // hide suggestions
                      FocusScope.of(context).unfocus();     // close keyboard
                    },
                  );
                },
              ),
            ),
        ],
      );
    });

}




  Widget _buildImagePicker() {
    return Obx(() {
      final images = controller.selectedImages;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: controller.pickImages,
            child: Container(
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade700, width: 1),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, color: AppColors.buttonBg, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Add Images",
                      style: TextStyle(color: AppColors.buttonBg, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (images.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            images[index],
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => controller.selectedImages.removeAt(index),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.6),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      );
    });
  }
}