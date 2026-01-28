import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/receipt.dart';
import '../../services/ai_service.dart';
import '../../state/receipt_controller.dart';

class ReviewReceiptScreen extends ConsumerStatefulWidget {
  final String imagePath;
  final AiExtractionResult extracted;

  const ReviewReceiptScreen({
    super.key,
    required this.imagePath,
    required this.extracted,
  });

  @override
  ConsumerState<ReviewReceiptScreen> createState() => _ReviewReceiptScreenState();
}

class _ReviewReceiptScreenState extends ConsumerState<ReviewReceiptScreen> {
  late final TextEditingController merchant;
  late final TextEditingController total;
  late final TextEditingController category;
  late DateTime date;

  final note = TextEditingController();

  @override
  void initState() {
    super.initState();
    merchant = TextEditingController(text: widget.extracted.merchant);
    total = TextEditingController(text: widget.extracted.total.toStringAsFixed(2));
    category = TextEditingController(text: widget.extracted.category);
    date = widget.extracted.date;
  }

  @override
  void dispose() {
    merchant.dispose();
    total.dispose();
    category.dispose();
    note.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => date = picked);
  }

  void save() {
    final parsedTotal = double.tryParse(total.text.trim()) ?? 0.0;

    final receipt = Receipt(
      id: const Uuid().v4(),
      merchant: merchant.text.trim().isEmpty ? "Unknown" : merchant.text.trim(),
      total: parsedTotal,
      category: category.text.trim().isEmpty ? "Uncategorised" : category.text.trim(),
      date: date,
      confidence: widget.extracted.confidence,
      imagePath: widget.imagePath,
      note: note.text.trim().isEmpty ? null : note.text.trim(),
      userEdited: true,
    );

    ref.read(receiptsProvider.notifier).add(receipt);

    Navigator.pop(context); // back to Scan tab
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Saved ✅")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final confPct = (widget.extracted.confidence * 100).toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(title: const Text("Review")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.file(File(widget.imagePath), height: 220, fit: BoxFit.cover),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 18),
              const SizedBox(width: 8),
              Text("AI confidence: $confPct%",
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.75))),
            ],
          ),

          const SizedBox(height: 14),

          TextField(
            controller: merchant,
            decoration: const InputDecoration(labelText: "Merchant"),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: total,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: "Total (£)"),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: category,
            decoration: const InputDecoration(labelText: "Category"),
          ),
          const SizedBox(height: 12),

          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Date"),
            subtitle: Text("${date.toLocal()}".split(" ").first),
            trailing: const Icon(Icons.calendar_month),
            onTap: pickDate,
          ),

          const SizedBox(height: 12),
          TextField(
            controller: note,
            decoration: const InputDecoration(labelText: "Note (optional)"),
          ),

          const SizedBox(height: 18),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: save,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text("Save receipt"),
            ),
          ),
        ],
      ),
    );
  }
}
