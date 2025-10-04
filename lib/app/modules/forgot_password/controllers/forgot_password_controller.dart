import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app2/app/constants/my_toast.dart';
import 'package:travel_app2/app/services/api_service.dart';

class ForgotPasswordController extends GetxController {
  final emailOrPhoneController = TextEditingController();
  final isLoading = false.obs;

  final ApiService apiService = Get.find<ApiService>();

void sendOtp() async {
  final input = emailOrPhoneController.text.trim();

  if (input.isEmpty) {
    CustomToast.showErrorHome(Get.context!, "Please enter your email or mobile number");
    return;
  }

  if (!_isValidEmail(input)) {
    CustomToast.showErrorHome(Get.context!, "Please enter a valid email");
    return;
  }

  isLoading.value = true;

  try {
    final response = await apiService.forgotPassword(input);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      CustomToast.showSuccess(Get.context!, data['message'] ?? "OTP sent successfully");
      Get.toNamed("/reset-password", arguments: {"input": input}); // 👈 Go to Reset Password screen
    } else {
      CustomToast.showError(Get.context!, data['message'] ?? "Failed to send OTP");
    }
  } catch (e) {
    CustomToast.showError(Get.context!, "Something went wrong. Please try again.");
    debugPrint("ForgotPassword Error: $e");
  } finally {
    isLoading.value = false;
  }
}

  bool _isValidEmail(String input) {
    return GetUtils.isEmail(input);
  }

  @override
  void onClose() {
    emailOrPhoneController.dispose();
    super.onClose();
  }
}
