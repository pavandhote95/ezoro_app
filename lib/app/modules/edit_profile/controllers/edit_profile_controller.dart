// edit_profile_controller.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'package:travel_app2/app/constants/my_toast.dart';
import 'package:travel_app2/app/modules/home/controllers/community_controller.dart';
import 'package:travel_app2/app/modules/my_profile/controllers/my_profile_controller.dart';

class EditProfileController extends GetxController {
   String baseUrl = "https://kotiboxglobaltech.com/travel_app/storage/";
  // Text controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final bioController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final travelInterestController = TextEditingController();
  final visitedPlacesController = TextEditingController();
  final dreamDestinationController = TextEditingController();
  final languageController = TextEditingController();

  var selectedTravelTypes = <String>[].obs;
  final selectedImage = Rx<File?>(null);
  var profileImageUrl = ''.obs;
  RxBool isUpdating = false.obs;
  var isLoading = false.obs;

  final ImagePicker _picker = ImagePicker();
  final GetStorage _storage = GetStorage();
  String get token => _storage.read('token') ?? '';

  final String updateProfileUrl =
      'https://kotiboxglobaltech.com/travel_app/api/update-profile';
  final String getProfileUrl =
      'https://kotiboxglobaltech.com/travel_app/api/get-profile';

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) selectedImage.value = File(pickedFile.path);
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final response = await http.get(Uri.parse(getProfileUrl), headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonResponse['status'] == true) {
        final data = jsonResponse['data'];
        final travelDetail = data['travel_detail'];

        firstNameController.text = data['first_name'] ?? '';
        lastNameController.text = data['last_name'] ?? '';
        bioController.text = data['bio'] ?? '';
        emailController.text = data['email'] ?? '';
        phoneController.text = data['phone_number'] ?? '';
        locationController.text = travelDetail['location'] ?? '';
        travelInterestController.text = travelDetail['travel_interest'] ?? '';
        visitedPlacesController.text = travelDetail['visited_place'] != null
            ? (jsonDecode(travelDetail['visited_place']) as List).join(', ')
            : '';
        dreamDestinationController.text = travelDetail['dream_destination'] ?? '';
        languageController.text = travelDetail['language'] ?? '';

        selectedTravelTypes.value = travelDetail['travel_type'] != null
            ? List<String>.from(jsonDecode(travelDetail['travel_type']))
            : ['Solo'];

        profileImageUrl.value = data['image_url'] ?? '';
        selectedImage.value = null;
      } else {
        Get.snackbar(
          'Error',
          jsonResponse['message'] ?? 'Failed to fetch profile',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Fetch profile error: $e");
    } finally {
      isLoading.value = false;
    }
  }
Future<void> updateProfile() async {
  try {
    // Required field validations
    if (firstNameController.text.trim().isEmpty) {
      CustomToast.showError(Get.context!, "First name is required");
      return;
    }
    if (lastNameController.text.trim().isEmpty) {
      CustomToast.showError(Get.context!, "Last name is required");
      return;
    }
    if (emailController.text.trim().isEmpty) {
      CustomToast.showError(Get.context!, "Email is required");
      return;
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      CustomToast.showError(Get.context!, "Enter a valid email address");
      return;
    }
    if (phoneController.text.trim().isEmpty) {
      CustomToast.showError(Get.context!, "Phone number is required");
      return;
    }
    if (phoneController.text.trim().length < 8) {
      CustomToast.showError(Get.context!, "Enter a valid phone number");
      return;
    }
    if (locationController.text.trim().isEmpty) {
      CustomToast.showError(Get.context!, "Location is required");
      return;
    }

    // 🔴 Image strict validation (image is mandatory every time)
    if (selectedImage.value == null) {
      CustomToast.showError(Get.context!, "Please select a profile image");
      return;
    }

    isUpdating.value = true;

    var request = http.MultipartRequest('POST', Uri.parse(updateProfileUrl));
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields['first_name'] = firstNameController.text.trim();
    request.fields['last_name'] = lastNameController.text.trim();
    request.fields['bio'] = bioController.text.trim();
    request.fields['email'] = emailController.text.trim();
    request.fields['phone_number'] = phoneController.text.trim();
    request.fields['location'] = locationController.text.trim();
    request.fields['travel_interest'] = travelInterestController.text.trim();
    request.fields['visited_place'] = jsonEncode(
      visitedPlacesController.text.split(',').map((e) => e.trim()).toList(),
    );
    request.fields['dream_destination'] = dreamDestinationController.text.trim();
    request.fields['language'] = languageController.text.trim();
    request.fields['travel_type'] = jsonEncode(selectedTravelTypes);

    // ✅ Add image (mandatory)
    request.files.add(
      await http.MultipartFile.fromPath('image', selectedImage.value!.path),
    );

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    var jsonResponse = jsonDecode(responseBody);

    if (response.statusCode == 201 && jsonResponse['status'] == true) {
      CustomToast.showSuccess(Get.context!, "Profile updated successfully");

      if (jsonResponse['data']?['image_url'] != null) {
        profileImageUrl.value = jsonResponse['data']['image_url'];
      }

      // Reset selected image
      selectedImage.value = null;

      // Refresh other controllers
      final myProfileController = Get.find<MyProfileController>();
      final communityController = Get.find<CommunityController>();
      await communityController.fetchPosts();
      await myProfileController.fetchProfile();
      await fetchProfile();
    } else {
      Get.snackbar(
        "Error",
        jsonResponse['message'] ?? "Failed to update profile",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  } catch (e) {
    debugPrint("Update profile error: $e");
    Get.snackbar(
      "Error",
      "Something went wrong. Please try again.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
    );
  } finally {
    isUpdating.value = false;
  }
}

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    bioController.dispose();
    emailController.dispose();
    phoneController.dispose();
    locationController.dispose();
    travelInterestController.dispose();
    visitedPlacesController.dispose();
    dreamDestinationController.dispose();
    languageController.dispose();
    super.onClose();
  }
}
