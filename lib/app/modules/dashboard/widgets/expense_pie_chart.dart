import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpensePieChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const ExpensePieChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: data.map((item) {
            final index = data.indexOf(item);
            final colors = [
              Colors.blue,
              Colors.red,
              Colors.green,
              Colors.orange,
              Colors.purple,
              Colors.teal,
            ];
            return PieChartSectionData(
              color: colors[index % colors.length],
              value: (item['total'] as num).toDouble(),
              title: '',
              radius: 50,
            );
          }).toList(),
          centerSpaceRadius: 40,
        ),
      ),
    );
  }
}
