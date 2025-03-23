import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  String? id;
  String name;
  String phone1;
  String phone2;
  String shopAddress;
  String shopName;
  double advanceAmount;
  double pendingAmount; // New field for pending amount
  Timestamp? advanceLastUpdate; // New field for last advance update timestamp
  Timestamp? pendingLastUpdate; // New field for last pending update timestamp

  Customer({
    this.id,
    required this.name,
    required this.phone1,
    required this.phone2,
    required this.shopAddress,
    required this.shopName,
    this.advanceAmount = 0.0,
    this.pendingAmount = 0.0, // Default to 0
    this.advanceLastUpdate, // Nullable, defaults to null
    this.pendingLastUpdate, // Nullable, defaults to null
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      name: json['name'],
      phone1: json['phone1'],
      phone2: json['phone2'],
      shopAddress: json['shopAddress'],
      shopName: json['shopName'],
      advanceAmount: (json['advanceAmount'] as num?)?.toDouble() ?? 0.0,
      pendingAmount: (json['pendingAmount'] as num?)?.toDouble() ?? 0.0, // New
      advanceLastUpdate: json['advanceLastUpdate'] as Timestamp?, // New
      pendingLastUpdate: json['pendingLastUpdate'] as Timestamp?, // New
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone1': phone1,
        'phone2': phone2,
        'shopAddress': shopAddress,
        'shopName': shopName,
        'advanceAmount': advanceAmount,
        'pendingAmount': pendingAmount, // New
        'advanceLastUpdate': advanceLastUpdate, // New
        'pendingLastUpdate': pendingLastUpdate, // New
      };
}