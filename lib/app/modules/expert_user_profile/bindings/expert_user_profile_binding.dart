import 'package:get/get.dart';

import '../controllers/expert_user_profile_controller.dart';

class ExpertUserProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExpertUserProfileController>(
      () => ExpertUserProfileController(),
    );
  }
}
