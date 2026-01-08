import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../data/providers/dashboard_provider.dart';

class DashboardController extends GetxController {
  final isLoading = true.obs;
  final DashboardProvider _provider = DashboardProvider();

  // Data Observables
  final currentBalance = 0.0.obs;
  final thisMonthIncome = 0.0.obs;
  final thisMonthExpenses = 0.0.obs;
  final upcomingTotal = 0.0.obs;
  final projectedBalance = 0.0.obs;
  final topCategories = <Map<String, dynamic>>[].obs;
  final monthlyTrend = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  void fetchDashboardData() async {
    isLoading.value = true;
    try {
      final data = await _provider.getDashboardData();

      currentBalance.value = (data['currentBalance'] as num).toDouble();
      thisMonthIncome.value = (data['thisMonthIncome'] as num).toDouble();
      thisMonthExpenses.value = (data['thisMonthExpenses'] as num).toDouble();
      upcomingTotal.value = (data['upcomingTotal'] as num).toDouble();
      projectedBalance.value = (data['projectedBalance'] as num).toDouble();

      topCategories.assignAll(
        List<Map<String, dynamic>>.from(data['topCategories']),
      );
      monthlyTrend.assignAll(
        List<Map<String, dynamic>>.from(data['monthlyTrend']),
      );

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      debugPrint('Error fetching dashboard: $e');

      // DEMO MODE: Backend not found, showing mock data for UI preview
      Get.snackbar(
        "Demo Mode",
        "Backend not connected. Showing sample data.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.secondary,
        colorText: Get.theme.colorScheme.onSecondary,
      );

      currentBalance.value = 2450.00;
      thisMonthIncome.value = 5000.00;
      thisMonthExpenses.value = 2550.00;
      upcomingTotal.value = 450.00;
      projectedBalance.value = 2000.00;

      topCategories.assignAll([
        {'_id': 'Rent', 'total': 1200},
        {'_id': 'Food', 'total': 800},
        {'_id': 'Transport', 'total': 350},
      ]);

      monthlyTrend.assignAll([
        {'month': '2023-8', 'val': 2000},
        {'month': '2023-9', 'val': 2400},
        {'month': '2023-10', 'val': 1800},
        {'month': '2023-11', 'val': 2550},
        {'month': '2023-12', 'val': 2100},
        {'month': '2024-1', 'val': 2550},
      ]);
    }
  }
}
