import 'package:get/get.dart';

import '../../data/providers/expense_provider.dart';
import '../../routes/app_routes.dart';
import '../dashboard/dashboard_controller.dart';

class ExpenseListingController extends GetxController {
  final ExpenseProvider _provider = ExpenseProvider();
  final expenses = <dynamic>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchExpenses();
  }

  void fetchExpenses() async {
    isLoading.value = true;
    try {
      final data = await _provider.getExpenses();
      // Sort by date descending
      data.sort((a, b) {
        DateTime dA = DateTime.tryParse(a['date'].toString()) ?? DateTime.now();
        if (int.tryParse(a['date'].toString()) != null) {
          dA = DateTime.fromMillisecondsSinceEpoch(
            int.parse(a['date'].toString()),
          );
        }
        DateTime dB = DateTime.tryParse(b['date'].toString()) ?? DateTime.now();
        if (int.tryParse(b['date'].toString()) != null) {
          dB = DateTime.fromMillisecondsSinceEpoch(
            int.parse(b['date'].toString()),
          );
        }
        return dB.compareTo(dA);
      });
      expenses.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load expenses');
    } finally {
      isLoading.value = false;
    }
  }

  void deleteExpense(String id) async {
    try {
      await _provider.deleteExpense(id);
      expenses.removeWhere((e) => (e['_id'] ?? e['id']) == id);
      Get.snackbar('Success', 'Expense deleted');
      // Refresh Main Dashboard too
      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().fetchDashboardData(
          isRefresh: true,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete expense');
    }
  }

  void navigateToAdd() async {
    final result = await Get.toNamed(Routes.ADD_EXPENSE);
    if (result == true) {
      fetchExpenses();
    }
  }

  void navigateToEdit(Map<String, dynamic> expense) async {
    final result = await Get.toNamed(Routes.ADD_EXPENSE, arguments: expense);
    if (result == true) {
      fetchExpenses();
    }
  }
}
