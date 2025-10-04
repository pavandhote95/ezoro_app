import 'package:get/get.dart';

import '../controllers/bottom_sheet_controller.dart';

class PostQuesionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BottomSheetQuestionsController>(
      () => BottomSheetQuestionsController(),
    );
  }
}
