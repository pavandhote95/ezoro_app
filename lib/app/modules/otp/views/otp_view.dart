import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import 'package:travel_app2/app/constants/custom_button.dart';
import 'package:travel_app2/app/modules/phone_login/controllers/phone_login_controller.dart';

import '../controllers/otp_controller.dart';

class OtpView extends StatelessWidget {
  final controller = Get.find<PhoneAuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller.otpController,
              decoration: const InputDecoration(
                labelText: "Enter OTP",
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Obx(() => controller.isLoading.value
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: controller.verifyOtp,
                    child: const Text("Verify OTP"),
                  )),
          ],
        ),
      ),
    );
  }
}
