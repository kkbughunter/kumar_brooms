class UserPermission {
  final String uid;
  bool isActive;
  String? name;
  String? phone;
  String? role;

  UserPermission({
    required this.uid,
    required this.isActive,
    this.name,
    this.phone,
    this.role,
  });

  factory UserPermission.fromJson(String uid, bool isActive, Map<String, dynamic>? userData) {
    return UserPermission(
      uid: uid,
      isActive: isActive,
      name: userData?['name'],
      phone: userData?['phone'],
      role: userData?['role'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'role': role,
      };
}