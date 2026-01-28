import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/widgets/ai_card.dart';
import '../../models/bank_account.dart';
import '../../state/bank_controller.dart';
import 'uk_banks.dart';

class BankConnectionsScreen extends ConsumerWidget {
  const BankConnectionsScreen({super.key});

  Future<UkBank?> _pickBank(BuildContext context) async {
    return showModalBottomSheet<UkBank>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      builder: (_) {
        final cs = Theme.of(context).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Choose your bank",
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: ukBanks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final b = ukBanks[i];
                      return InkWell(
                        onTap: () => Navigator.pop(context, b),
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white.withOpacity(0.10)),
                            color: Colors.black.withOpacity(0.10),
                          ),
                          child: Row(
                            children: [
                              _BankLogo(bank: b),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  b.name,
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ),
                              Icon(Icons.chevron_right, color: cs.secondary.withOpacity(0.9)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  BankAccount _mockConnect(UkBank bank) {
    // realistic-ish types
    const types = ["Current account", "Savings account", "Credit card"];
    final type = types[DateTime.now().millisecondsSinceEpoch % types.length];

    // “**** 1234”
    final last4 = (DateTime.now().millisecondsSinceEpoch % 9000 + 1000).toString();
    final masked = "**** $last4";

    final now = DateTime.now();
    // Many Open Banking consents are time-limited; we’ll simulate ~90 days.
    final expires = now.add(const Duration(days: 90));

    return BankAccount(
      id: const Uuid().v4(),
      accountId: "current",
      bankId: bank.id,
      bankName: bank.name,
      maskedAccountNumber: masked,
      accountType: type,
      connectedAt: now,
      connectionStatus: "Connected",
      consentExpiresAt: expires,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(bankAccountsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Bank connections")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AiCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.verified_user, color: cs.secondary, size: 18),
                    const SizedBox(width: 8),
                    const Text("Open Banking (mock)",
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Choose a UK bank to connect. This demo simulates an Open Banking consent flow (no real login).",
                  style: TextStyle(color: Colors.white.withOpacity(0.75)),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final picked = await _pickBank(context);
                      if (picked == null) return;

                      final account = _mockConnect(picked);
                      ref.read(bankAccountsProvider.notifier).link(account);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${picked.name} linked ✅ (mock)")),
                      );
                    },
                    icon: const Icon(Icons.link),
                    label: const Text("Link a bank account"),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Text("Connected accounts",
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),

          if (accounts.isEmpty)
            AiCard(
              child: Row(
                children: [
                  Icon(Icons.account_balance_outlined, color: cs.secondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "No bank accounts linked yet.",
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                  ),
                ],
              ),
            )
          else
            ...accounts.map((a) {
              final bank = ukBanks.firstWhere(
                    (b) => b.id == a.bankId,
                orElse: () => const UkBank(
                  id: "unknown",
                  name: "Bank",
                  short: "B",
                  a: Color(0xFF4F46E5),
                  b: Color(0xFF2DE2E6),
                ),
              );

              final expiresText = a.consentExpiresAt == null
                  ? null
                  : "Consent expires: ${a.consentExpiresAt!.toLocal().toString().split(' ').first}";

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AiCard(
                  child: Row(
                    children: [
                      _BankLogo(bank: bank),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.bankName,
                                style: const TextStyle(fontWeight: FontWeight.w900)),
                            const SizedBox(height: 3),
                            Text(
                              "${a.accountType} • ${a.maskedAccountNumber}",
                              style: TextStyle(color: Colors.white.withOpacity(0.72)),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _Chip(text: a.connectionStatus, color: cs.secondary),
                                if (expiresText != null)
                                  _Chip(text: expiresText, color: cs.primary),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ref.read(bankAccountsProvider.notifier).unlink(a.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Unlinked")),
                          );
                        },
                        icon: Icon(Icons.link_off, color: cs.tertiary),
                      ),
                    ],
                  ),
                ),
              );
            }),

          if (accounts.isNotEmpty) ...[
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: () {
                ref.read(bankAccountsProvider.notifier).unlinkAll();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("All accounts unlinked")),
                );
              },
              icon: Icon(Icons.delete_outline, color: cs.tertiary),
              label: Text("Remove all", style: TextStyle(color: cs.tertiary)),
            ),
          ],
        ],
      ),
    );
  }
}

class _BankLogo extends StatelessWidget {
  final UkBank bank;
  const _BankLogo({required this.bank});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [bank.a, bank.b]),
        boxShadow: [
          BoxShadow(
            color: bank.b.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        bank.short,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
        color: Colors.black.withOpacity(0.10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white.withOpacity(0.86),
        ),
      ),
    );
  }
}
