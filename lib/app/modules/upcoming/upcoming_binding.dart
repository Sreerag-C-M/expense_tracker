import 'package:get/get.dart';
import 'upcoming_controller.dart';

class UpcomingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UpcomingController>(() => UpcomingController());
  }
}
