import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:travel_app2/app/routes/app_pages.dart';

class ResetPasswordController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;

  final String baseUrl = 'https://kotiboxglobaltech.com/travel_app/api';

Future<void> resetPassword() async {
  final email = emailController.text.trim();
  final password = passwordController.text.trim();

  debugPrint('⏳ Attempting reset with:');
  debugPrint('📧 Email: $email');
  debugPrint('🔑 Password: $password');

  if (email.isEmpty || password.isEmpty) {
    debugPrint('⚠️ Validation failed: Email or Password is empty');
    Fluttertoast.showToast(
      msg: "Please enter both email and password",
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      gravity: ToastGravity.BOTTOM,
    );
    return;
  }

  isLoading.value = true;

  final url = Uri.parse('$baseUrl/reset-password');
  final body = jsonEncode({
    "email": email,
    "password": password,
  });

  debugPrint('📡 Sending POST to: $url');
  debugPrint('📦 Payload: $body');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: body,
    );

    debugPrint('✅ Response Status: ${response.statusCode}');
    debugPrint('📨 Response Body: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['status'] == true) {
      debugPrint('🎉 Password reset successful: ${data['message']}');
      Fluttertoast.showToast(
        msg: data['message'] ?? "Password reset successfully",
        backgroundColor: Colors.green,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
      );
   Get.offAllNamed(Routes.LOGIN);
    } else {
      debugPrint('❌ Server error or failure: ${data['message']}');
      Fluttertoast.showToast(
        msg: data['message'] ?? "Something went wrong",
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
      );
    }
  } catch (e) {
    debugPrint('🔥 Exception: $e');
    Fluttertoast.showToast(
      msg: "Failed to reset password: $e",
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      gravity: ToastGravity.BOTTOM,
    );
  } finally {
    isLoading.value = false;
    debugPrint('🔚 Request completed');
  }
}
}