import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/receipt_controller.dart';

class ReceiptDetailScreen extends ConsumerWidget {
  final String receiptId;
  const ReceiptDetailScreen({super.key, required this.receiptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receipt = ref.read(receiptsProvider.notifier).byId(receiptId);

    if (receipt == null) {
      return const Scaffold(body: Center(child: Text('Receipt not found')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Receipt')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.file(File(receipt.imagePath),
                  height: 230, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            Text(receipt.merchant,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('Category: ${receipt.category}'),
            Text('Total: £${receipt.total.toStringAsFixed(2)}'),
            Text('AI confidence: ${(receipt.confidence * 100).toStringAsFixed(0)}%'),
          ],
        ),
      ),
    );
  }
}
