import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:travel_app2/app/modules/home/controllers/community_controller.dart';
import 'package:travel_app2/app/services/api_service.dart';

class BottomSheetQuestionsController extends GetxController {
  final RxList<File> selectedImages = <File>[].obs;
  final RxString selectedLocation = ''.obs;
  final RxString questionText = ''.obs;
  final ApiService _apiService = Get.find<ApiService>();
  final ImagePicker _picker = ImagePicker();
  final RxBool isPickingImage = false.obs;
  final RxBool isLoading = false.obs;
  final CommunityController communityController = Get.find<CommunityController>();
  final TextEditingController locationController = TextEditingController();

  //  Search results for location
  final RxList<String> searchResults = <String>[].obs;
  final RxBool isSearching = false.obs;

  // ------------------ Image Picker ------------------
  Future<void> pickImages() async {
    if (isPickingImage.value) return;
    try {
      isPickingImage.value = true;
      final List<XFile>? pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
      }
    } finally {
      isPickingImage.value = false;
    }
  }

  void clearImages() => selectedImages.clear();
  void updateQuestion(String value) => questionText.value = value;

  void updateLocation(String value) {
    selectedLocation.value = value;
    if (locationController.text != value) {
      locationController.text = value;
      locationController.selection = TextSelection.fromPosition(
        TextPosition(offset: locationController.text.length),
      );
    }
  }

  // ------------------ Fetch Locations from OpenStreetMap Nominatim ------------------
  Future<void> fetchLocations(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    isSearching.value = true;
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=25',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'MyTravelApp/1.0 (pavandhote95@gmail.com)',  // required by Nominatim
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final results = data.map<String>((place) {
          final displayName = place['display_name'] ?? '';
          return displayName;
        }).toList();

        searchResults.assignAll(results);
      } else {
        Get.snackbar('Error', 'Failed to fetch locations: ${response.statusCode}',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch locations: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSearching.value = false;
    }
  }

  // ------------------ Submit Post ------------------
  Future<void> submitPost() async {
    if (questionText.value.isEmpty || selectedLocation.value.isEmpty) {
      Get.snackbar('Error', 'Please fill in both question and location fields',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      final response = await _apiService.addPost(
        question: questionText.value,
        location: selectedLocation.value,
        imageFiles: selectedImages.isNotEmpty ? selectedImages : null,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Get.back();
        Get.snackbar('Success', 'Post created successfully',
            backgroundColor: Colors.green, colorText: Colors.white);

        try {
          await communityController.fetchPosts();
        } catch (e) {
          Get.snackbar('Warning',
              'Post created but failed to fetch updated posts: $e',
              backgroundColor: Colors.orange, colorText: Colors.white);
        }

        questionText.value = '';
        selectedLocation.value = '';
        selectedImages.clear();
      } else {
        Get.snackbar(
            'Error',
            'Failed to create post: ${response.statusCode} - ${response.reasonPhrase}',
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create post: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
