import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../data/providers/dashboard_provider.dart';

class DashboardController extends GetxController {
  final isLoading = true.obs;
  final isError = false.obs;
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
  }

  @override
  void onReady() {
    super.onReady();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData({bool isRefresh = false}) async {
    if (!isRefresh) {
      isLoading.value = true;
    }
    isError.value = false; // Reset error state
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
      // monthlyTrend is now calculated client-side below

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

      // --- Client-side Monthly Trend Calculation ---
      final Map<String, double> trendMap = {};
      final now = DateTime.now();
      // Initialize with last 6 months (including current)
      for (int i = 5; i >= 0; i--) {
        final d = DateTime(now.year, now.month - i, 1);
        final key = "${d.year}-${d.month.toString().padLeft(2, '0')}";
        trendMap[key] = 0.0;
      }

      for (var e in expenses) {
        DateTime? date;
        if (int.tryParse(e['date'].toString()) != null) {
          date = DateTime.fromMillisecondsSinceEpoch(
            int.parse(e['date'].toString()),
          );
        } else {
          date = DateTime.tryParse(e['date'].toString());
        }

        if (date != null) {
          final key = "${date.year}-${date.month.toString().padLeft(2, '0')}";
          if (trendMap.containsKey(key)) {
            trendMap[key] =
                (trendMap[key] ?? 0) +
                (double.tryParse(e['amount'].toString()) ?? 0.0);
          }
        }
      }

      final generatedTrend = trendMap.entries.map((entry) {
        return {'month': entry.key, 'val': entry.value};
      }).toList();

      // Sort by month string (YYYY-MM)
      generatedTrend.sort(
        (a, b) => (a['month'] as String).compareTo(b['month'] as String),
      );

      monthlyTrend.assignAll(generatedTrend);
      // ---------------------------------------------

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      debugPrint('Error fetching dashboard: $e');

      String errorMessage = e.toString();
      if (errorMessage.length > 100) {
        errorMessage = errorMessage.substring(0, 100) + '...';
      }

      Get.snackbar(
        "Error",
        "Failed to load dashboard data: $errorMessage",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }
}
