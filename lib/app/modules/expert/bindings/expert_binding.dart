import 'package:get/get.dart';

import '../controllers/expert_controller.dart';

class ExpertBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExpertController>(
      () => ExpertController(),
    );
  }
}
