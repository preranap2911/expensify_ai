import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/receipt.dart';

final receiptsProvider =
StateNotifierProvider<ReceiptController, List<Receipt>>(
      (ref) => ReceiptController(),
);

class ReceiptController extends StateNotifier<List<Receipt>> {
  ReceiptController() : super(const []);

  void add(Receipt r) => state = [r, ...state];

  Receipt? byId(String id) {
    try {
      return state.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  void update(String id, Receipt updated) {
    state = [
      for (final r in state) if (r.id == id) updated else r,
    ];
  }
}
