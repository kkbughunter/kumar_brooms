class User {
  final String name;
  final String phone;
  final String role;

  User({
    required this.name,
    required this.phone,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      phone: json['phone'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'role': role,
      };
}
