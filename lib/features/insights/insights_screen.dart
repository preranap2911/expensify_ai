import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../state/receipt_controller.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receipts = ref.watch(receiptsProvider);

    final byCategory = <String, double>{};
    for (final r in receipts) {
      byCategory[r.category] = (byCategory[r.category] ?? 0) + r.total;
    }

    final sections = byCategory.entries.map((e) {
      return PieChartSectionData(
        value: e.value,
        title: e.key,
        radius: 70,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      );
    }).toList();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Insights')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: receipts.isEmpty
              ? const Center(child: Text('No data yet. Scan some receipts.'))
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Spending by category',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              SizedBox(
                height: 260,
                child: PieChart(PieChartData(sections: sections)),
              ),
              const SizedBox(height: 10),
              Text(
                'AI highlight: Your top category is ${byCategory.entries.toList()..sort((a,b)=>b.value.compareTo(a.value))}.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.75)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
