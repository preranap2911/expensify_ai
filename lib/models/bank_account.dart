class BankAccount {
  final String id;
  final String bankId;
  final String bankName;

  // NEW: distinguish multiple accounts from same bank
  final String accountId; // e.g. "current", "savings", "credit"

  final String maskedAccountNumber;
  final String accountType;
  final DateTime connectedAt;

  final String connectionStatus; // Connected / Expired / Needs re-auth
  final DateTime? consentExpiresAt;

  // NEW: sync status
  final DateTime? lastSyncedAt;

  const BankAccount({
    required this.id,
    required this.bankId,
    required this.bankName,
    required this.accountId,
    required this.maskedAccountNumber,
    required this.accountType,
    required this.connectedAt,
    this.connectionStatus = "Connected",
    this.consentExpiresAt,
    this.lastSyncedAt,
  });

  BankAccount copyWith({
    String? connectionStatus,
    DateTime? lastSyncedAt,
    DateTime? consentExpiresAt,
  }) {
    return BankAccount(
      id: id,
      bankId: bankId,
      bankName: bankName,
      accountId: accountId,
      maskedAccountNumber: maskedAccountNumber,
      accountType: accountType,
      connectedAt: connectedAt,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      consentExpiresAt: consentExpiresAt ?? this.consentExpiresAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}
