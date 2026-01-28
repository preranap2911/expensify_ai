class Receipt {
  final String id;
  final String merchant;
  final DateTime date;
  final double total;
  final String category;
  final double confidence; // 0..1
  final String imagePath;

  // NEW
  final String currency; // e.g., GBP
  final String? note;
  final bool userEdited;

  const Receipt({
    required this.id,
    required this.merchant,
    required this.date,
    required this.total,
    required this.category,
    required this.confidence,
    required this.imagePath,
    this.currency = "GBP",
    this.note,
    this.userEdited = false,
  });

  Receipt copyWith({
    String? merchant,
    DateTime? date,
    double? total,
    String? category,
    double? confidence,
    String? currency,
    String? note,
    bool? userEdited,
  }) {
    return Receipt(
      id: id,
      merchant: merchant ?? this.merchant,
      date: date ?? this.date,
      total: total ?? this.total,
      category: category ?? this.category,
      confidence: confidence ?? this.confidence,
      imagePath: imagePath,
      currency: currency ?? this.currency,
      note: note ?? this.note,
      userEdited: userEdited ?? this.userEdited,
    );
  }
}
