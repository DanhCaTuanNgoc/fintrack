
class Wallet {
  final int? id;
  final String nameBalance;
  final double walletBalance;
  final String type;
  final int userId;
  final DateTime createdAt;

  Wallet({
    this.id,
    required this.nameBalance,
    required this.walletBalance,
    required this.type,
    required this.userId,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Wallet copyWith({
    int? id,
    String? nameBalance,
    double? balance,
    String? type,
    int? userId,
    DateTime? createdAt,
  }) {
    return Wallet(
      id: id ?? this.id,
      nameBalance: nameBalance ?? this.nameBalance,
      walletBalance: balance ?? this.walletBalance,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name_balance': nameBalance,
      'wallet_balance': walletBalance,
      'type': type,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      id: map['id'],
      nameBalance: map['name_balance'],
      walletBalance: map['wallet_balance'],
      type: map['type'],
      userId: map['user_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

