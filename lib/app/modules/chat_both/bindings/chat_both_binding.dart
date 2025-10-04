import 'package:get/get.dart';

import '../controllers/chat_both_controller.dart';

class ChatBothBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatBothController>(
      () => ChatBothController(),
    );
  }
}
