class ExpenseItem {
  final String id;
  String name;
  double price;

  ExpenseItem({
    required this.id,
    required this.name,
    required this.price,
  });

  ExpenseItem copyWith({
    String? id,
    String? name,
    double? price,
  }) {
    return ExpenseItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }
}
