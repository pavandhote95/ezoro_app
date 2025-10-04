import 'package:get/get.dart';

import '../controllers/travellers_controller.dart';

class TravellersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TravellersController>(
      () => TravellersController(),
    );
  }
}
