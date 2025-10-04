import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:travel_app2/app/constants/api_url.dart';

class TalkToTravellersChatController extends GetxController {
  var messages = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isSending = false.obs;
  var selectedRating = 0.obs;

  final ScrollController scrollController = ScrollController();
  final box = GetStorage();

  late int travellerId;
  late String travellerName;
  late String? travellerImage;
  late int myUserId;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>;
    travellerId = args["travellerId"];
    travellerName = args["travellerName"];
    travellerImage = args["travellerImage"];
    myUserId = box.read("user_id") ?? 0;

    // Scroll whenever messages update
    ever(messages, (_) => scrollToLastMessage());

    fetchChat();
  }

  void scrollToLastMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }


  Future<void> fetchChat() async {
    try {
      isLoading.value = true;
      final token = box.read('token') ?? '';

      final response = await http.post(
        Uri.parse(ApiUrls.fetchChatMessages),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        body: {
          "receiver_id": travellerId.toString(),
        },
      );
      print("🔹 API => ${ApiUrls.fetchChatMessages}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["status"] == true) {
          messages.value = List<Map<String, dynamic>>.from(data["data"]);

          // ✅ Auto-scroll to last message
          scrollToLastMessage();

          // Show rating dialog if last message is system
          if (messages.isNotEmpty && box.read("user_type") == "user") {
            final lastMsg = messages.last;
            if (lastMsg["message_type"] == "system" &&
                (lastMsg["message"] ?? "").contains("rate your experience")) {
              _showRatingDialog();
            }
          }
        }
      }
    } catch (e) {
      print("❌ Error fetching chat: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessageToExpert({
    required int receiverId,
    required String message,
    String messageType = "text",
  }) async {
    if (message.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Message cannot be empty");
      return;
    }

    try {
      isSending.value = true;
      final token = box.read('token');
      if (token == null) {
        Fluttertoast.showToast(msg: "Please login first");
        return;
      }

      messages.add({
        "sender_id": myUserId,
        "receiver_id": receiverId,
        "message": message,
        "message_type": messageType,
        "created_at": DateTime.now().toIso8601String(),
      });
      Future.delayed(const Duration(milliseconds: 100), scrollToLastMessage);
      scrollToLastMessage();

      //end message to backend
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiUrls.sendMessage),
      );
      request.fields.addAll({
        'receiver_id': receiverId.toString(),
        'message': message,
        'message_type': messageType,
      });
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      final response = await request.send();
      final responseString = await response.stream.bytesToString();
      final data = jsonDecode(responseString);

      if (response.statusCode == 201 && data["status"] == true) {
        // ✅ Fetch updated messages from server
        await fetchChat();
        print("send msg to expert ${data}");
      } else {
        Fluttertoast.showToast(msg: data["message"] ?? "Failed to send message");
      }

    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to send message");
      print("❌ Error sending message: $e");
    } finally {
      isSending.value = false;
    }
  }


  Future<void> endChat() async {
    try {
      final token = box.read("token");
      if (token == null) {
        Fluttertoast.showToast(msg: "Please login again");
        return;
      }

      final response = await http.post(
        Uri.parse(ApiUrls.endChat),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        body: {
          "user_id": travellerId.toString(),
        },
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["status"] == true) {
        Fluttertoast.showToast(msg: data["message"] ?? "Chat ended successfully");

        final userTypeFromApi = data["data"]?["chat"]?["user_type"] ?? "";
        if (userTypeFromApi == "user") {
          _showRatingDialog();
        }
      } else {
        Fluttertoast.showToast(msg: data["message"] ?? "Failed to end chat");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error ending chat");
      print("❌ Error ending chat: $e");
    }
  }

  Future<void> submitRating(int rating) async {
    try {
      final token = box.read("token");
      if (token == null) {
        Fluttertoast.showToast(msg: "Please login again");
        return;
      }

      final response = await http.post(
        Uri.parse("https://kotiboxglobaltech.com/travel_app/api/add-rating/experts"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        body: {
          "expert_id": travellerId.toString(),
          "rating": rating.toString(),
        },
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data["status"] == true) {
        Fluttertoast.showToast(msg: data["message"] ?? "Thanks for your rating!");
      } else {
        Fluttertoast.showToast(msg: data["message"] ?? "Failed to submit rating");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error submitting rating");
      print("❌ Error submitting rating: $e");
    }
  }

  void _showRatingDialog() {
    selectedRating.value = 0;

    Get.dialog(
      Center(
        child: SizedBox(
          width: Get.width * 0.95,
          child: AlertDialog(
            title: const Text("⭐ Rate your Experience"),
            content: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Please give a rating for your chat."),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: List.generate(
                    5,
                        (index) => IconButton(
                      icon: Icon(
                        index < selectedRating.value
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.orange,
                        size: 36,
                      ),
                      onPressed: () {
                        selectedRating.value = index + 1;
                      },
                    ),
                  ),
                ),
              ],
            )),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text("Later"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedRating.value == 0) {
                    Fluttertoast.showToast(msg: "Please select a rating first");
                    return;
                  }
                  Get.back();
                  submitRating(selectedRating.value);
                },
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
