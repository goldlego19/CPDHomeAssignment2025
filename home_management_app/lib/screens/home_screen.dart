import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'create_group_screen.dart';
import 'package:home_management_app/data/dummy_data.dart';
import 'package:home_management_app/models/user.dart';
import 'package:home_management_app/models/group.dart';
import 'package:home_management_app/screens/chores_list_screen.dart';
import 'shopping_list_screen.dart';

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
  title: Text("Home", style: TextStyle(color: Colors.white)), // 🔹 Updated AppBar title
  automaticallyImplyLeading: false,
  backgroundColor: Colors.deepPurple.shade700, // 🔹 Updated AppBar color
  actions: [
    IconButton(
      icon: Icon(Icons.logout),
      color: Colors.white,
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      },
    ),
  ],
),

      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Section
            Text(
              "Welcome, ${user.name} 👋",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              user.groupId.isEmpty
                  ? "You are not in a group yet"
                  : "Group: ${_getGroupName(user.groupId)}",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 30),

            // If user is not in a group, show the join button
            if (user.groupId.isEmpty)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateGroupScreen(user: user),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Create / Join Group",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            // If user is in a group, show dashboard options
            if (user.groupId.isNotEmpty)
              Expanded(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    // Dashboard Options
                    _buildOptionCard(
                      context,
                      "Chores",
                      "Manage household chores",
                      Icons.cleaning_services,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChoresScreen(user: user),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    _buildOptionCard(
                      context,
                      "Shopping List",
                      "Manage shopping essentials",
                      Icons.shopping_cart,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShoppingListScreen(user: user),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Modern Card-Based Button
  Widget _buildOptionCard(
      BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.deepPurple.shade100,
                child: Icon(icon, color: Colors.deepPurple, size: 25),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
