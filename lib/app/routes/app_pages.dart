import 'package:get/get.dart';
import 'package:test_application/app/modules/dashboard/dashboard_binding.dart';
import 'package:test_application/app/modules/dashboard/dashboard_view.dart';
import 'package:test_application/app/modules/splash/splash_binding.dart';
import 'package:test_application/app/modules/splash/splash_view.dart';
import 'app_routes.dart';
import '../modules/expense/add_expense_view.dart';
import '../modules/expense/expense_binding.dart';
import '../modules/income/add_income_view.dart';
import '../modules/income/income_binding.dart';
import '../modules/upcoming/upcoming_view.dart';
import '../modules/upcoming/upcoming_binding.dart';
import '../modules/categories/categories_view.dart';
import '../modules/categories/categories_binding.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.ADD_EXPENSE,
      page: () => const AddExpenseView(),
      binding: ExpenseBinding(),
    ),
    GetPage(
      name: Routes.ADD_INCOME,
      page: () => const AddIncomeView(),
      binding: IncomeBinding(),
    ),
    GetPage(
      name: Routes.UPCOMING,
      page: () => const UpcomingView(),
      binding: UpcomingBinding(),
    ),
    GetPage(
      name: Routes.CATEGORIES,
      page: () => const CategoriesView(),
      binding: CategoriesBinding(),
    ),
  ];
}
