import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:travel_app2/app/constants/my_toast.dart';
import 'package:travel_app2/app/routes/app_pages.dart';

class OtpController extends GetxController {
  final RxInt secondsRemaining = 30.obs;
  final RxBool isLoading = false.obs;
  Timer? _timer;
  final box = GetStorage();

  // OTP input controllers
  final List<TextEditingController> otpControllers =
      List.generate(4, (_) => TextEditingController());
  final String mockOtp = "1234"; // ✅ Hardcoded OTP for now

  late String receivedToken; // ✅ Token from LoginController

  @override
  void onInit() {
    super.onInit();
    startTimer();

    // ✅ Get the token passed via Get.arguments
    receivedToken = Get.arguments?['token'] ?? '';
    debugPrint("📦 Received token from login: $receivedToken");
  }

  void startTimer() {
    secondsRemaining.value = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value == 0) {
        timer.cancel();
      } else {
        secondsRemaining.value--;
      }
    });
  }

  void resendOtp(BuildContext context) {
    CustomToast.showSuccess(context, "A new OTP has been sent.");
    startTimer();
  }

  void verify4DigitOtp(BuildContext context) async {
    String otp = otpControllers.map((e) => e.text.trim()).join();

    if (otp.length != 4) {
      CustomToast.showErrorHome(context, "Enter the complete 4-digit OTP");
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1)); // Simulate wait

    isLoading.value = false;

    if (otp == mockOtp) {
      /// ✅ Save token received from login

      box.write('token', receivedToken); // ✅ Save the real token

      debugPrint("✅ Token saved: ${box.read('token')}");
      CustomToast.showSuccess(context, 'Login Successful');
      Get.offAllNamed(Routes.DASHBOARD);
    } else {
      CustomToast.showErrorHome(context, "Incorrect OTP, try again.");
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    for (var c in otpControllers) {
      c.dispose();
    }
    super.onClose();
  }
}
