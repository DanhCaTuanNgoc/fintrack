class User {
  final int? id;
  final String name;
  final String email;
  final bool isPremium;

  User({
    this.id,
    required this.name,
    required this.email,
    this.isPremium = false,
  });

  User copyWith({int? id, String? name, String? email, bool? isPremium}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'premium': isPremium ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      isPremium: map['premium'] == 1,
    );
  }
}
