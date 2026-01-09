import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/income_provider.dart';
import '../dashboard/dashboard_controller.dart';

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

  final Rx<String?> editId = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      editId.value = args['_id'] ?? args['id'];
      amountController.text = args['amount'].toString();
      sourceController.text = args['source'] ?? '';

      try {
        if (int.tryParse(args['date'].toString()) != null) {
          selectedDate.value = DateTime.fromMillisecondsSinceEpoch(
            int.parse(args['date'].toString()),
          );
        } else {
          selectedDate.value = DateTime.parse(args['date']);
        }
      } catch (_) {}

      isRecurring.value = args['isRecurring'] ?? false;
    }
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

      if (editId.value != null) {
        await _provider.updateIncome(editId.value!, data);
        Get.snackbar(
          'Success',
          'Income updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        await _provider.createIncome(data);
        Get.snackbar(
          'Success',
          'Income added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().fetchDashboardData(
          isRefresh: true,
        );
      }

      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save income: $e',
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
