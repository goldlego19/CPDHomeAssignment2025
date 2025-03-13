import 'package:flutter/material.dart';
import 'package:home_management_app/models/user.dart';
import 'package:home_management_app/models/group.dart';
import 'home_screen.dart';
import 'package:home_management_app/data/dummy_data.dart';

class CreateGroupScreen extends StatefulWidget {
  final User user;

  CreateGroupScreen({required this.user});

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  final _groupDescriptionController = TextEditingController();
  String? _selectedGroupId; // To store the selected group ID

  void _joinGroup() {
    if (_selectedGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a group to join')),
      );
      return;
    }

    // Find the user in the dummyUsers list and update their groupId
    final userIndex =
        dummyUsers.indexWhere((user) => user.id == widget.user.id);
    if (userIndex != -1) {
      dummyUsers[userIndex] = User(
        id: widget.user.id,
        name: widget.user.name,
        email: widget.user.email,
        password: widget.user.password,
        role: widget.user.role,
        groupId: _selectedGroupId!, // Update the groupId
      );
    }

    // Navigate back to the HomeScreen with the updated user
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(user: dummyUsers[userIndex]),
      ),
    );
  }

  void _createGroup() {
    if (_formKey.currentState!.validate()) {
      // Create a new group with a meaningful ID
      final group = Group(
        id: 'group_${DateTime.now().millisecondsSinceEpoch}', // Unique ID
        name: _groupNameController.text,
        description: _groupDescriptionController.text,
      );

      // Add the new group to the dummy data
      dummyGroups.add(group);

      // Find the user in the dummyUsers list and update their groupId
      final userIndex =
          dummyUsers.indexWhere((user) => user.id == widget.user.id);
      if (userIndex != -1) {
        dummyUsers[userIndex] = User(
          id: widget.user.id,
          name: widget.user.name,
          email: widget.user.email,
          password: widget.user.password,
          role: widget.user.role,
          groupId: group.id, // Update the groupId
        );
      }

      // Navigate back to the HomeScreen with the updated user
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(user: dummyUsers[userIndex]),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create/Join Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown to select an existing group
            DropdownButtonFormField<String>(
              value: _selectedGroupId,
              hint: Text('Select a group to join'),
              items: dummyGroups.map((group) {
                return DropdownMenuItem(
                  value: group.id,
                  child: Text(group.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGroupId = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _joinGroup,
              child: Text('Join Selected Group'),
            ),
            SizedBox(height: 20),
            Divider(), // Separator between join and create options
            SizedBox(height: 20),
            // Form to create a new group
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _groupNameController,
                    decoration: InputDecoration(labelText: 'Group Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a group name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _groupDescriptionController,
                    decoration: InputDecoration(labelText: 'Group Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a group description';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _createGroup,
                    child: Text('Create New Group'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
