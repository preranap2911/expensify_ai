class Receipt {
  final String id;
  final String merchant;
  final DateTime date;
  final double total;
  final String category;
  final double confidence; // AI confidence 0..1
  final String imagePath;

  const Receipt({
    required this.id,
    required this.merchant,
    required this.date,
    required this.total,
    required this.category,
    required this.confidence,
    required this.imagePath,
  });

  Receipt copyWith({
    String? merchant,
    DateTime? date,
    double? total,
    String? category,
    double? confidence,
  }) {
    return Receipt(
      id: id,
      merchant: merchant ?? this.merchant,
      date: date ?? this.date,
      total: total ?? this.total,
      category: category ?? this.category,
      confidence: confidence ?? this.confidence,
      imagePath: imagePath,
    );
  }
}

