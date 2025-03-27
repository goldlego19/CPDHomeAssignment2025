import 'package:flutter/material.dart';

class Chore {
  Chore({
    required this.id,
    required this.name,
    required this.description,
    required this.userId,
    required this.dueDate,
    this.completed = false,
  });

  final String id;
  final String name;
  final String description;
  final String userId;
  final DateTime dueDate;
  bool completed;
}
