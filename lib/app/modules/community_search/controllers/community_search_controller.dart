import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityModel {
  final String name;
  final String description;

  CommunityModel({required this.name, required this.description});
}

class CommunitySearchController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxList<CommunityModel> allCommunities = <CommunityModel>[
    CommunityModel(name: "Beach Lovers", description: "For those who love sun & sand."),
    CommunityModel(name: "Mountain Trekkers", description: "Explore the world's highest peaks."),
    CommunityModel(name: "City Explorers", description: "Discover hidden gems in cities."),
    CommunityModel(name: "Cultural Nomads", description: "Celebrate global traditions."),
  ].obs;

  final RxList<CommunityModel> filteredCommunities = <CommunityModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    filteredCommunities.assignAll(allCommunities);
  }

  void onSearchChanged(String query) {
    if (query.isEmpty) {
      filteredCommunities.assignAll(allCommunities);
    } else {
      final results = allCommunities.where((community) =>
      community.name.toLowerCase().contains(query.toLowerCase()) ||
          community.description.toLowerCase().contains(query.toLowerCase()));
      filteredCommunities.assignAll(results);
    }
  }
}
