import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/expense_provider.dart';

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

      await _provider.createExpense(expenseData);
      Get.back(result: true); // Return true to refresh dashboard
      Get.snackbar(
        'Success',
        'Expense added successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add expense: $e',
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
