import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:travel_app2/app/modules/home/controllers/community_controller.dart';

class DashboardController extends GetxController {
  final selectedIndex = 0.obs;
  final showSearchBar = false.obs;
  final isTravelingModeOn = false.obs;

  final TextEditingController searchController = TextEditingController();

  /// Handle tab switching with optional special behavior for Search tab
  void changeTab(int index) {
    if (index == 1) {
      // Instead of switching to index 1 (CommunitySearchView),
      // activate search bar and stay on home (index 0)
      showSearchBar.value = true;
      selectedIndex.value = 0;
    } else {
      showSearchBar.value = false;
      selectedIndex.value = index;
    }
  }

  /// Enables traveling mode: gets location, fetches posts by city
  Future<void> enableTravelingMode() async {
    isTravelingModeOn.value = true;

    try {
      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar("Location Error", "Please enable location services.");
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar("Permission Denied", "Location access is required.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          "Permission Blocked",
          "Location access is permanently denied. Enable it from settings.",
        );
        return;
      }

      // Get current location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocoding to get city
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final city = placemarks.first.locality ?? '';
      if (city.isNotEmpty) {
        // Fetch posts from that city via CommunityController
        Get.find<CommunityController>().fetchPostsByLocation(city);
        Get.snackbar("Traveling Mode Activated", "Showing posts from $city");
      } else {
        Get.snackbar("Location Error", "City not detected from GPS.");
      }
    } catch (e) {
      Get.snackbar("Error", "Unable to get location: $e");
    } finally {
      isTravelingModeOn.value = false;
    }
  }
}
