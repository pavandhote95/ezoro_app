import 'package:get/get.dart';

import '../controllers/experts_profile_controller.dart';

class ExpertsProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExpertsProfileController>(
      () => ExpertsProfileController(),
    );
  }
}
