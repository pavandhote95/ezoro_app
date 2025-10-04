import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:travel_app2/app/constants/my_toast.dart';
import 'package:travel_app2/app/modules/otp_verification/views/otp_verification_view.dart';
import 'package:travel_app2/app/modules/phone_login/views/phone_login_view.dart';
import 'package:travel_app2/app/routes/app_pages.dart';
import 'package:travel_app2/app/services/api_service.dart';

class LoginController extends GetxController {
  // Common
  final isLoading = false.obs;
  final apiService = Get.find<ApiService>();
  final box = GetStorage();
  var isGoogleLoading = false.obs;

  // Email/Password Controllers
  final emailOrPhoneController = TextEditingController();
  final passwordController = TextEditingController();

  // Phone OTP Controllers
  final phoneController = TextEditingController();
  List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());
  List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());

  var secondsRemaining = 30.obs;

  /// ✅ Login API → Dashboard → Save Token
  void login() async {
    final input = emailOrPhoneController.text.trim();
    final password = passwordController.text.trim();

    if (input.isEmpty || password.isEmpty) {
      CustomToast.showErrorHome(Get.context!, 'Please enter all fields');
      return;
    }

    isLoading.value = true;

    try {
      final bool isPhone = RegExp(r'^\d+$').hasMatch(input);

      final response = await apiService.loginUser(
        email: isPhone ? null : input,
        phoneNumber: isPhone ? input : null,
        password: password,
      );

      final data = jsonDecode(response.body);
      isLoading.value = false;

      if (response.statusCode == 200) {
        final token = data['token'];
        final userData = data['data'] ?? {};
        final int userId = userData['id'] ?? 0;
        final int userPoints = userData['user_points'] ?? 0;
        final String userType = userData['user_type'] ?? 'user'; // ✅ get user_type

        if (token != null) {
          // Save token, userId, userPoints
          box.write('token', token);
          box.write('userId', userId);
          box.write('userPoints', userPoints);
          box.write('isLoggedIn', true);
              box.write('user_type', userType); // ✅ save user_type

          debugPrint("📦 Token: $token");
          debugPrint("🆔 UserId: $userId");
          debugPrint("⭐ UserPoints: $userPoints");
    debugPrint("👤 UserType: $userType"); 
          CustomToast.showSuccess(Get.context!, 'Login Successful');

          // ✅ Save FCM Device Token after login
          await saveDeviceToken(userId);

          // ✅ Go to Dashboard
          Get.offAllNamed(Routes.DASHBOARD);
        } else {
          CustomToast.showError(Get.context!, 'Token not found');
        }
  
      } else {
        CustomToast.showError(Get.context!, data['message'] ?? 'Login Failed');
      }
    } catch (e) {
      isLoading.value = false;
      debugPrint("Login Exception: $e");
      CustomToast.showError(Get.context!, 'Something went wrong. Try again.');
    }
  }

  /// ✅ Save Device Token API
// 👈 add this import at top

/// ✅ Save Device Token API
Future<void> saveDeviceToken(int userId) async {
  try {
    String? deviceToken = await FirebaseMessaging.instance.getToken();
    String? token = box.read('token'); // ✅ read saved login token

    if (deviceToken == null || token == null) {
      debugPrint("⚠️ Device token or user token is null");
      return;
    }

    // 👇 detect device type
    String deviceType = Platform.isAndroid ? "android" : "ios";

    final url = Uri.parse("https://kotiboxglobaltech.com/travel_app/api/push/save-token");
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",   // ✅ auth header
        "Accept": "application/json",
      },
      body: {
        "user_id": userId.toString(),
        "device_token": deviceToken,
        "device_type": deviceType, // ✅ send device type
      },
    );

    debugPrint("📡 Save Token Response: ${response.body}");

    if (response.statusCode == 200) {
      debugPrint("✅ Device token saved successfully");
    } else {
      debugPrint("❌ Failed to save device token: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("🔥 Error saving device token: $e");
  }
}

  // ✅ Navigate to registration page
  void goToRegister() => Get.toNamed(Routes.REGISTER);

  // ✅ Navigate to Phone Login page
  void loginWithPhone() => Get.to(() => PhoneLoginView());

  // ✅ Send OTP
  void sendPhoneOtp() async {
    String phone = phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      Get.snackbar('Error', 'Enter a valid phone number');
      return;
    }

    isLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 2));
      isLoading(false);
      Get.to(() => OtpVerificationView(phoneNumber: phone));
    } catch (e) {
      isLoading(false);
      Get.snackbar('Error', e.toString());
    }
  }

  // ✅ Verify OTP
  void verifyOtp(String phone) async {
    String otp = otpControllers.map((e) => e.text).join();
    if (otp.length < 4) {
      Get.snackbar('Error', 'Enter complete OTP');
      return;
    }

    isLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 2));
      isLoading(false);

      CustomToast.showSuccess(Get.context!, 'Phone login successful');
      Get.toNamed(Routes.LOGIN);
    } catch (e) {
      isLoading(false);
      Get.snackbar('Error', e.toString());
    }
  }

  // ✅ Resend OTP
  void resendOtp() => sendPhoneOtp();

  /// ✅ Google Login
  Future<void> googleLogin() async {
    final _auth = FirebaseAuth.instance;
    final googleSignIn = GoogleSignIn();

    try {
      isGoogleLoading.value = true;

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        isGoogleLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      isGoogleLoading.value = false;

      if (user != null) {
        box.write('isLoggedIn', true);
        box.write('userEmail', user.email);
        box.write('userName', user.displayName);
        box.write('userUid', user.uid);

        debugPrint("✅ Google Login Successful");
        CustomToast.showSuccess(Get.context!, "Google Login Successful");

        Get.offAllNamed(Routes.LOGIN);
      } else {
        CustomToast.showError(Get.context!, "Google login failed");
      }
    } catch (e) {
      isGoogleLoading.value = false;
      debugPrint("❌ Google Login Error: $e");
      CustomToast.showError(Get.context!, "Google login error: $e");
    }
  }

  /// ✅ Logout
  void logout() {
    box.erase();
    debugPrint("🔒 Cleared all storage");
    Get.offAllNamed(Routes.LOGIN);
    CustomToast.showSuccess(Get.context!, 'Logged out successfully');
  }

  @override
  void onClose() {
    emailOrPhoneController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    for (var c in otpControllers) {
      c.dispose();
    }
    for (var f in otpFocusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}
