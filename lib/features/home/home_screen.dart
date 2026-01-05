import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/ai_card.dart';
import '../../core/widgets/receipt_tile.dart';
import '../../state/receipt_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receipts = ref.watch(receiptsProvider);

    final monthTotal = receipts.fold<double>(0, (sum, r) => sum + r.total);

    // ✅ Clean, typed top-category calculation
    String topCategoryName = '—';
    if (receipts.isNotEmpty) {
      final counts = <String, int>{};
      for (final r in receipts) {
        counts[r.category] = (counts[r.category] ?? 0) + 1;
      }

      final sorted = counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      topCategoryName = sorted.first.key;
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ExpensifyAI'),
          actions: const [SizedBox(width: 8)],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AiCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('This month',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text('£${monthTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 6),
                        Text('Top category: $topCategoryName',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withOpacity(0.75))),
                      ],
                    ),
                  ),
                  const Icon(Icons.auto_awesome, size: 34),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text('Recent receipts',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            if (receipts.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('No receipts yet. Go to Scan tab to add one.'),
              )
            else
              ...receipts.take(8).map(
                    (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ReceiptTile(
                    receipt: r,
                    onTap: () => context.push('/receipt/${r.id}'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
