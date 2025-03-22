// lib/models/order.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Orders {
  String? id;
  String customerId;
  Map<String, List<int>> items; // e.g., {'i1': [100, 50]} where [ordered, completed]
  double? paid; // Nullable since it’s not initially present
  Map<String, Timestamp> timestamps;

  Orders({
    this.id,
    required this.customerId,
    required this.items,
    this.paid,
    required this.timestamps,
  });

  factory Orders.fromJson(Map<String, dynamic> json) {
    return Orders(
      id: json['id'],
      customerId: json['customer'],
      items: (json['items'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, List<int>.from(value)),
          ) ??
          {},
      paid: json['paid'] != null
          ? (json['paid'] is int ? (json['paid'] as int).toDouble() : json['paid'])
          : null,
      timestamps: (json['time_stamp'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as Timestamp),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() => {
        'customer': customerId,
        'items': items,
        if (paid != null) 'paid': paid, // Only include if present
        'time_stamp': timestamps.isEmpty
            ? {'order_placed': FieldValue.serverTimestamp()}
            : timestamps,
      };
}