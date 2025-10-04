import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app2/app/modules/otp/views/otp_view.dart';

class PhoneAuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var isLoading = false.obs;
  String verificationId = "";

  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  // ✅ Step 1: Send OTP
  Future<void> sendOtp() async {
    String phone = phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      print("⚠️ Invalid phone number entered: $phone");
      Get.snackbar("Error", "Enter a valid phone number");
      return;
    }

    print("📤 Sending OTP to: +91$phone");

    isLoading(true);
    await _auth.verifyPhoneNumber(
      phoneNumber: "+91$phone", // ✅ India ke liye +91
      timeout: const Duration(seconds: 60),

      verificationCompleted: (PhoneAuthCredential credential) async {
        print("✅ Auto verification completed with credential: $credential");
        try {
          await _auth.signInWithCredential(credential);
          print("🎉 Auto login successful for phone: +91$phone");
          Get.snackbar("Success", "Phone verified automatically!");
        } catch (e) {
          print("❌ Auto verification error: $e");
        }
      },

      verificationFailed: (FirebaseAuthException e) {
        isLoading(false);
        print("❌ Verification failed for +91$phone");
        print("📄 Error Code: ${e.code}");
        print("📄 Error Message: ${e.message}");
        Get.snackbar("Error", e.message ?? "Verification failed");
      },

      codeSent: (String verId, int? resendToken) {
        verificationId = verId;
        isLoading(false);
        print("📩 OTP code sent to +91$phone");
        print("🆔 VerificationId: $verificationId");
        print("🔄 Resend Token: $resendToken");
        Get.to(() => OtpView());
      },

      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
        print("⏳ Auto retrieval timeout, VerificationId: $verificationId");
      },
    );
  }

  // ✅ Step 2: Verify OTP
  Future<void> verifyOtp() async {
    String otp = otpController.text.trim();
    if (otp.isEmpty || otp.length < 6) {
      print("⚠️ Invalid OTP entered: $otp");
      Get.snackbar("Error", "Enter valid OTP");
      return;
    }

    print("📤 Verifying OTP: $otp with VerificationId: $verificationId");

    isLoading(true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);
      isLoading(false);

      print("🎉 OTP verification successful, login complete!");
      Get.snackbar("Success", "Phone login successful!");
      Get.offAllNamed('/dashboard'); // ✅ Dashboard route
    } catch (e) {
      isLoading(false);
      print("❌ OTP verification failed: $e");
      Get.snackbar("Error", "Invalid OTP: $e");
    }
  }
}
