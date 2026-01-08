import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:test_application/app/core/widgets/glass_container.dart';
import 'upcoming_controller.dart';

class UpcomingView extends GetView<UpcomingController> {
  const UpcomingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Upcoming Payments'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
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
          // Decor
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 80,
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
          ),

          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.upcomingPayments.isEmpty) {
              return const Center(child: Text("No upcoming payments"));
            }
            return ListView.builder(
              padding: const EdgeInsets.only(
                top: 100,
                bottom: 80,
                left: 16,
                right: 16,
              ),
              itemCount: controller.upcomingPayments.length,
              itemBuilder: (context, index) {
                final payment = controller.upcomingPayments[index];
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
                            color: Colors.orange.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.calendar_today,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                payment['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Due: ${DateFormat.yMMMd().format(DateTime.parse(payment['dueDate']))}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                payment['frequency'],
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${payment['amount']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () =>
                                  controller.deletePayment(payment['_id']),
                            ),
                          ],
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
      title: "Add Upcoming Payment",
      content: Column(
        children: [
          TextField(
            controller: controller.titleController,
            decoration: const InputDecoration(
              labelText: "Title (e.g. Netflix)",
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller.amountController,
            decoration: const InputDecoration(
              labelText: "Amount",
              prefixText: "₹ ",
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text("Due Date: "),
              Obx(
                () => TextButton(
                  onPressed: () => controller.pickDate(context),
                  child: Text(
                    DateFormat.yMMMd().format(controller.dueDate.value),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Obx(
            () => DropdownButton<String>(
              value: controller.frequency.value,
              items: ['one-time', 'monthly', 'yearly']
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (v) => controller.frequency.value = v!,
            ),
          ),
        ],
      ),
      textConfirm: "Add",
      textCancel: "Cancel",
      onConfirm: controller.addPayment,
    );
  }
}
