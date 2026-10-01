import 'package:flutter/material.dart';
import 'expense_item.dart';

class Person {
  final String id;
  String name;
  Color color;
  List<ExpenseItem> items;

  Person({
    required this.id,
    required this.name,
    required this.color,
    List<ExpenseItem>? items,
  }) : items = items ?? [];

  double get itemsSubtotal => items.fold(0.0, (sum, item) => sum + item.price);

  Person copyWith({
    String? id,
    String? name,
    Color? color,
    List<ExpenseItem>? items,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      items: items ?? List.from(this.items),
    );
  }
}
