import 'dart:math';

class AiExtractionResult {
  final String merchant;
  final String category;
  final double total;
  final DateTime date;
  final double confidence;

  AiExtractionResult({
    required this.merchant,
    required this.category,
    required this.total,
    required this.date,
    required this.confidence,
  });
}

class AiService {
  Future<AiExtractionResult> extractFromReceiptImage(String imagePath) async {
    // simulate processing time + "AI feel"
    await Future.delayed(const Duration(milliseconds: 1200));

    final merchants = ["Sainsbury’s", "Tesco", "Aldi", "Boots", "Primark"];
    final categories = ["Groceries", "Shopping", "Pharmacy", "Food", "Transport"];
    final rnd = Random();

    return AiExtractionResult(
      merchant: merchants[rnd.nextInt(merchants.length)],
      category: categories[rnd.nextInt(categories.length)],
      total: (5 + rnd.nextInt(40) + rnd.nextDouble()),
      date: DateTime.now(),
      confidence: 0.72 + rnd.nextDouble() * 0.25,
    );
  }
}
