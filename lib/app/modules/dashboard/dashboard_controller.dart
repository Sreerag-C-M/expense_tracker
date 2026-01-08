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
  final recentExpenses = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // fetchDashboardData(); // Moved to onReady
  }

  @override
  void onReady() {
    super.onReady();
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

      final expenses = await _provider.getExpenses();
      final incomes = await _provider.getIncomes();

      final allTransactions = <Map<String, dynamic>>[];

      for (var e in expenses) {
        allTransactions.add({...e, '_type': 'expense'});
      }
      for (var i in incomes) {
        allTransactions.add({...i, '_type': 'income'});
      }

      // Sort by date descending
      allTransactions.sort((a, b) {
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

      recentExpenses.assignAll(allTransactions);

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      debugPrint('Error fetching dashboard: $e');

      Get.snackbar(
        "Error",
        "Failed to load dashboard data: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }
}
