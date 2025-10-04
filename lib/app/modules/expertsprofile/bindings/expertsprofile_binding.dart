import 'package:get/get.dart';

import '../controllers/expertsprofile_controller.dart';

class ExpertsprofileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExpertsprofileController>(
      () => ExpertsprofileController(),
    );
  }
}
