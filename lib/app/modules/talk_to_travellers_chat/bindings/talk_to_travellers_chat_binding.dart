import 'package:get/get.dart';

import '../controllers/talk_to_travellers_chat_controller.dart';

class TalkToTravellersChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TalkToTravellersChatController>(
      () => TalkToTravellersChatController(),
    );
  }
}
