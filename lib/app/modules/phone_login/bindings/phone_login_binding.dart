import 'package:get/get.dart';

import '../controllers/phone_login_controller.dart';

class PhoneLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PhoneAuthController>(
      () => PhoneAuthController(),
    );
  }
}
