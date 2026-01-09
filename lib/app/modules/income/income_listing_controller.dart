import 'package:get/get.dart';
import '../../data/providers/income_provider.dart';
import '../../routes/app_routes.dart';
import '../dashboard/dashboard_controller.dart';

class IncomeListingController extends GetxController {
  final IncomeProvider _provider = IncomeProvider();
  final incomes = <dynamic>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchIncomes();
  }

  void fetchIncomes() async {
    isLoading.value = true;
    try {
      final data = await _provider.getIncomes();
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
      incomes.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load incomes');
    } finally {
      isLoading.value = false;
    }
  }

  void deleteIncome(String id) async {
    try {
      await _provider.deleteIncome(id);
      incomes.removeWhere((e) => (e['_id'] ?? e['id']) == id);
      Get.snackbar('Success', 'Income deleted');
      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().fetchDashboardData(
          isRefresh: true,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete income');
    }
  }

  void navigateToAdd() async {
    final result = await Get.toNamed(Routes.ADD_INCOME);
    if (result == true) {
      fetchIncomes();
    }
  }

  void navigateToEdit(Map<String, dynamic> income) async {
    final result = await Get.toNamed(Routes.ADD_INCOME, arguments: income);
    if (result == true) {
      fetchIncomes();
    }
  }
}
