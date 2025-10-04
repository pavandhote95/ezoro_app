import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class ExpertsProfileController extends GetxController {
  var expert = <String, dynamic>{}.obs;
  var isLoading = true.obs;

  final box = GetStorage();

  Future<void> fetchExpertDetail(int id) async {
    print("🔹 Fetching expert details for ID: $id"); // ✅ Print when fetch starts
    isLoading.value = true;

    try {
      final token = box.read('token');
      if (token == null) {
        Get.snackbar("Error", "No token found. Please login first.");
        print("❌ No token found in storage"); // ✅ Print if token missing
        return;
      }
      print("🔑 Using token: $token"); // ✅ Print token (optional, remove in production)

      final response = await http.get(
        Uri.parse("http://kotiboxglobaltech.com/travel_app/api/experts/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      print("📦 Response status code: ${response.statusCode}");
      print("📄 Response body: ${response.body}"); // ✅ Print entire response

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true &&
          data["data"] != null) {
        expert.value = data["data"];
        print("✅ Expert data fetched successfully: ${expert.value}");
      } else {
        print("⚠️ Failed to fetch expert data: ${data["message"] ?? 'No message'}");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
      print("❌ Exception while fetching expert details: $e");
    } finally {
      isLoading.value = false;
      print("🔹 Fetch expert loading finished");
    }
  }

  String getLanguages() {
    if (expert.value["language"] != null) {
      List langs = expert.value["language"];
      String langsStr = langs.map((e) => e["value"].toString()).join(", ");
      print("🗣 Expert languages: $langsStr"); // ✅ Print languages
      return langsStr;
    }
    print("🗣 Expert has no languages listed");
    return "";
  }
}
