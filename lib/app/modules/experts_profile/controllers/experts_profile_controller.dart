import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class ExpertsProfileController extends GetxController {
  var expert = <String, dynamic>{}.obs;
  var isLoading = true.obs;
  var ratings = <dynamic>[].obs;

  final box = GetStorage();

  Future<void> fetchExpertDetail(int id) async {
    isLoading.value = true;
    try {
      final token = box.read('token');
      if (token == null) {
        Get.snackbar("Error", "No token found. Please login first.");
        return;
      }

      final response = await http.get(
        Uri.parse("http://kotiboxglobaltech.com/travel_app/api/experts/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 &&
          data["success"] == true &&
          data["data"] != null) {
        expert.value = data["data"];

        // Ratings
        if (data["data"]["ratings"] != null) {
          ratings.assignAll(data["data"]["ratings"]);
        } else {
          ratings.clear();
        }

        print("✅ Expert average rating: ${expert['average_rating']}");
      } else {
        print("⚠️ Failed to fetch expert data: ${data["message"] ?? 'No message'}");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  String getLanguages() {
    if (expert.value["language"] != null) {
      List langs = expert.value["language"];
      return langs.map((e) => e["value"].toString()).join(", ");
    }
    return "";
  }
}
