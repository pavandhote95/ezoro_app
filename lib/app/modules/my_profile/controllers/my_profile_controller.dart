import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:travel_app2/app/constants/my_toast.dart';
import 'package:travel_app2/app/routes/app_pages.dart';
import 'package:travel_app2/app/services/api_service.dart';

class MyProfileController extends GetxController {
  final box = GetStorage();
  final ApiService apiService = Get.find<ApiService>();

  final RxString username = ''.obs;
  final RxString firstname = ''.obs;
  final RxString role = ''.obs;
  final RxString profileImage = ''.obs;

  final RxInt totalPosts = 0.obs;
  final RxInt totalAnswers = 0.obs;
  final RxList<Map<String, dynamic>> userPosts = <Map<String, dynamic>>[].obs;

  final isLoading = false.obs;

  // Cache for passing to EditProfile
  Map<String, dynamic> cachedProfileData = {};

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }
  
  Future<void> deletePost(int postId) async {
    try {
      isLoading.value = true;

      final token = box.read('token') ?? ''; // Read token from GetStorage

      final response = await http.post(
        Uri.parse('https://kotiboxglobaltech.com/travel_app/api/post-delete'),
        headers: {
          'Authorization': 'Bearer $token', // send token in headers
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'id': postId.toString()},
      );

      final data = json.decode(response.body);

      if (data['status'] == true) {
        Get.snackbar("Success", "Post deleted successfully",
            snackPosition: SnackPosition.BOTTOM);
        userPosts.removeWhere((post) => post['id'] == postId);
      } else {
        Get.snackbar("Error", data['message'] ?? "Failed to delete post",
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> fetchProfile() async {
    final token = box.read('token');
    final userId = box.read('userId');

    if (token == null || userId == null) return;

    try {
      final response = await apiService.getProfileById(token, userId);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        final user = data['data'];

        username.value = user['name'] ?? '';
        firstname.value = user['first_name'] ?? '';
        role.value = user['role'] ?? 'Traveler';
        profileImage.value = user['image_url'] ?? '';

        cachedProfileData = user; // Store for EditProfileView

        if (user['posts'] != null) {
          userPosts.assignAll(
            List<Map<String, dynamic>>.from(user['posts']).map((post) {
              return {
                "id": post['id'] ?? 0,
                "title": post['question'] ?? "Untitled",
                "description": post['location'] ?? "",
                "image": post['image'] ?? "",
                "likes_count": post['likes_count'] ?? 0,
                "dislikes_count": post['dislikes_count'] ?? 0,
                "is_liked": post['is_liked'] ?? 0,
                "is_disliked": post['is_disliked'] ?? 0,
                "images": post['images'] ?? [],
              };
            }).toList(),
          );
          totalPosts.value = userPosts.length;
        }
      } else {
        CustomToast.showError(Get.context!, data['message'] ?? 'Failed to load profile');
      }
    } catch (e) {
      CustomToast.showError(Get.context!, 'Profile fetch error: $e');
    }
  }
void logoutUser() async {
  final token = box.read('token');
  if (token == null) {
    // Already logged out
    Get.offAllNamed(Routes.LOGIN);
    return;
  }

  isLoading.value = true;

  try {
    final response = await apiService.logoutUser(token);

    if (response.statusCode == 200) {
      // Clear all storage
      await box.erase();

      // Show toast
      CustomToast.showSuccess(Get.context!, 'Logout successful');

      // Navigate to login safely
      Get.offAllNamed(Routes.LOGIN);
    } else {
      CustomToast.showError(
        Get.context!, 
        'Logout failed: ${response.statusCode}'
      );
    }
  } catch (e) {
    CustomToast.showError(Get.context!, 'Logout error: $e');
  } finally {
    isLoading.value = false;
  }
}

}