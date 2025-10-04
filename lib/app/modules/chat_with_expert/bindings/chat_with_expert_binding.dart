import 'package:get/get.dart';

import '../controllers/chat_with_expert_controller.dart';

class ChatWithExpertBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatWithExpertController>(
      () => ChatWithExpertController(),
    );
  }
}
