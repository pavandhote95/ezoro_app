import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'dart:async';

class ExpertUserProfileController extends GetxController {
  var isLoading = false.obs;
  var profileData = <String, dynamic>{}.obs; // RxMap

  final box = GetStorage();
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    fetchExpertUserProfile();

    // Poll every 5 seconds to get latest ratings
    _timer = Timer.periodic(Duration(seconds: 5), (_) {
      fetchExpertUserProfile();
    });
  }

  @override
  void onClose() {
    _timer?.cancel(); // Cancel timer when controller is disposed
    super.onClose();
  }

  Future<void> fetchExpertUserProfile() async {
    try {
      isLoading.value = true;
      final token = box.read('token') ?? "";
   

      final response = await http.get(
        Uri.parse(
            "https://kotiboxglobaltech.com/travel_app/api/expert-user-details"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      // print("📩 API Status Code: ${response.statusCode}");
      // print("📩 API Raw Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["status"] == true && data["data"] != null) {
          // Force cast to Map<String,dynamic>
          final Map<String, dynamic> newData =
          Map<String, dynamic>.from(data["data"]);

          // Make ratings reactive
          newData["ratings"] = RxList(newData["ratings"] ?? []);

          profileData.value = newData;
          profileData.refresh();
          // print("🎯 Profile Data Updated: ${profileData.value}");
        } else {
       
    
        }
      } else {
     
      }
    } catch (e) {

  
    } finally {
      isLoading.value = false;
    }
  }

}
