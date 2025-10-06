import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:travel_app2/app/modules/otp/views/otp_view.dart';
import 'package:travel_app2/app/routes/app_pages.dart';

class PhoneAuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var isLoading = false.obs;
  String verificationId = "";
 final GetStorage box = GetStorage();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  // 🔹 Step 1: Send OTP
  Future<void> sendOtp() async {
    String phone = phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      Get.snackbar("Error", "Enter a valid phone number");
      return;
    }

    print("📤 Sending OTP to +91$phone");
    isLoading(true);

    await _auth.verifyPhoneNumber(
      phoneNumber: "+91$phone",
      timeout: const Duration(seconds: 60),

      verificationCompleted: (PhoneAuthCredential credential) async {
        print("✅ Auto verification completed");

        try {
          UserCredential userCred = await _auth.signInWithCredential(credential);
          User? user = userCred.user;

          if (user != null) {
            // ✅ Corrected line
       String idToken = (await user.getIdToken())!;
            print("🔐 Firebase ID Token: $idToken");

            await _loginWithBackend(idToken);
          }
        } catch (e) {
          print("❌ Auto verify error: $e");
        }
      },

      verificationFailed: (FirebaseAuthException e) {
        isLoading(false);
        Get.snackbar("Error", e.message ?? "Verification failed");
        print("❌ Verification failed: ${e.message}");
      },

      codeSent: (String verId, int? resendToken) {
        verificationId = verId;
        isLoading(false);
        print("📩 OTP sent successfully to +91$phone");
        Get.to(() => OtpView());
      },

      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
        print("⏳ Auto retrieval timeout");
      },
    );
  }

  // 🔹 Step 2: Verify OTP manually
Future<void> verifyOtp() async {
  String otp = otpController.text.trim();
  if (otp.isEmpty || otp.length < 6) {
    Get.snackbar("Error", "Enter a valid OTP");
    return;
  }

  print("📤 Verifying OTP: $otp");
  isLoading(true);

  try {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    UserCredential userCred = await _auth.signInWithCredential(credential);
    User? user = userCred.user;

    if (user != null) {
      String idToken = await user.getIdToken() ?? '';
      if (idToken.isEmpty) {
        isLoading(false);
        Get.snackbar("Error", "Failed to retrieve ID token");
        return;
      }
      print("🔐 Firebase ID Token: $idToken");
      await _loginWithBackend(idToken);
    } else {
      isLoading(false);
      Get.snackbar("Error", "User not found");
    }
  } catch (e) {
    isLoading(false);
    print("❌ OTP Verification Failed: $e");
    Get.snackbar("Error", "Invalid OTP or verification failed");
  }
}
Future<void> _loginWithBackend(String idToken) async {
  const String apiUrl = "https://kotiboxglobaltech.com/travel_app/api/login-with-phone";
  print("🌐 Calling backend API: $apiUrl");

  try {
    isLoading(true);

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "idToken": idToken,
      }),
    );

    print("📡 Response Code: ${response.statusCode}");
    print("📦 Response Body: ${response.body}");

    isLoading(false);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data['status'] == true) {
        final token = data['token'];
        final userData = data['user'] ?? {}; // ✅ Correct key
        final int userId = userData['id'] ?? 0;
        final int userPoints = userData['user_points'] ?? 0;
        final String userType = userData['user_type'] ?? 'user';

        if (token != null) {
          // Save token and user info in storage
          box.write('token', token);
          box.write('userId', userId);
          box.write('userPoints', userPoints);
          box.write('isLoggedIn', true);
          box.write('user_type', userType);
          box.write('user_points', userPoints);

          debugPrint("📦 Tokenppppp: $token");
          debugPrint("🆔 UserId: $userId");
          debugPrint("⭐ UserPoints: $userPoints");
          debugPrint("👤 UserType: $userType");

          // ✅ Save FCM Device Token if needed


          Get.snackbar("Success", data['message'] ?? "Login successful!");
          Get.offAllNamed(Routes.DASHBOARD);
        } else {
          Get.snackbar("Error", "Token not found in response");
        }
      } else {
        Get.snackbar("Error", data['message'] ?? "Login failed");
      }
    } else {
      Get.snackbar("Error", "Server error: ${response.statusCode}");
    }
  } catch (e) {
    isLoading(false);
    print("❌ Backend API Error: $e");
    Get.snackbar("Error", "Something went wrong while contacting server");
  }
}

}