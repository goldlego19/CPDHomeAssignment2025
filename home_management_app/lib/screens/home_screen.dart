import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart'; // Import clipboard package
import 'package:home_management_app/models/group.dart';
import 'login_screen.dart';
import 'create_group_screen.dart';
import 'chores_list_screen.dart';
import 'shopping_list_screen.dart';
import 'package:home_management_app/models/user.dart';

class HomeScreen extends StatefulWidget {
  final String userId; // Pass only the user ID

  HomeScreen({required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://cpd-nestease-denzelbaldacchino-default-rtdb.europe-west1.firebasedatabase.app',
  ).ref("users");
  final DatabaseReference _groupsRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://cpd-nestease-denzelbaldacchino-default-rtdb.europe-west1.firebasedatabase.app',
  ).ref("groups");

  User? _user;
  Group? _group;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final snapshot = await _dbRef.child(widget.userId).get();
      if (snapshot.exists) {
        final userData = snapshot.value as Map<dynamic, dynamic>;
        if (mounted) {
          setState(() {
            _user = User(
              id: widget.userId,
              name: userData["name"],
              email: userData["email"],
              password: userData["password"],
              role: userData["role"],
              groupId: userData["groupId"],
            );
            _isLoading = false;
          });
        }
        _setGroupName(_user!.groupId);
      } else {
        _showError("User not found.");
      }
    } catch (e) {
      _showError("Failed to fetch user data.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setGroupName(String groupId) async {
    if (groupId.isEmpty) return;

    try {
      final snapshot = await _groupsRef.child(groupId).get();

      if (snapshot.exists) {
        final groupData = snapshot.value as Map<dynamic, dynamic>;
        if (mounted) {
          setState(() {
            _group = Group(
              id: groupId,
              name: groupData["name"],
            );
          });
        }
      } else {
        _showError("Group not found.");
      }
    } catch (e) {
      _showError("Failed to fetch group data.");
    }
  }

  void _copyGroupId() {
    if (_group != null) {
      Clipboard.setData(ClipboardData(text: _group!.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Group ID copied to clipboard!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple.shade700,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _user == null
              ? Center(
                  child: Text("User data not available",
                      style: TextStyle(color: Colors.white)))
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple.shade700,
                        Colors.deepPurple.shade400
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting Section
                      Text(
                        "Welcome, ${_user!.name} 👋",
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(height: 8),

                      // Show Group Name & Copyable Group ID
                      if (_user!.groupId.isNotEmpty) ...[
                        Text(
                          "Group: ${_group?.name ?? "Unknown"}",
                          style: TextStyle(fontSize: 20, color: Colors.white70),
                        ),
                        Row(
                          children: [
                            Text(
                              "Group ID: ${_group?.id ?? "N/A"}",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ),
                            IconButton(
                              icon: Icon(Icons.copy, color: Colors.white),
                              tooltip: "Copy Group ID",
                              onPressed: _copyGroupId,
                            ),
                          ],
                        ),
                      ],

                      SizedBox(height: 30),

                      // If user is not in a group, show join button
                      if (_user!.groupId.isEmpty)
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CreateGroupScreen(userId: _user!.id),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text("Create / Join Group",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),

                      // If user is in a group, show dashboard options
                      if (_user!.groupId.isNotEmpty)
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              _buildOptionCard(
                                context,
                                "Chores",
                                "Manage household chores",
                                Icons.cleaning_services,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChoresScreen(
                                          userId: _user!.id,
                                          groupId: _user!.groupId)),
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
                                      builder: (context) => ShoppingListScreen(
                                            userId: _user!.id,
                                            groupId: _group!.id,
                                          )),
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
  Widget _buildOptionCard(BuildContext context, String title, String subtitle,
      IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.deepPurple.shade100,
                child: Icon(icon, color: Colors.deepPurple, size: 30),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade700)),
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
