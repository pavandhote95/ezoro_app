import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:travel_app2/app/constants/app_color.dart';

class ChatWithExpertController extends GetxController {
  var messages = <Map<String, dynamic>>[].obs;
  var isSending = false.obs;
  var isLoading = false.obs;
  final box = GetStorage();
    var selectedRating = 0.obs;
  late int receiverId; // Store current receiverId for rating

  /// SEND MESSAGE
  Future<void> sendMessageToExpert({
    required int receiverId,
    required String message,
    String messageType = "text",
  }) async {
    if (message.trim().isEmpty) return;

    try {
      isSending.value = true;
      final token = box.read('token');
      if (token == null) {
        Fluttertoast.showToast(msg: "Please login first");
        return;
      }

      var headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://kotiboxglobaltech.com/travel_app/api/expert-messages/send'),
      );

      request.fields.addAll({
        'receiver_id': receiverId.toString(),
        'message': message,
        'message_type': messageType,
      });

      request.headers.addAll(headers);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var data = jsonDecode(responseBody);

      if (response.statusCode == 201 && data["status"] == true) {
        messages.add({
          "sender": "me",
          "message": message,
          "created_at": DateTime.now().toString(),
        });

        // Fetch messages and store receiverId
        await fetchMessagesusertoexpert(receiverId: receiverId);
      } else {
        Fluttertoast.showToast(
            msg: data["message"] ?? "Failed to send message");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error sending message: $e");
    } finally {
      isSending.value = false;
    }
  }
  
  
 Future<void> fetchMessagesusertoexpert({required int receiverId}) async {
    try {
      isLoading.value = true;

      final token = box.read('token');
      final userType = box.read('user_type');
      final userId = box.read('user_id');

      this.receiverId = receiverId; // ✅ Store receiverId for rating

      var url = Uri.parse(
        'https://kotiboxglobaltech.com/travel_app/api/expert-messages/get?receiver_id=$receiverId',
      );

      var response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["status"] == true) {
          final List<dynamic> messageList = data["data"] ?? [];

          messages.value = messageList.map<Map<String, dynamic>>((msg) {
            return {
              "sender": msg['sender_id'].toString() == userId.toString()
                  ? "me"
                  : "expert",
              "message": msg['message'] ?? "",
              "created_at": msg['created_at'] ?? "",
            };
          }).toList();

          if (messages.isNotEmpty) {
            final lastMsg = messages.last["message"]?.toString().trim() ?? "";
                if (lastMsg.contains("Thanks! Rated")) {
              final starMatch = RegExp(r'(\d+)★').firstMatch(lastMsg);
              final rating = starMatch != null ? int.tryParse(starMatch.group(1)!) : null;
              if (userType == "user") _showThanksDialog(rating);
            }

            if (userType == "user" &&
                lastMsg.contains("⭐ Your chat has ended.")) {
              Future.delayed(const Duration(milliseconds: 600), () {
                _showRatingDialog();
              });
            }
          }
        }
      } else {
        Fluttertoast.showToast(msg: "Failed to fetch messages");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching messages");
      print("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
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
 
  Future<void> submitRating(int rating) async {
    try {
      final token = box.read("token");

      if (token == null) {
        Fluttertoast.showToast(msg: "Please login again");
        return;
      }

      if (receiverId == 0) {
        Fluttertoast.showToast(msg: "Expert not selected");
        return;
      }

      final response = await http.post(
        Uri.parse(
            "https://kotiboxglobaltech.com/travel_app/api/add-rating/experts"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        body: {
          "expert_id": receiverId.toString(), // ✅ Use stored receiverId
          "rating": rating.toString(),
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data["status"] == true) {
        Fluttertoast.showToast(msg: "Thanks for your rating!");
      } else {
        Fluttertoast.showToast(
            msg: data["message"] ?? "Failed to submit rating");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error submitting rating");
      print("Error submitting rating: $e");
    }
  }

  // Add verifyPayment & _capturePayment methods here if needed


  /// VERIFY PAYMENT
  Future<void> verifyPayment({
    required String paymentId,
    required String expertId,
    String? amount,
  }) async {
    try {
      final token = box.read('token') ?? '';
      if (token.isEmpty) {
        Fluttertoast.showToast(msg: "Please login again.");
        return;
      }

      var headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      var request = http.Request(
        'POST',
        Uri.parse(
            'https://kotiboxglobaltech.com/travel_app/api/verify-payment-id'),
      );

      request.headers.addAll(headers);
      request.bodyFields = {
        'payment_id': paymentId,
        'expert_id': expertId,
      };

      var response = await request.send();
      var body = await response.stream.bytesToString();
      var data = jsonDecode(body);

      if (response.statusCode == 200 && data['status'] == true) {
        Fluttertoast.showToast(
          msg: "✅ ${data['message']}",
          backgroundColor: Colors.green.shade600,
          textColor: Colors.white,
        );
      } else if (data['message']
          .toString()
          .toLowerCase()
          .contains("authorized")) {
        Fluttertoast.showToast(
            msg: "⚠ Authorized, capturing...",
            backgroundColor: Colors.orange.shade600);
        if (amount != null) {
          await _capturePayment(paymentId, expertId, token, amount);
        }
      } else {
        Fluttertoast.showToast(
          msg: "❌ ${data['message']}",
          backgroundColor: Colors.red.shade600,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error verifying payment: $e");
    }
  }

  /// CAPTURE PAYMENT (fallback)
  Future<void> _capturePayment(
      String paymentId, String expertId, String token, String amount) async {
    try {
      var headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      var request = http.Request(
        'POST',
        Uri.parse(
            'https://kotiboxglobaltech.com/travel_app/api/capture-payment'),
      );

      request.headers.addAll(headers);
      request.bodyFields = {
        'payment_id': paymentId,
        'amount': (double.parse(amount) * 100).toInt().toString(),
      };

      var response = await request.send();
      var body = await response.stream.bytesToString();
      var data = jsonDecode(body);

      if (response.statusCode == 200 &&
          data['status'] == true &&
          data['payment']['status'] == 'captured') {
        Fluttertoast.showToast(
            msg: "✅ Payment captured successfully",
            backgroundColor: Colors.green.shade600);
      } else {
        Fluttertoast.showToast(
            msg: "❌ Failed to capture payment",
            backgroundColor: Colors.red.shade600);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error capturing payment: $e");
    }
  }
}