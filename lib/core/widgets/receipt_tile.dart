import 'package:flutter/material.dart';
import '../../models/receipt.dart';
import 'package:intl/intl.dart';

class ReceiptTile extends StatelessWidget {
  final Receipt receipt;
  final VoidCallback onTap;
  const ReceiptTile({super.key, required this.receipt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MMM yyyy').format(receipt.date);
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: Theme.of(context).cardTheme.color?.withOpacity(0.9),
      leading: CircleAvatar(
        child: Text(receipt.merchant.substring(0, 1)),
      ),
      title: Text(receipt.merchant, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('$date • ${receipt.category} • AI ${(receipt.confidence * 100).toStringAsFixed(0)}%'),
      trailing: Text('£${receipt.total.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
