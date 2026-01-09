import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/upcoming_provider.dart';
import '../dashboard/dashboard_controller.dart';

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

  final Rx<String?> editPaymentId = Rx<String?>(null);

  void setEditMode(Map<String, dynamic>? payment) {
    if (payment != null) {
      editPaymentId.value = payment['_id'] ?? payment['id'];
      titleController.text = payment['title'];
      amountController.text = payment['amount'].toString();

      // Handle date parsing safely like in the view
      try {
        if (int.tryParse(payment['dueDate'].toString()) != null) {
          dueDate.value = DateTime.fromMillisecondsSinceEpoch(
            int.parse(payment['dueDate'].toString()),
          );
        } else {
          dueDate.value = DateTime.parse(payment['dueDate']);
        }
      } catch (_) {
        dueDate.value = DateTime.now();
      }

      frequency.value = payment['frequency'];
    } else {
      editPaymentId.value = null;
      titleController.clear();
      amountController.clear();
      dueDate.value = DateTime.now();
      frequency.value = 'monthly';
    }
  }

  void savePayment() async {
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

      if (editPaymentId.value != null) {
        await _provider.updateUpcomingPayment(editPaymentId.value!, data);
        Get.snackbar(
          'Success',
          'Payment Updated',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        await _provider.createUpcomingPayment(data);
        Get.snackbar(
          'Success',
          'Payment Added',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

      Get.back(); // Close dialog
      fetchPayments(); // Refresh list

      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().fetchDashboardData(
          isRefresh: true,
        );
      }

      // Reset form
      setEditMode(null);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save payment: $e');
    }
  }

  void deletePayment(String id) async {
    try {
      await _provider.deleteUpcomingPayment(id);
      upcomingPayments.removeWhere(
        (element) => (element['id'] ?? element['_id']) == id,
      );
      Get.snackbar('Deleted', 'Payment removed');
      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().fetchDashboardData(
          isRefresh: true,
        );
      }
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
