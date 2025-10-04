import 'package:get/get.dart';

import '../controllers/community_search_controller.dart';

class CommunitySearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommunitySearchController>(
      () => CommunitySearchController(),
    );
  }
}
