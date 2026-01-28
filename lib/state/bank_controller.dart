import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bank_account.dart';

final bankAccountsProvider =
StateNotifierProvider<BankController, List<BankAccount>>(
      (ref) => BankController(),
);

class BankController extends StateNotifier<List<BankAccount>> {
  BankController() : super(const []);

  void link(BankAccount account) => state = [account, ...state];
  void unlink(String id) => state = state.where((a) => a.id != id).toList();
  void unlinkAll() => state = const [];
}
