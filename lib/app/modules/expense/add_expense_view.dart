import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:test_application/app/core/widgets/glass_container.dart';
import 'add_expense_controller.dart';

class AddExpenseView extends GetView<AddExpenseController> {
  const AddExpenseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Add Expense'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // Background Gradient
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
          // Decor blobs
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 80,
                    color: Theme.of(
                      context,
                    ).colorScheme.error.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 120, 16, 20),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GlassContainer(
                    opacity: 0.5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Enter Amount',
                            style: TextStyle(color: Colors.grey),
                          ),
                          TextFormField(
                            controller: controller.amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              prefixText: '₹ ',
                              border: InputBorder.none,
                              hintText: '0.00',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter amount';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassContainer(
                    opacity: 0.5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: controller.descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              prefixIcon: Icon(Icons.description),
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                v!.isEmpty ? 'Enter description' : null,
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => DropdownButtonFormField<String>(
                              value: controller.selectedCategory.value,
                              items: controller.defaultCategories
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  controller.selectedCategory.value = v!,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                prefixIcon: Icon(Icons.category),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          Obx(() {
                            if (controller.selectedCategory.value == 'Others') {
                              return Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: TextFormField(
                                  controller:
                                      controller.customCategoryController,
                                  decoration: const InputDecoration(
                                    labelText: 'Custom Category Name',
                                    prefixIcon: Icon(Icons.edit),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          }),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: () => controller.pickDate(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date',
                                prefixIcon: Icon(Icons.calendar_today),
                                border: OutlineInputBorder(),
                              ),
                              child: Obx(
                                () => Text(
                                  DateFormat.yMMMd().format(
                                    controller.selectedDate.value,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => DropdownButtonFormField<String>(
                              value: controller.paymentType.value,
                              items: ['cash', 'bank', 'upi', 'card']
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e.toUpperCase()),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  controller.paymentType.value = v!,
                              decoration: const InputDecoration(
                                labelText: 'Payment Type',
                                prefixIcon: Icon(Icons.payment),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => SwitchListTile(
                              title: const Text('Recurring Expense?'),
                              value: controller.isRecurring.value,
                              onChanged: (v) =>
                                  controller.isRecurring.value = v,
                            ),
                          ),
                          Obx(() {
                            if (controller.isRecurring.value) {
                              return DropdownButtonFormField<String>(
                                value: controller.recurrenceType.value,
                                items: ['monthly', 'yearly']
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e.toUpperCase()),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    controller.recurrenceType.value = v!,
                                decoration: const InputDecoration(
                                  labelText: 'Recurrence',
                                  prefixIcon: Icon(Icons.loop),
                                  border: OutlineInputBorder(),
                                ),
                              );
                            }
                            return const SizedBox();
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(
                    () => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.saveExpense,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save Expense',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
