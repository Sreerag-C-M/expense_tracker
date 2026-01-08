import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_application/app/core/widgets/glass_container.dart';
import 'categories_controller.dart';

class CategoriesView extends GetView<CategoriesController> {
  const CategoriesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Manage Categories'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          ),

          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              padding: const EdgeInsets.only(
                top: 100,
                bottom: 80,
                left: 16,
                right: 16,
              ),
              itemCount: controller.categories.length,
              itemBuilder: (context, index) {
                final cat = controller.categories[index];
                final isExpense = cat['type'] == 'expense';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: GlassContainer(
                    opacity: 0.5,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (isExpense ? Colors.red : Colors.green)
                                .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isExpense ? Icons.money_off : Icons.attach_money,
                            color: isExpense ? Colors.red : Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                cat['type'].toString().toUpperCase(),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        cat['isDefault'] == true
                            ? const Icon(
                                Icons.lock_outline,
                                size: 20,
                                color: Colors.grey,
                              )
                            : IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    controller.deleteCategory(cat['_id']),
                              ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    Get.defaultDialog(
      title: "New Category",
      content: Column(
        children: [
          TextField(
            controller: controller.nameController,
            decoration: const InputDecoration(labelText: "Category Name"),
          ),
          const SizedBox(height: 10),
          Obx(
            () => DropdownButton<String>(
              value: controller.type.value,
              items: ['expense', 'income']
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (v) => controller.type.value = v!,
            ),
          ),
        ],
      ),
      textConfirm: "Add",
      textCancel: "Cancel",
      onConfirm: controller.addCategory,
    );
  }
}
