import 'package:flutter/material.dart';


class User{

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.groupId,
  });

  final String id;
  final String name;
  final String email;
  final String password;
  final String role;
  final String groupId;

}