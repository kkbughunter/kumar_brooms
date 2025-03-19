class Item {
  String? id;
  String itemFor;
  String length;
  String name;
  double price;
  int weight;

  Item({
    this.id,
    required this.itemFor,
    required this.length,
    required this.name,
    required this.price,
    required this.weight,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemFor: json['item_for'],
      length: json['length'],
      name: json['name'],
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : json['price'], // Convert int to double if needed
      weight: json['weight'],
    );
  }

  Map<String, dynamic> toJson() => {
        'item_for': itemFor,
        'length': length,
        'name': name,
        'price': price,
        'weight': weight,
      };
}
