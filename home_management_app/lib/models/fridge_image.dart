import 'package:flutter/material.dart';   

class FridgeImage {
  const FridgeImage({
    required this.id,
    required this.path,
    required this.groupId,
    required this.lastUpdated,
  });

  final String id;
  final String path;
  final String groupId;
  final DateTime lastUpdated;
}