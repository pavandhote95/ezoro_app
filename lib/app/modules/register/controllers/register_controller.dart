import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:travel_app2/app/constants/my_toast.dart';
import 'package:travel_app2/app/services/api_service.dart';
import 'package:travel_app2/app/routes/app_pages.dart';

class RegisterController extends GetxController {
  final nameController = TextEditingController();
  final emailOrPhoneController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;

  final ApiService _apiService = Get.find<ApiService>();

  void register() async {
    String name = nameController.text.trim();
    String emailOrPhone = emailOrPhoneController.text.trim();
    String password = passwordController.text.trim();

    debugPrint("Name: $name");
    debugPrint("Email or Phone: $emailOrPhone");
    debugPrint("Password: $password");

    if (name.isEmpty || emailOrPhone.isEmpty || password.isEmpty) {
    CustomToast.showErrorHome(Get.context!,'Please fill all fields');
      return;
    }

    bool isEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailOrPhone);
    bool isMobile = RegExp(r'^\d{10}$').hasMatch(emailOrPhone);

    debugPrint("Is Email: $isEmail");
    debugPrint("Is Mobile: $isMobile");

    if (!isEmail && !isMobile) {
    CustomToast.showErrorHome(Get.context! ,'Enter a valid email or 10-digit phone number');
      return;
    }

    isLoading.value = true;

    final Map<String, dynamic> body = {
      "name": name,
      "email": isEmail ? emailOrPhone : "",
      "phone_number": isMobile ? emailOrPhone : "",
      "password": password,
      "password_confirmation": password
    };

    debugPrint("Request Body: ${jsonEncode(body)}");

    try {
      final response = await _apiService.registerUser(body);

      isLoading.value = false;

      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Raw Response: ${response.body}");

      Map<String, dynamic> responseData = {};
      try {
        responseData = jsonDecode(response.body);
        debugPrint("Decoded Response: $responseData");
      } catch (e) {
        Fluttertoast.showToast(msg: 'Invalid response format');
        debugPrint("JSON Decode Error: $e");
        return;
      }

      if (response.statusCode == 201) {
        debugPrint("Registration Successful: $responseData");
       
        // Fluttertoast.showToast(msg: "Registered Successfully");
        CustomToast.showSuccess(
         Get.context!,  "Registered Successfully",
    
        );

        Get.offAllNamed(Routes.LOGIN);
      } else {
        String errorMessage = responseData['message'] ?? 'Registration failed';

        CustomToast.showError(
          Get.context!, errorMessage,
        );
        debugPrint("Registration Failed: $errorMessage");
        debugPrint("API Error: $errorMessage");
      }
    } catch (e) {
      isLoading.value = false;
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
      debugPrint("API Call Exception: $e");
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailOrPhoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}