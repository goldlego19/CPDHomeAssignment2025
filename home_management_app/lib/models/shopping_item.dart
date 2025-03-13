import 'package:flutter/material.dart';   

class ShoppingItem {
  const ShoppingItem({
    required this.id,
    required this.name,
    required this.userId,
    required this.quantity,
    required this.completed,
  });

  final String id;
  final String name;
  final String userId;
  final int quantity;
  final bool completed;
}