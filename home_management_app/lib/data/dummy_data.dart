import 'package:home_management_app/models/chore.dart';
import 'package:home_management_app/models/group.dart';
import 'package:home_management_app/models/shopping_item.dart';
import 'package:home_management_app/models/user.dart';

// Dummy Users
final List<User> dummyUsers = [
  User(
    id: '1',
    name: 'John Doe',
    email: 'john@example.com',
    password: 'password123',
    role: 'user',
    groupId: '101', // Belongs to group 101
  ),
  User(
    id: '2',
    name: 'Jane Smith',
    email: 'jane@example.com',
    password: 'password123',
    role: 'user',
    groupId: '101', // Belongs to group 101
  ),
  User(
    id: '3',
    name: 'Alice Johnson',
    email: 'alice@example.com',
    password: 'password123',
    role: 'user',
    groupId: '', // No group assigned
  ),
];

// Dummy Groups
final List<Group> dummyGroups = [
  Group(
    id: '101',
    name: 'Smith Family',
    description: 'The Smith family household',
  ),
  Group(
    id: '102',
    name: 'Doe Family',
    description: 'The Doe family household',
  ),
];

// Dummy Chores
final List<Chore> dummyChores = [
  Chore(
    id: '1',
    name: 'Wash Dishes',
    description: 'Wash all the dishes in the sink',
    userId: '1',
    dueDate: DateTime.now().add(Duration(days: 1)),
    completed: false,
  ),
  Chore(
    id: '2',
    name: 'Vacuum Living Room',
    description: 'Vacuum the living room carpet',
    userId: '2',
    dueDate: DateTime.now().add(Duration(days: 2)),
    completed: false,
  ),
];

// Dummy Shopping Items
final List<ShoppingItem> dummyShoppingItems = [
  ShoppingItem(
    id: '1',
    name: 'Milk',
    userId: '1',
    quantity: 2,
    completed: false,
  ),
  ShoppingItem(
    id: '2',
    name: 'Bread',
    userId: '2',
    quantity: 1,
    completed: true,
  ),
];
