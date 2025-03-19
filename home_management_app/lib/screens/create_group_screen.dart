import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'home_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  final String userId; // User ID from Firebase

  CreateGroupScreen({required this.userId});

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  bool _isLoading = false;

  final DatabaseReference _groupsRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://cpd-nestease-denzelbaldacchino-default-rtdb.europe-west1.firebasedatabase.app',
  ).ref("groups");
  final DatabaseReference _usersRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://cpd-nestease-denzelbaldacchino-default-rtdb.europe-west1.firebasedatabase.app',
  ).ref("users");

  Future<void> _createGroup() async {
    if (_formKey.currentState!.validate()) {
      if (mounted) {
        setState(() => _isLoading = true);
      }

      try {
        // Create a new group with a unique ID
        DatabaseReference newGroupRef = _groupsRef.push();
        String groupId = newGroupRef.key!;

        await newGroupRef.set({
          "id": groupId,
          "name": _groupNameController.text,
        });

        // Update the user's groupId in Firebase
        await _usersRef.child(widget.userId).update({"groupId": groupId});

        // Navigate to Home Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(userId: widget.userId)),
        );
      } catch (e) {
        _showError("Failed to create group. Please try again.");
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _joinGroup(String groupId) async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    try {
      final snapshot = await _groupsRef.child(groupId).get();
      if (!snapshot.exists) {
        _showError("Group not found. Please check the ID.");
        return;
      }

      // Update user's groupId in Firebase
      await _usersRef.child(widget.userId).update({"groupId": groupId});

      // Navigate to Home Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(userId: widget.userId)),
      );
    } catch (e) {
      _showError("Failed to join group. Please try again.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Create / Join Group",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          leading: IconButton(
            icon:
                Icon(Icons.arrow_back_ios, color: Colors.white), // 🏠 Home Icon
            onPressed: () {
              Navigator.pop(context); // Navigates back to the previous screen
            },
          ),
          backgroundColor: Colors.deepPurple.shade700),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Create a Group",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _groupNameController,
                          decoration: InputDecoration(
                              labelText: "Group Name",
                              border: OutlineInputBorder()),
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return "Please enter a group name";
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        _isLoading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _createGroup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 20),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text("Create Group",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Text("OR",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("Join an existing group",
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 15),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () {
                            _showJoinGroupDialog();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: EdgeInsets.symmetric(
                                vertical: 14, horizontal: 20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text("Join Group",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showJoinGroupDialog() {
    final _groupIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Join Group"),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Enter the Group ID to join"),
              SizedBox(height: 10),
              TextFormField(
                controller: _groupIdController,
                decoration: InputDecoration(
                    labelText: "Group ID", border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(
              onPressed: () {
                if (_groupIdController.text.isNotEmpty) {
                  _joinGroup(_groupIdController.text);
                  Navigator.pop(context);
                }
              },
              child: Text("Join"),
            ),
          ],
        );
      },
    );
  }
}
