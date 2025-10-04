import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class ExpertController extends GetxController {
  var experts = [].obs;       // Filtered list for UI
  var allExperts = [].obs;    // Original list from API
  var isLoading = true.obs;

  final box = GetStorage();
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchExperts();
  }

  Future<void> fetchExperts() async {
    try {
      isLoading.value = true;
      final token = box.read('token');

      if (token == null) {
        Get.snackbar("Error", "No token found. Please login first.");
        isLoading.value = false;
        return;
      }

      final response = await http.get(
        Uri.parse("http://kotiboxglobaltech.com/travel_app/api/experts"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          allExperts.value = data["data"];
          experts.value = data["data"]; // ✅ initially show all
        }
      } else {
        Get.snackbar("Error", "Failed to fetch experts: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // 🔍 Search function
  void searchExperts(String query) {
    if (query.isEmpty) {
      experts.value = allExperts;
    } else {
      experts.value = allExperts.where((expert) {
        final title = expert['title']?.toString().toLowerCase() ?? '';
        final subtitle = expert['sub_title']?.toString().toLowerCase() ?? '';
        final location = expert['location']?.toString().toLowerCase() ?? '';

        return title.contains(query.toLowerCase()) ||
            subtitle.contains(query.toLowerCase()) ||
            location.contains(query.toLowerCase());
      }).toList();
    }
  }
}
