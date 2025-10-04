import 'package:get/get.dart';

import '../controllers/dm_controller.dart';

class DmBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DmController>(
      () => DmController(),
    );
  }
}
