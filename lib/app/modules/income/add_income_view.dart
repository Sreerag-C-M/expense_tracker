import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:test_application/app/core/widgets/glass_container.dart';
import 'add_income_controller.dart';

class AddIncomeView extends GetView<AddIncomeController> {
  const AddIncomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.editId.value == null ? 'Add Income' : 'Edit Income',
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
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
          // Decor blobs
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 80,
                    color: Colors.green.withValues(alpha: 0.3),
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
                              color: Colors.green,
                            ),
                            decoration: const InputDecoration(
                              prefixText: '₹ ',
                              border: InputBorder.none,
                              hintText: '0.00',
                            ),
                            validator: (v) =>
                                v!.isEmpty ? 'Enter amount' : null,
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
                            controller: controller.sourceController,
                            decoration: const InputDecoration(
                              labelText: 'Source',
                              prefixIcon: Icon(Icons.source),
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                v!.isEmpty ? 'Enter source' : null,
                          ),
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
                            () => SwitchListTile(
                              title: const Text('Recurring Income?'),
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
                          : controller.saveIncome,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
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
                          : Text(
                              controller.editId.value == null
                                  ? 'Save Income'
                                  : 'Update Income',
                              style: const TextStyle(
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
