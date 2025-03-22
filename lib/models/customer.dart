class Customer {
  String? id; // Add this field (nullable since it’s set after creation)
  String name;
  String phone1;
  String phone2;
  String shopAddress;
  String shopName;

  Customer({
    this.id, // Not required since it’s assigned by Firestore
    required this.name,
    required this.phone1,
    required this.phone2,
    required this.shopAddress,
    required this.shopName,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      name: json['name'],
      phone1: json['phone1'],
      phone2: json['phone2'],
      shopAddress: json['shopAddress'],
      shopName: json['shopName'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone1': phone1,
        'phone2': phone2,
        'shopAddress': shopAddress,
        'shopName': shopName,
      };
}
