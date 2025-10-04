import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class UserProfileController extends GetxController {
  var isLoading = true.obs;
  var profile = <String, dynamic>{}.obs;

  final box = GetStorage();
  late int userId;

  // ✅ Add a getter for the current logged-in user ID
  int get currentUserId => box.read('user_id') ?? 0;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>? ?? {};
    dynamic idValue = args['user_id'];

    if (idValue is int) {
      userId = idValue;
    } else if (idValue is String) {
      userId = int.tryParse(idValue) ?? 0;
    } else {
      userId = 0;
    }

    if (userId > 0) {
      fetchProfile();
    } else {
      Get.snackbar('Error', 'Invalid user id');
      isLoading(false);
    }
  }

void fetchProfile() async {
  final token = box.read('token') ?? '';
  if (token.isEmpty) {
    Get.snackbar('Error', 'User not logged in');
    return;
  }

  try {
    isLoading(true);
    final response = await http.get(
      Uri.parse(
          'https://kotiboxglobaltech.com/travel_app/api/get-profile-byid/$userId'),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    print("🔹 API Response Status: ${response.statusCode}");
    print("🔹 API Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("🔹 Parsed Data: $data");

      if (data['status'] == true) {
        profile.value = data['data'] ?? {};
        print("🔹 Profile Map: ${profile.value}");

        // ✅ Save user_type to GetStorage
        final String userType = profile.value['user_type'] ?? 'user';
        box.write('user_type', userType);
        debugPrint("👤 Saved user_type: $userType"); // ✅ print for confirmation

      } else {
        Get.snackbar("Error", data['message'] ?? "Unknown error");
      }
    } else {
      Get.snackbar("Error", "Failed to fetch profile");
    }
  } catch (e) {
    Get.snackbar("Error", e.toString());
    print("🔹 Exception: $e");
  } finally {
    isLoading(false);
  }
}

}