import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/category_provider.dart';
import '../dashboard/dashboard_controller.dart';

class CategoriesController extends GetxController {
  final CategoryProvider _provider = CategoryProvider();

  final categories = <dynamic>[].obs;
  final isLoading = true.obs;
  final nameController = TextEditingController();
  final type = 'expense'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  void fetchCategories() async {
    isLoading.value = true;
    try {
      final data = await _provider.getCategories();
      categories.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load categories');
    } finally {
      isLoading.value = false;
    }
  }

  void addCategory() async {
    if (nameController.text.isEmpty) return;
    try {
      await _provider.createCategory({
        'name': nameController.text,
        'type': type.value,
        'isDefault': false,
      });
      Get.back();
      nameController.clear();
      fetchCategories();
      Get.snackbar('Success', 'Category added');
      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().fetchDashboardData(
          isRefresh: true,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add category: $e');
    }
  }

  void deleteCategory(String id) async {
    try {
      await _provider.deleteCategory(id);
      categories.removeWhere((e) => e['_id'] == id);
      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().fetchDashboardData(
          isRefresh: true,
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
    }
  }
}
