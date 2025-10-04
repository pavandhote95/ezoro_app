import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:travel_app2/app/modules/travellers/views/all_expert_chat_model.dart';

class TravellersController extends GetxController {
  var isLoading = false.obs;
  var travellers = <UserModel2>[].obs;

  final String apiUrl = "https://kotiboxglobaltech.com/travel_app/api/chat/expert-users";

  final box = GetStorage(); // GetStorage instance

  @override
  void onInit() {
    super.onInit();
    fetchTravellers();
  }

  void fetchTravellers() async {
    try {
      isLoading.value = true;

      // Get token from GetStorage
      String token = box.read('token') ?? '';
      Map<String, String> headers = {};
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      print("API Response Status: ${response.statusCode}");
      print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == true) {
          travellers.value = (data['data'] as List)
              .map((json) => UserModel2.fromJson(json))
              .toList();

          for (var t in travellers) {
            print("Traveller: ${t.name}, LastMsg: ${t.lastMessage}");
            print("Travellerid: ${t.userId}, LastMsg: ${t.lastMessage}");
          }
        } else {
          travellers.clear();
          print("API returned status=false");
        }
      } else {
        travellers.clear();
        print("Failed to fetch travellers: ${response.statusCode}");
      }
    } catch (e) {
      travellers.clear();
      print("Error fetching travellers: $e");
    } finally {
      isLoading.value = false;
    }
  }
  
}
