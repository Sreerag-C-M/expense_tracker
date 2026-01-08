import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/upcoming_provider.dart';

class UpcomingController extends GetxController {
  final UpcomingProvider _provider = UpcomingProvider();

  final upcomingPayments = <dynamic>[].obs;
  final isLoading = true.obs;

  // Form Controllers
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final dueDate = DateTime.now().obs;
  final frequency = 'monthly'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPayments();
  }

  void fetchPayments() async {
    isLoading.value = true;
    try {
      final data = await _provider.getUpcomingPayments();
      upcomingPayments.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load payments');
    } finally {
      isLoading.value = false;
    }
  }

  void addPayment() async {
    if (titleController.text.isEmpty || amountController.text.isEmpty) {
      Get.snackbar("Error", "Please fill all fields");
      return;
    }

    try {
      final data = {
        'title': titleController.text,
        'amount': double.parse(amountController.text),
        'dueDate': dueDate.value.toIso8601String(),
        'frequency': frequency.value,
      };

      await _provider.createUpcomingPayment(data);
      Get.back(); // Close dialog
      fetchPayments(); // Refresh list
      Get.snackbar(
        'Success',
        'Payment Added',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Reset form
      titleController.clear();
      amountController.clear();
      dueDate.value = DateTime.now();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add payment: $e');
    }
  }

  void deletePayment(String id) async {
    try {
      await _provider.deleteUpcomingPayment(id);
      upcomingPayments.removeWhere((element) => element['_id'] == id);
      Get.snackbar('Deleted', 'Payment removed');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete payment');
    }
  }

  void pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dueDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) dueDate.value = picked;
  }
}
