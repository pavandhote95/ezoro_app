import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:travel_app2/app/constants/api_url.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import 'package:travel_app2/app/modules/chat_with_expert/controllers/chat_with_expert_controller.dart';

class TalkToTravellersChatController extends GetxController {
  var messages = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isSending = false.obs;
  var selectedRating = 0.obs;

  final ScrollController scrollController = ScrollController();
  final ChatWithExpertController controller = Get.put(ChatWithExpertController());
  final box = GetStorage();

  Timer? _chatRefreshTimer;

  late int travellerId;
  late String travellerName;
  late String? travellerImage;
  late int myUserId;
  late String userType;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>? ?? {};
    travellerId = args["travellerId"] ?? 0;
    travellerName = args["travellerName"] ?? "";
    travellerImage = args["travellerImage"];
    myUserId = box.read("user_id") ?? 0;
    userType = box.read("user_type") ?? "user";

    _startAutoChatRefresh();
    ever(messages, (_) => scrollToLastMessage());
  }

  @override
  void onClose() {
    _chatRefreshTimer?.cancel();
    super.onClose();
  }

  void _startAutoChatRefresh() {
    fetchChat();
    _chatRefreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      fetchChat();
    });
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

  /// ✅ Fetch chat messages between user & traveller
  Future<void> fetchChat() async {
    try {
      final token = box.read('token') ?? '';
      if (token.isEmpty) return;

      final response = await http.post(
        Uri.parse(ApiUrls.fetchChatMessages),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        body: {"receiver_id": travellerId.toString()},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["status"] == true) {
          final List<Map<String, dynamic>> fetchedMessages =
              List<Map<String, dynamic>>.from(data["data"]).map((msg) {
            String createdAt = msg["created_at"] ?? DateTime.now().toUtc().toIso8601String();
            try {
              DateTime.parse(createdAt);
            } catch (_) {
              createdAt = DateTime.now().toUtc().toIso8601String();
            }
            return {...msg, "created_at": createdAt};
          }).toList();

          // ✅ Only update if message count changes
          if (messages.length != fetchedMessages.length) {
            messages.assignAll(fetchedMessages);

            final lastMsg = fetchedMessages.isNotEmpty
                ? (fetchedMessages.last["message"]?.toString() ?? "")
                : "";

            // 🔹 When chat ended -> show rating dialog for user
            if (lastMsg.contains("⭐ Your chat has ended") && userType == "user") {
              _showRatingDialog();
            }

            // 🔹 When expert thanks user for rating
            if (lastMsg.contains("Thanks! Rated")) {
              final starMatch = RegExp(r'(\d+)★').firstMatch(lastMsg);
              final rating = starMatch != null ? int.tryParse(starMatch.group(1)!) : null;
              if (userType == "user") _showThanksDialog(rating);
            }
          }
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching chat: $e");
    }
  }

  /// ✅ Send message
  Future<void> sendMessageToExpert({
    required int receiverId,
    required String message,
    String messageType = "text",
  }) async {
    if (message.trim().isEmpty) return;

    try {
      isSending.value = true;
      final token = box.read('token');
          print("Sending message to receiverId: $receiverId");
      if (token == null) {
        Fluttertoast.showToast(msg: "Please login first");
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://kotiboxglobaltech.com/travel_app/api/expert-messages/send'),
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

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var data = jsonDecode(responseBody);

      if (response.statusCode == 201 && data["status"] == true) {
        messages.add({
          "sender_id": myUserId,
          "receiver_id": receiverId,
          "message": message,
          "created_at": DateTime.now().toString(),
        });
        // controller.fetchMessagesusertoexpert(receiverId: receiverId);
      } else {
        Fluttertoast.showToast(msg: data["message"] ?? "Failed to send message");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error sending message: $e");
    } finally {
      isSending.value = false;
    }
  }

  /// ✅ End chat and request rating
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

      // ✅ Call fetchMessagesusertoexpert from ChatWithExpertController
      controller.fetchMessagesusertoexpert(receiverId: travellerId);
      print("ha sahi h ");
      print("${travellerId}trrrrr");

      // if (userType == "user") _showRatingDialog();
    } else {
      Fluttertoast.showToast(msg: data["message"] ?? "Failed to end chat");
    }
  } catch (e) {
    Fluttertoast.showToast(msg: "Error ending chat");
    debugPrint("❌ Error ending chat: $e");
  }
}

  /// ✅ Submit rating to backend
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
        Fluttertoast.showToast(msg: "Thanks for your rating!");
      } else {
        Fluttertoast.showToast(msg: data["message"] ?? "Failed to submit rating");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error submitting rating");
      debugPrint("❌ Error submitting rating: $e");
    }
  }

  /// ⭐ Rating dialog
 void _showRatingDialog() {
    selectedRating.value = 0;
    Get.dialog(
      Center(
        child: Container(
          width: Get.width * 0.85,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.buttonBg, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("⭐ Rate your Experience",
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              Text("Please rate your chat experience.",
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70)),
              const SizedBox(height: 16),
              Obx(() => Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4,
                    children: List.generate(
                      5,
                      (index) => IconButton(
                        icon: Icon(
                          index < selectedRating.value ? Icons.star : Icons.star_border,
                          color: Colors.orangeAccent,
                          size: 36,
                        ),
                        onPressed: () => selectedRating.value = index + 1,
                      ),
                    ),
                  )),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text("Later", style: GoogleFonts.poppins(color: Colors.white70)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonBg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (selectedRating.value == 0) {
                        Fluttertoast.showToast(msg: "Please select a rating");
                        return;
                      }
                      Get.back();
                      submitRating(selectedRating.value);
                    },
                    child: Text("Submit",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
 
  /// ⭐ Thank-You Dialog after rating received
  void _showThanksDialog(int? rating) {
    Get.dialog(
      Center(
        child: Container(
          width: Get.width * 0.7,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.buttonBg, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: AppColors.buttonBg, size: 40),
              const SizedBox(height: 10),
              Text("Thanks for rating!",
                  style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (rating != null)
                Wrap(
                  spacing: 4,
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.orangeAccent,
                      size: 26,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () => Get.back(),
                child: Text("OK", style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
