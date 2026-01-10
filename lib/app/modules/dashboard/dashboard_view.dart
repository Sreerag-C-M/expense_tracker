import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dashboard_controller.dart';
import 'package:test_application/app/routes/app_routes.dart';
import 'widgets/trend_line_chart.dart';
import 'package:test_application/app/core/widgets/glass_container.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 1. Dynamic Background for Glass Effect
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 100,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.3),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 100,
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),

          // 2. Main Content
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async {
                await controller.fetchDashboardData(isRefresh: true);
              },
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    backgroundColor:
                        Colors.transparent, // Transparent for glass
                    surfaceTintColor: Colors.transparent,
                    title: Text(
                      'Dashboard',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    actions: [
                      IconButton(
                        onPressed: () => controller.fetchDashboardData(),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.refresh,
                            size: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          Get.dialog(
                            Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: GlassContainer(
                                borderRadius: 24,
                                opacity: 0.9,
                                color: Theme.of(context).cardColor,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(
                                          alpha: 0.1,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.logout,
                                        color: Colors.red,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Logout?",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Are you sure you want to log out?",
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextButton(
                                            onPressed: () => Get.back(),
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text(
                                              "Cancel",
                                              style: TextStyle(
                                                color: Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium?.color,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Get.back();
                                              controller.logout();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text("Logout"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: GlassContainer(
                          padding: const EdgeInsets.all(8),
                          borderRadius: 12,
                          blur: 10,
                          opacity: 0.1,
                          child: const Icon(Icons.logout, size: 20),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildGlassBalanceCard(context),
                          const SizedBox(height: 24),
                          _buildQuickActions(context),
                          const SizedBox(height: 24),
                          _buildSummaryRow(context),
                          const SizedBox(height: 24),
                          _buildSectionTitle(context, "Spending Trend"),
                          const SizedBox(height: 16),
                          GlassContainer(
                            height: 220,
                            padding: const EdgeInsets.all(20),
                            opacity: 0.05,
                            borderRadius: 24,
                            child: TrendLineChart(
                              data: controller.monthlyTrend,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionTitle(context, "Top Categories"),
                              TextButton(
                                onPressed: () {},
                                child: const Text("See All"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildTopCategoriesList(context),
                          const SizedBox(height: 24),
                          _buildRecentTransactions(context),
                          const SizedBox(height: 100), // Bottom padding
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGlassBalanceCard(BuildContext context) {
    return GlassContainer(
      // height: 220, // REMOVED: Fixed height caused overflow
      width: double.infinity,
      borderRadius: 32,
      opacity: 0.15,
      color: Theme.of(context).colorScheme.primary, // Tint with primary
      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
      padding: EdgeInsets.zero, // Handle padding internally for stack
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.spa, color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                "Smart Balance",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Icon(Icons.more_horiz, color: Colors.white70),
                  ],
                ),
                const SizedBox(
                  height: 24,
                ), // Added explicit spacing instead of mainAxisAlignment spaceBetween relying on height
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${controller.currentBalance.value.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Projected: ₹${controller.projectedBalance.value.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24), // Added explicit spacing
                Row(
                  children: [
                    _buildSmallInfo(
                      "Daily Avg",
                      "₹${(controller.thisMonthExpenses.value / 30).toStringAsFixed(0)}",
                    ),
                    const SizedBox(width: 24),
                    _buildSmallInfo(
                      "Upcoming",
                      "₹${controller.upcomingTotal.value.toStringAsFixed(0)}",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallInfo(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        Text(
          val,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context,
          Icons.arrow_outward,
          "Expense",
          Colors.orange,
          () => Get.toNamed(
            Routes.EXPENSE_LIST,
          )?.then((_) => controller.fetchDashboardData(isRefresh: true)),
        ),
        _buildActionButton(
          context,
          Icons.arrow_downward,
          "Income",
          Colors.green,
          () => Get.toNamed(
            Routes.INCOME_LIST,
          )?.then((_) => controller.fetchDashboardData(isRefresh: true)),
        ),
        _buildActionButton(
          context,
          Icons.calendar_month,
          "Bills",
          Colors.blue,
          () => Get.toNamed(
            Routes.UPCOMING,
          )?.then((_) => controller.fetchDashboardData(isRefresh: true)),
        ),
        _buildActionButton(
          context,
          Icons.pie_chart,
          "Budget",
          Colors.purple,
          () => Get.toNamed(
            Routes.CATEGORIES,
          )?.then((_) => controller.fetchDashboardData(isRefresh: true)),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          GlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: 20,
            color: color,
            opacity: 0.15,
            border: Border.all(color: color.withValues(alpha: 0.3)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryItem(
            context,
            'Income',
            controller.thisMonthIncome.value,
            Colors.green,
            Icons.arrow_circle_down,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryItem(
            context,
            'Expenses',
            controller.thisMonthExpenses.value,
            Colors.red,
            Icons.arrow_circle_up,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16), // Reduced padding to prevent overflow
      borderRadius: 24,
      color: Theme.of(context).cardColor,
      opacity: 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8), // Reduced spacing
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '₹${amount.toStringAsFixed(0)}',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTopCategoriesList(BuildContext context) {
    if (controller.topCategories.isEmpty) return const SizedBox();

    return Column(
      children: controller.topCategories.map((cat) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            opacity: 0.5,
            borderRadius: 20,
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      cat['category'].toString().substring(0, 1),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat['category'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${((cat['total'] / controller.thisMonthExpenses.value) * 100).toStringAsFixed(1)}% of spending",
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  "-₹${cat['total']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    if (controller.recentExpenses.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, "Recent Transactions"),
        const SizedBox(height: 16),
        ...controller.recentExpenses.take(5).map((t) {
          final isIncome = t['_type'] == 'income';
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => Get.toNamed(
                isIncome ? Routes.ADD_INCOME : Routes.ADD_EXPENSE,
                arguments: t,
              )?.then((_) => controller.fetchDashboardData(isRefresh: true)),
              borderRadius: BorderRadius.circular(20),
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                opacity: 0.5,
                borderRadius: 20,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isIncome ? Colors.green : Colors.red)
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isIncome
                            ? Icons.arrow_downward
                            : Icons.shopping_bag_outlined,
                        color: isIncome ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isIncome
                                ? t['source']
                                : (t['description'] ?? t['category']),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            t['date'] != null
                                ? DateFormat.MMMd().format(
                                    int.tryParse(t['date'].toString()) != null
                                        ? DateTime.fromMillisecondsSinceEpoch(
                                            int.parse(t['date'].toString()),
                                          )
                                        : DateTime.parse(t['date']),
                                  )
                                : '',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${isIncome ? '+' : '-'}₹${t['amount']}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isIncome ? Colors.green : Colors.redAccent,
                          ),
                        ),
                        const Icon(Icons.edit, size: 14, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
