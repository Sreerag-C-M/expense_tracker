import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../data/providers/dashboard_provider.dart';
import 'package:get_storage/get_storage.dart';
import '../../routes/app_routes.dart';

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
    isError.value = false;
    try {
      // 1. Fetch data SEQUENTIALLY (not parallel) to avoid overwhelming the connection/server
      // and to satisfy the user's request for "not parallel".
      // strictly using networkOnly policy (handled in provider/service default) for fresh data.

      final expenses = await _provider.getExpenses();
      final incomes = await _provider.getIncomes();
      final upcoming = await _provider.getUpcomingPayments();

      // 2. Calculate Totals (Client-Side)
      double totalExpenses = 0.0;
      double totalIncome = 0.0;
      double calcThisMonthExpenses = 0.0;
      double calcThisMonthIncome = 0.0;
      double calcUpcomingTotal = 0.0;

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      for (var e in expenses) {
        double amount = (double.tryParse(e['amount'].toString()) ?? 0.0);
        totalExpenses += amount;

        DateTime? date = int.tryParse(e['date'].toString()) != null
            ? DateTime.fromMillisecondsSinceEpoch(
                int.parse(e['date'].toString()),
              )
            : DateTime.tryParse(e['date'].toString());

        if (date != null &&
            date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) &&
            date.isBefore(endOfMonth.add(const Duration(seconds: 1)))) {
          calcThisMonthExpenses += amount;
        }
      }

      for (var i in incomes) {
        double amount = (double.tryParse(i['amount'].toString()) ?? 0.0);
        totalIncome += amount;

        DateTime? date = int.tryParse(i['date'].toString()) != null
            ? DateTime.fromMillisecondsSinceEpoch(
                int.parse(i['date'].toString()),
              )
            : DateTime.tryParse(i['date'].toString());

        if (date != null &&
            date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) &&
            date.isBefore(endOfMonth.add(const Duration(seconds: 1)))) {
          calcThisMonthIncome += amount;
        }
      }

      for (var u in upcoming) {
        calcUpcomingTotal += (double.tryParse(u['amount'].toString()) ?? 0.0);
      }

      // 3. Update Observables
      currentBalance.value = totalIncome - totalExpenses;
      thisMonthIncome.value = calcThisMonthIncome;
      thisMonthExpenses.value = calcThisMonthExpenses;
      upcomingTotal.value = calcUpcomingTotal;
      projectedBalance.value = currentBalance.value - upcomingTotal.value;

      // 4. Top Categories (Client-Side)
      final Map<String, double> categoryMap = {};
      for (var e in expenses) {
        DateTime? date = int.tryParse(e['date'].toString()) != null
            ? DateTime.fromMillisecondsSinceEpoch(
                int.parse(e['date'].toString()),
              )
            : DateTime.tryParse(e['date'].toString());

        // Filter for this month for top categories
        if (date != null &&
            date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) &&
            date.isBefore(endOfMonth.add(const Duration(seconds: 1)))) {
          String cat = e['category'] ?? 'Other';
          double amount = (double.tryParse(e['amount'].toString()) ?? 0.0);
          categoryMap[cat] = (categoryMap[cat] ?? 0) + amount;
        }
      }

      final sortedCategories = categoryMap.entries
          .map((e) => {'category': e.key, 'total': e.value})
          .toList();
      sortedCategories.sort(
        (a, b) => (b['total'] as double).compareTo(a['total'] as double),
      );
      topCategories.assignAll(sortedCategories.take(3).toList());

      // 5. Recent Transactions
      final allTransactions = <Map<String, dynamic>>[];
      for (var e in expenses) allTransactions.add({...e, '_type': 'expense'});
      for (var i in incomes) allTransactions.add({...i, '_type': 'income'});

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

      // 6. Monthly Trend (Client-Side)
      final Map<String, double> trendMap = {};
      // Initialize last 6 months
      for (int i = 5; i >= 0; i--) {
        final d = DateTime(now.year, now.month - i, 1);
        final key = "${d.year}-${d.month.toString().padLeft(2, '0')}";
        trendMap[key] = 0.0;
      }

      for (var e in expenses) {
        DateTime? date = int.tryParse(e['date'].toString()) != null
            ? DateTime.fromMillisecondsSinceEpoch(
                int.parse(e['date'].toString()),
              )
            : DateTime.tryParse(e['date'].toString());

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
      generatedTrend.sort(
        (a, b) => (a['month'] as String).compareTo(b['month'] as String),
      );
      monthlyTrend.assignAll(generatedTrend);

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

  Future<void> logout() async {
    final box = GetStorage();
    await box.remove('token');
    Get.offAllNamed(Routes.LOGIN);
  }
}
