import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/expense_provider.dart';
import '../dashboard/dashboard_controller.dart';

class AddExpenseController extends GetxController {
  final ExpenseProvider _provider = ExpenseProvider();

  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final customCategoryController = TextEditingController();

  final selectedDate = DateTime.now().obs;
  final selectedCategory = 'Food'.obs; // Default
  final paymentType = 'cash'.obs;
  final isRecurring = false.obs;
  final recurrenceType = 'monthly'.obs;

  final List<String> defaultCategories = [
    'Food',
    'Transport',
    'Rent',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Others',
  ];

  final isLoading = false.obs;

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

  final Rx<String?> editId = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      editId.value = args['_id'] ?? args['id'];
      amountController.text = args['amount'].toString();
      descriptionController.text = args['description'] ?? '';

      // Category
      if (defaultCategories.contains(args['category'])) {
        selectedCategory.value = args['category'];
      } else {
        selectedCategory.value = 'Others';
        customCategoryController.text = args['category'] ?? '';
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
        Get.find<DashboardController>().fetchDashboardData();
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
