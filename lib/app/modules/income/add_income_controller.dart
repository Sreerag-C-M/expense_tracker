import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/income_provider.dart';

class AddIncomeController extends GetxController {
  final IncomeProvider _provider = IncomeProvider();

  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final sourceController = TextEditingController();

  final selectedDate = DateTime.now().obs;
  // final selectedSource = 'Salary'.obs; // Removed in favor of text input for simplicity
  final isRecurring = false.obs;
  final recurrenceType = 'monthly'.obs;

  final isLoading = false.obs;

  void pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) selectedDate.value = picked;
  }

  void saveIncome() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final data = {
        'amount': double.parse(amountController.text),
        'source': sourceController.text,
        'date': selectedDate.value.toIso8601String(),
        'isRecurring': isRecurring.value,
        if (isRecurring.value) 'recurrence': recurrenceType.value,
      };

      await _provider.createIncome(data);
      Get.back(result: true);
      Get.snackbar(
        'Success',
        'Income added successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add income: $e',
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
    sourceController.dispose();
    super.onClose();
  }
}
