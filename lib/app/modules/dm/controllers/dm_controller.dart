import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:travel_app2/app/modules/dm/views/user_model.dart';

class DmController extends GetxController {
  final box = GetStorage();

  RxList<UserModel> users = <UserModel>[].obs;
  RxList<UserModel> travellers = <UserModel>[].obs; // Travellers list
  RxBool isLoading = true.obs;
  RxBool isTravellersLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
    fetchTravellers(); // Fetch travellers dynamically
  }

  /// Fetch regular users
  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      final token = box.read('token');
      if (token == null) {
        Get.snackbar('Error', 'Auth token not found');
        return;
      }

      final url = 'https://kotiboxglobaltech.com/travel_app/api/chat/users';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        if (jsonBody['status'] == true) {
          final List data = jsonBody['data'];
          users.value = data.map((e) => UserModel.fromJson(e)).toList();
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch chat users');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch Travellers (Experts)
  Future<void> fetchTravellers() async {
    try {
      isTravellersLoading.value = true;
      final token = box.read('token');
      if (token == null) {
        Get.snackbar('Error', 'Auth token not found');
        return;
      }

      final url = 'https://kotiboxglobaltech.com/travel_app/api/chat/expert-users';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        if (jsonBody['status'] == true) {
          final List data = jsonBody['data'];
          travellers.value = data.map((e) => UserModel.fromJson(e)).toList();
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch travellers');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isTravellersLoading.value = false;
    }
  }
}
