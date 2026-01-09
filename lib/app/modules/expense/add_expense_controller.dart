import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/expense_provider.dart';
import '../../data/providers/category_provider.dart';
import '../dashboard/dashboard_controller.dart';

class AddExpenseController extends GetxController {
  final ExpenseProvider _provider = ExpenseProvider();
  final CategoryProvider _categoryProvider = CategoryProvider();

  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final customCategoryController = TextEditingController();

  final selectedDate = DateTime.now().obs;
  final selectedCategory = 'Food'.obs; // Default
  final paymentType = 'cash'.obs;
  final isRecurring = false.obs;
  final recurrenceType = 'monthly'.obs;

  final defaultCategories = <String>[
    'Food',
    'Transport',
    'Rent',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Others',
  ].obs;

  final isLoading = false.obs;
  final Rx<String?> editId = Rx<String?>(null);

  void pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadCategories();

    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      editId.value = args['_id'] ?? args['id'];
      amountController.text = args['amount'].toString();
      descriptionController.text = args['description'] ?? '';

      // We will set category after loading, or temp set it here
      // But simpler to just check containment later.
      // For now, let's delay setting selectedCategory checks until categories are loaded if possible,
      // but simplistic approach:

      final categoryArg = args['category'];
      // We'll optimistically set it, and if it's not in the list later we can add it or handle it.
      if (categoryArg != null) {
        selectedCategory.value = categoryArg;
        if (!defaultCategories.contains(categoryArg)) {
          // Use "Others" logic or add to list?
          // Current logic uses "Others" + Custom text.
          // If it's a known custom category, we might want to just show it.
          // For now, let's keep existing logic:
          if (!defaultCategories.contains(categoryArg)) {
            if ([
              'Food',
              'Transport',
              'Rent',
              'Shopping',
              'Bills',
              'Entertainment',
              'Health',
            ].contains(categoryArg)) {
              // It's a default one
            } else {
              // It's likely a custom one or one from the DB
              // We will wait for DB categories to load.
            }
          }
        }
      }

      // ... (Rest of args parsing)
      // Category Logic refined:
      if (defaultCategories.contains(args['category'])) {
        selectedCategory.value = args['category'];
      } else {
        // It might be in the fetched list later, so we just set it.
        // If it's absolutely not found, user might see it selected or "Others"
        selectedCategory.value = args['category'];
        // Note: Logic for "Others" + Custom Field might need adjustment if we want to support fully dynamic categories.
        // If we move to fully dynamic, "Others" + Custom Field is less needed, but let's keep it for fallback.
      }

      // Date
      try {
        if (int.tryParse(args['date'].toString()) != null) {
          selectedDate.value = DateTime.fromMillisecondsSinceEpoch(
            int.parse(args['date'].toString()),
          );
        } else {
          selectedDate.value = DateTime.parse(args['date']);
        }
      } catch (_) {}

      paymentType.value = args['paymentType'] ?? 'cash';
      isRecurring.value = args['isRecurring'] ?? false;
      recurrenceType.value = args['recurrenceType'] ?? 'monthly';
    }
  }

  void _loadCategories() async {
    try {
      final cats = await _categoryProvider.getCategories();
      final names = cats.map((e) => e['name'].toString()).toList();

      // Merge with hardcoded defaults if you want, or replace them.
      // User said "category is like a useless field", implies they want to use the ones they created.
      // So let's prioritize the DB categories.

      final Set<String> allCats = {};
      // specific hardcoded defaults to keep
      allCats.addAll([
        'Food',
        'Transport',
        'Rent',
        'Shopping',
        'Bills',
        'Entertainment',
        'Health',
        'Others',
      ]);
      allCats.addAll(names);

      defaultCategories.assignAll(allCats.toList());

      // Ensure selected category is valid
      if (!defaultCategories.contains(selectedCategory.value)) {
        if (selectedCategory.value != 'Others' &&
            selectedCategory.value.isNotEmpty) {
          // It was a custom one not in list? Add it temp?
          defaultCategories.add(selectedCategory.value);
        } else {
          selectedCategory.value = defaultCategories.first;
        }
      }
    } catch (e) {
      print("Error loading categories: $e");
    }
  }

  void saveExpense() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final category =
          selectedCategory.value == 'Others' &&
              customCategoryController.text.isNotEmpty
          ? customCategoryController.text
          : selectedCategory.value;

      final expenseData = {
        'amount': double.parse(amountController.text),
        'description': descriptionController.text,
        'category': category,
        'date': selectedDate.value.toIso8601String(),
        'paymentType': paymentType.value,
        'isRecurring': isRecurring.value,
        'recurrenceType': isRecurring.value ? recurrenceType.value : null,
      };

      if (editId.value != null) {
        await _provider.updateExpense(editId.value!, expenseData);
        Get.snackbar(
          'Success',
          'Expense updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        await _provider.createExpense(expenseData);
        Get.snackbar(
          'Success',
          'Expense added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

      // Refresh Dashboard
      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().fetchDashboardData(
          isRefresh: true,
        );
        // Trigger onReady or explicit fetch if needed, but fetchDashboardData calls getExpenses too now
      }

      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save expense: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    descriptionController.dispose();
    customCategoryController.dispose();
    super.onClose();
  }
}
