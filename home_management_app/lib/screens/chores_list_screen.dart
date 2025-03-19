import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:home_management_app/models/chore.dart';
import 'package:home_management_app/models/user.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class ChoresScreen extends StatefulWidget {
  final String userId; // User ID from Firebase
  final String groupId; // Group ID from Firebase

  ChoresScreen({required this.userId, required this.groupId});

  @override
  _ChoresScreenState createState() => _ChoresScreenState();
}

class _ChoresScreenState extends State<ChoresScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://cpd-nestease-denzelbaldacchino-default-rtdb.europe-west1.firebasedatabase.app',
  ).ref("chores");
  final DatabaseReference _usersRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://cpd-nestease-denzelbaldacchino-default-rtdb.europe-west1.firebasedatabase.app',
  ).ref("users");

  List<Chore> _chores = [];
  bool _isLoading = true;
  List<User> _users = [];

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _fetchChores();
    _fetchUsersInGroup();
  }

  Future<void> _initializeNotifications() async {
    // Request notification permission for Android 13+
    if (await Permission.notification.request().isGranted) {
      print('Notification permission granted.');
    } else {
      print('Notification permission denied.');
      return; // Stop if permission is not granted
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            '@mipmap/ic_launcher'); // Ensure this icon exists

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _sendNewChoreNotification(
      String choreName, DateTime dueDate) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'chore_channel', // Unique ID
      'Chores', // Name
      channelDescription: 'Notifications for added chores',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'New Chore Added',
      '$choreName due on ${DateFormat('EEE d MMM, HH:mm').format(dueDate)}',
      platformChannelSpecifics,
    );
  }

  Future<void> _sendCompletionNotification(String choreName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'completion_channel', // Unique channel ID
      'Completed Chores',
      channelDescription: 'Notifications when a chore is completed',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Chore Completed',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      1, // Notification ID (should be different from the "new chore" notification)
      'Chore Completed 🎉',
      '$choreName has been marked as completed!',
      platformChannelSpecifics,
    );
  }

  void _fetchUsersInGroup() {
    _usersRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        List<User> loadedUsers = [];
        final data = event.snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, userData) {
          if (userData["groupId"] == widget.groupId) {
            loadedUsers.add(User(
              id: key,
              name: userData["name"],
              email: userData["email"],
              password: userData["password"],
              role: userData["role"],
              groupId: userData["groupId"],
            ));
          }
        });
        if (mounted) {
          setState(() {
            _users = loadedUsers;
          });
        }
      }
    });
  }

  void _fetchChores() {
    _dbRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        List<Chore> loadedChores = [];
        final data = event.snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, choreData) {
          if (choreData["userId"] == widget.userId) {
            loadedChores.add(Chore(
              id: key,
              name: choreData["name"],
              description: choreData["description"],
              userId: choreData["userId"],
              dueDate: DateTime.parse(choreData["dueDate"]),
              completed: choreData["completed"] ?? false,
            ));
          }
        });
        if (mounted) {
          setState(() {
            _chores = loadedChores;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _chores = [];
            _isLoading = false;
          });
        }
      }
    });
  }

  void _addChore(String name, String description, DateTime dueDate, String id) {
    String newChoreId = _dbRef.push().key!;
    _dbRef.child(newChoreId).set({
      "id": newChoreId,
      "name": name,
      "description": description,
      "userId": id,
      "dueDate": dueDate.toIso8601String(),
      "completed": false,
    });

    _sendNewChoreNotification(name, dueDate);
  }

  void _toggleChoreCompletion(String choreId, bool isCompleted) {
    _dbRef.child(choreId).update({"completed": isCompleted});
    _sendCompletionNotification(
        _chores.firstWhere((c) => c.id == choreId).name);
    if (isCompleted) {
      Future.delayed(Duration(milliseconds: 500), () {
        _dbRef.child(choreId).remove();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chores",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: Colors.deepPurple.shade700,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white), // 🏠 Home Icon
          onPressed: () {
            Navigator.pop(context); // Navigates back to the previous screen
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _chores.isEmpty
                ? Center(
                    child: Text("No Chores Found",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)))
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _chores.length,
                    itemBuilder: (context, index) {
                      final chore = _chores[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Text(
                            chore.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              decoration: chore.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                              color:
                                  chore.completed ? Colors.grey : Colors.black,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5),
                              Text(chore.description),
                              SizedBox(height: 5),
                              Text(
                                  "Due: ${DateFormat('EEE d MMM, HH:mm').format(chore.dueDate.toLocal())}"),
                            ],
                          ),
                          trailing: Checkbox(
                            value: chore.completed,
                            onChanged: (value) =>
                                _toggleChoreCompletion(chore.id, value!),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddChoreDialog(context),
        backgroundColor: Colors.white,
        child: Icon(Icons.add, color: Colors.deepPurple.shade700),
      ),
    );
  }

  void _showAddChoreDialog(BuildContext context) {
    final _nameController = TextEditingController();
    final _descriptionController = TextEditingController();
    DateTime? _selectedDateTime;
    User? _selectedUser;
    List<User> groupMembers = _users;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void _pickDateTime() async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDateTime ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );

              if (pickedDate != null) {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (pickedTime != null) {
                  if (mounted) {
                    setState(() {
                      _selectedDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  }
                }
              }
            }

            return AlertDialog(
              title: Text("Add Chore"),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                        labelText: "Chore Name", border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                        labelText: "Description", border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<User>(
                    value: _selectedUser,
                    hint: Text("Assign to"),
                    items: groupMembers.map((user) {
                      return DropdownMenuItem(
                        value: user,
                        child: Text(user.name),
                      );
                    }).toList(),
                    onChanged: (User? newValue) {
                      if (mounted) {
                        setState(() {
                          _selectedUser = newValue;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDateTime == null
                              ? "No date selected"
                              : "Due: ${DateFormat('EEE d MMM, HH:mm').format(_selectedDateTime!)}",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_today,
                            color: Colors.deepPurpleAccent),
                        onPressed: _pickDateTime,
                        tooltip: "Pick a date",
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel")),
                TextButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty &&
                        _descriptionController.text.isNotEmpty &&
                        _selectedDateTime != null &&
                        _selectedUser != null) {
                      _addChore(
                          _nameController.text,
                          _descriptionController.text,
                          _selectedDateTime!,
                          _selectedUser!.id);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please fill all fields")));
                    }
                  },
                  child: Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
