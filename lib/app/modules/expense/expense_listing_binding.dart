import 'package:get/get.dart';
import 'expense_listing_controller.dart';

class ExpenseListingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExpenseListingController>(() => ExpenseListingController());
  }
}
