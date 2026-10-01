class SharedItem {
  final String id;
  String name;
  double price;
  // List of person IDs who share this item. If empty, it's shared by all people.
  List<String> assignedPersonIds;

  SharedItem({
    required this.id,
    required this.name,
    required this.price,
    List<String>? assignedPersonIds,
  }) : assignedPersonIds = assignedPersonIds ?? [];

  SharedItem copyWith({
    String? id,
    String? name,
    double? price,
    List<String>? assignedPersonIds,
  }) {
    return SharedItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      assignedPersonIds: assignedPersonIds ?? List.from(this.assignedPersonIds),
    );
  }
}
