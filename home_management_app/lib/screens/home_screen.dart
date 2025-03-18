import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'create_group_screen.dart';
import 'package:home_management_app/data/dummy_data.dart';
import 'package:home_management_app/models/user.dart';
import 'package:home_management_app/models/group.dart';
import 'package:home_management_app/screens/chores_list_screen.dart';
import 'package:home_management_app/screens/shopping_list_screen.dart';

class HomeScreen extends StatelessWidget {
  final User user;

  HomeScreen({required this.user});

  // Helper method to get the group name
  String _getGroupName(String groupId) {
    final group = dummyGroups.firstWhere(
      (group) => group.id == groupId,
      orElse: () => Group(id: '', name: 'No Group', description: ''),
    );
    return group.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Household App'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Perform logout logic here
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: user.groupId.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Welcome, ${user.name}!'),
                  Text('You do not belong to any group.'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the CreateGroupScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateGroupScreen(user: user),
                        ),
                      );
                    },
                    child: Text('Create/Join Group'),
                  ),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Welcome, ${user.name}!'),
                  Text('You are in group: ${_getGroupName(user.groupId)}'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChoresScreen(user: user)),
                      );
                    },
                    child: Text('Chores'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the ShoppingListScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShoppingListScreen(user: user)),
                      );
                    },
                    child: Text('Shopping List'),
                  ),
                ],
              ),
            ),
    );
  }
}
