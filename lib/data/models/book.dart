class Book {
  final int? id;
  final String name;
  final double balance;
  final int userId;
  final DateTime createdAt;

  Book({
    this.id,
    required this.name,
    required this.balance,
    required this.userId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Book copyWith({
    int? id,
    String? name,
    String? description,
    double? balance,
    int? userId,
    DateTime? createdAt,
  }) {
    return Book(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      name: map['name'],
      balance: map['balance'],
      userId: map['user_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
