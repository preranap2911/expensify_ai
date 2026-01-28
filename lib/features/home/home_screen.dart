import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/ai_card.dart';
import '../../core/widgets/receipt_tile.dart';
import '../../state/receipt_controller.dart';
import '../profile/bank_connections_screen.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receipts = ref.watch(receiptsProvider);
    final cs = Theme.of(context).colorScheme;

    final monthTotal = receipts.fold<double>(0, (sum, r) => sum + r.total);

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

    // simple AI highlight (we’ll replace with real AI later)
    final aiHighlight = receipts.isEmpty
        ? "Scan your first receipt to unlock insights."
        : "AI detected your top spending category is $topCategoryName.";

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.auto_awesome, color: cs.secondary, size: 18),
              const SizedBox(width: 8),
              const Text('ExpensifyAI'),
            ],
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // HERO AI CARD
            AiCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: cs.secondary.withOpacity(0.35)),
                          color: Colors.black.withOpacity(0.10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt, size: 16, color: cs.secondary),
                            const SizedBox(width: 6),
                            Text(
                              "AI Summary",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withOpacity(0.92),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: cs.primary.withOpacity(0.35)),
                          color: Colors.black.withOpacity(0.10),
                        ),
                        child: Text(
                          "LIVE",
                          style: TextStyle(
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w800,
                            color: cs.primary.withOpacity(0.95),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "This month",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "£${monthTotal.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 34,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(0.96),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    aiHighlight,
                    style: TextStyle(color: Colors.white.withOpacity(0.75)),
                  ),
                  const SizedBox(height: 14),

                  // QUICK STATS
                  Row(
                    children: [
                      Expanded(
                        child: _NeonStat(
                          label: "Top category",
                          value: topCategoryName,
                          icon: Icons.category_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _NeonStat(
                          label: "Receipts",
                          value: receipts.length.toString(),
                          icon: Icons.receipt_long_outlined,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Text('Recent receipts', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton(
                  onPressed: () {}, // later: go to full history screen
                  child: const Text("View all"),
                ),
              ],
            ),

            if (receipts.isEmpty)
              AiCard(
                child: Row(
                  children: [
                    Icon(Icons.document_scanner_outlined, color: cs.secondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "No receipts yet. Go to Scan and upload one to start.",
                        style: TextStyle(color: Colors.white.withOpacity(0.8)),
                      ),
                    ),
                  ],
                ),
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

class _NeonStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _NeonStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
        color: Colors.black.withOpacity(0.10),
      ),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [
                  cs.primary.withOpacity(0.55),
                  cs.secondary.withOpacity(0.25),
                ],
              ),
            ),
            child: Icon(icon, size: 20, color: Colors.white.withOpacity(0.95)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
