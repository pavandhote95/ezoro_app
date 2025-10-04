import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';


class ChatWithExpertController extends GetxController {
  var messages = <Map<String, dynamic>>[].obs;
  var isSending = false.obs;
  var isLoading = false.obs;

  final box = GetStorage();

  /// Send message to expert
  var lastErrorMessage = "".obs;

  Future<void> sendMessageToExpert({
    required int receiverId,
    required String message,
    String messageType = "text",
  }) async {
    lastErrorMessage.value = "";
    if (message.trim().isEmpty) {
      lastErrorMessage.value = "Message cannot be empty";
      return;
    }

    try {
      isSending.value = true;
      final token = box.read('token');
      if (token == null) {
        lastErrorMessage.value = "Please login first";
        return;
      }

      var headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://kotiboxglobaltech.com/travel_app/api/expert-messages/send'),
      );

      request.fields.addAll({
        'receiver_id': receiverId.toString(),
        'message': message,
        'message_type': messageType,
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();
      final data = jsonDecode(responseString);

      if (response.statusCode == 201 && data["status"] == true) {
        messages.add({
          "sender": "me",
          "message": message,
          "created_at": DateTime.now().toString(),
        });
      } else {
        if (box.read("user_type") == "user") {
          lastErrorMessage.value = data["message"] ?? "Failed to send message";
        }

      }
    } catch (e) {
      lastErrorMessage.value = "Failed to send message";
      print("❌ Error sending message: $e");
    } finally {
      isSending.value = false;
    }
  }


  /// Fetch messages between user and expert
  Future<void> fetchMessagesusertoexpert({required int receiverId}) async {
    try {
      isLoading.value = true;
      final token = box.read('token');

      var url = Uri.parse(
          'https://kotiboxglobaltech.com/travel_app/api/expert-messages/get?receiver_id=$receiverId');

      var response = await http.post(url, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["status"] == true && data["data"] != null) {
          List messagesList = data["data"];
          messages.value = messagesList.map<Map<String, dynamic>>((msg) {
            return {
              "sender": msg['sender_id'].toString() == box.read('user_id').toString()
                  ? "me"
                  : "expert",
              "message": msg['message'],
              "created_at": msg['created_at'],
            };
          }).toList();
        }
      } else {
        Fluttertoast.showToast(msg: "Failed to fetch messages");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching messages");
      print("❌ Error fetching messages: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Capture payment if authorized but not captured
  Future<void> _capturePayment(String paymentId, String expertId, String token, String amount) async {
    try {
      var headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      var bodyFields = {
        'payment_id': paymentId,
        'amount': (double.parse(amount) * 100).toInt().toString(), // Amount in paise
      };

      var request = http.Request(
        'POST',
        Uri.parse('https://kotiboxglobaltech.com/travel_app/api/capture-payment'), // Update with actual endpoint
      );

      request.headers.addAll(headers);
      request.bodyFields = bodyFields;

      http.StreamedResponse response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print("📥 Capture Response: $responseBody");

      if (response.statusCode == 200) {
        var data = jsonDecode(responseBody);
        if (data['status'] == true && data['payment']['status'] == 'captured') {
          Fluttertoast.showToast(
            msg: "✅ Payment captured successfully",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green.shade600,
            textColor: Colors.white,
          );
          // Re-verify payment after capture
          await verifyPayment(paymentId: paymentId, expertId: expertId);
        } else {
          Fluttertoast.showToast(
            msg: "❌ Failed to capture payment: ${data['message'] ?? 'Unknown error'}",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red.shade600,
            textColor: Colors.white,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "❌ Capture failed: ${response.reasonPhrase ?? 'Unknown error'}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red.shade600,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      print("🔥 Error capturing payment: $e");
      Fluttertoast.showToast(
        msg: "🔥 Error capturing payment: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade600,
        textColor: Colors.white,
      );
    }
  }

  /// Verify payment
Future<void> verifyPayment({
  required String paymentId,
  required String expertId,
  String? amount, // Optional amount for capture
}) async {
  try {
    final token = box.read('token') ?? '';
    if (token.isEmpty) {
      Fluttertoast.showToast(
        msg: "❌ Token missing. Please login again.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade600,
        textColor: Colors.white,
      );
      return;
    }

    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    var bodyFields = {
      'payment_id': paymentId.trim(),
      'expert_id': expertId.trim(),
    };

    var request = http.Request(
      'POST',
      Uri.parse('https://kotiboxglobaltech.com/travel_app/api/verify-payment-id'),
    );

    request.headers.addAll(headers);
    request.bodyFields = bodyFields;

    http.StreamedResponse response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final data = jsonDecode(responseBody);

    // Successful verification
    if (response.statusCode == 200) {
      if (data['status'] == true) {
        Fluttertoast.showToast(
          msg: "✅ ${data['message'] }",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green.shade600,
          textColor: Colors.white,
        );
      } 
      // Authorized but not captured
      else if (data['message'] != null &&
          data['message'].toString().toLowerCase().contains("authorized")) {
        Fluttertoast.showToast(
          msg: "⚠ ${data['message']}. Attempting to capture...",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.orange.shade600,
          textColor: Colors.white,
        );
        // Call capture payment function (optional)
        if (amount != null) {
          await _capturePayment(paymentId, expertId, token, amount);
        }
      } 
      // Other failures
      else {
        Fluttertoast.showToast(
          msg: "❌ ${data['message'] }",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red.shade600,
          textColor: Colors.white,
        );
      }
    } 
    // Payment required / not captured (402)
    else if (response.statusCode == 402) {
      Fluttertoast.showToast(
        msg: "❌ ${data['message']}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade600,
        textColor: Colors.white,
      );
    } 
    // Other server errors
    else {
      Fluttertoast.showToast(
        msg: "❌ Server error: ${response.statusCode}, Reason: ${response.reasonPhrase ?? 'Unknown'}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade600,
        textColor: Colors.white,
      );
    }
  } catch (e) {
    Fluttertoast.showToast(
      msg: "🔥 Error verifying payment: $e",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red.shade600,
      textColor: Colors.white,
    );
  }
}}

  var messages = <Map<String, dynamic>>[].obs;
  var isSending = false.obs;
  var isLoading = false.obs;

  final box = GetStorage();

  /// Send message to expert
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

      var headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://kotiboxglobaltech.com/travel_app/api/expert-messages/send'),
      );

      request.fields.addAll({
        'receiver_id': receiverId.toString(),
        'message': message,
        'message_type': messageType,
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();
      final data = jsonDecode(responseString);

      if (response.statusCode == 201 && data["status"] == true) {
        messages.add({
          "sender": "me",
          "message": message,
          "created_at": DateTime.now().toString(),
        });
        Fluttertoast.showToast(msg: "Message sent successfully");
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

  /// Fetch messages between user and expert
  Future<void> fetchMessagesusertoexpert({required int receiverId}) async {
    try {
      final token = box.read('token');

      var url = Uri.parse(
          'https://kotiboxglobaltech.com/travel_app/api/expert-messages/get?receiver_id=$receiverId');

      var response = await http.post(url, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["status"] == true && data["data"] != null) {
          List messagesList = data["data"];
          messages.value = messagesList.map<Map<String, dynamic>>((msg) {
            return {
              "sender": msg['sender_id'].toString() ==
                      box.read('user_id').toString()
                  ? "me"
                  : "expert",
              "message": msg['message'],
              "created_at": msg['created_at'],
            };
          }).toList();
        }
      } else {
        Fluttertoast.showToast(msg: "Failed to fetch messages");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching messages");
      print("❌ Error fetching messages: $e");
    }
  }

Future<void> verifyPayment({
  required String paymentId,
  required String expertId,
    String? amount, 

}) async {
  try {
    final token = box.read('token') ?? '';
    if (token.isEmpty) {
      Fluttertoast.showToast(
        msg: "❌ Token missing. Please login again.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade600,
        textColor: Colors.white,
      );
      return;
    }

    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    var bodyFields = {
      'payment_id': paymentId.trim(),
      'expert_id': expertId.trim(),
    };

    var request = http.Request(
      'POST',
      Uri.parse('https://kotiboxglobaltech.com/travel_app/api/verify-payment-id'),
    );

    request.headers.addAll(headers);
    request.bodyFields = bodyFields;

    http.StreamedResponse response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final data = jsonDecode(responseBody);
    print("responsecodeeeee${response.statusCode}");

    // Handle based on status code
    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: data['message'] ?? "✅ Payment verified successfully",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green.shade600,
        textColor: Colors.white,
      );
    } else if (response.statusCode == 402) {
      Fluttertoast.showToast(
      
        msg: data['message'] ,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange.shade600,
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: "❌ ${data['message'] ?? 'Something went wrong'}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade600,
        textColor: Colors.white,
      );
    }
  } catch (e) {
    Fluttertoast.showToast(
      msg: "🔥 Error verifying payment: $e",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red.shade600,
      textColor: Colors.white,
    );
  }
}