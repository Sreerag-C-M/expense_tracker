import 'package:get/get.dart';
import 'add_expense_controller.dart';

class ExpenseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddExpenseController>(() => AddExpenseController());
  }
}
