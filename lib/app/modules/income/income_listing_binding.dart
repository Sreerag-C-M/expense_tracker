import 'package:get/get.dart';
import 'income_listing_controller.dart';

class IncomeListingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IncomeListingController>(() => IncomeListingController());
  }
}
