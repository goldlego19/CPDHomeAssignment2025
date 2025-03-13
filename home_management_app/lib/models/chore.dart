import 'package:flutter/material.dart';   

class Chore {
  const Chore({
    required this.id,
    required this.name,
    required this.description,
    required this.userId,
    required this.dueDate,
    required this.completed,
  });

  final String id;
  final String name;
  final String description;
  final String userId;
  final DateTime dueDate;
  final bool completed;
}