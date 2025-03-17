import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home_management_app/models/user.dart';
import 'package:intl/intl.dart';
import 'package:home_management_app/models/chore.dart';
import 'package:home_management_app/data/dummy_data.dart';
import 'package:permission_handler/permission_handler.dart';

class ChoresScreen extends StatefulWidget {
  final User user;

  ChoresScreen({required this.user});

  @override
  _ChoresScreenState createState() => _ChoresScreenState();
}

class _ChoresScreenState extends State<ChoresScreen> {
  List<Chore> chores = []; // Lishores
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    // Initialize with dummy chores (or fetch from a backend)
    _initializeNotifications();
    chores = dummyChores;
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

  Future<void> _sendNotification(String choreName, DateTime dueDate) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'chore_channel', // Unique channel ID
      'Chores Notifications',
      channelDescription: 'Notifications for added chores',
      importance: Importance.max, // Ensure high importance
      priority: Priority.high,
      ticker: 'Chore Reminder',
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

  void _addChore(
      String name, String description, DateTime dueDate, String userId) {
    setState(() {
      chores.add(Chore(
        id: DateTime.now().toString(),
        name: name,
        description: description,
        userId: userId,
        dueDate: dueDate,
        completed: false,
      ));
    });

    _sendNotification(name, dueDate);
  }

  void _toggleChoreCompletion(int index) {
    setState(() {
      chores[index].completed = !chores[index].completed;

      if (chores[index].completed) {
        // Send a notification
        _sendCompletionNotification(chores[index].name);

        // Delete the chore after 500ms
        Future.delayed(Duration(milliseconds: 500), () {
          _deleteChore(index);
        });
      }
    });
  }

  void _deleteChore(int index) {
    setState(() {
      chores.removeAt(index);
    });
  }

  String getSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String formatDueDate(DateTime dueDate) {
    final day = dueDate.day;
    final suffix = getSuffix(day);
    return DateFormat('EEE d\'$suffix\' MMMM, HH:mm').format(dueDate);
  }

  List<User> getGroupMembers(String groupId) {
    return dummyUsers.where((user) => user.groupId == groupId).toList();
  }

  void _showAddChoreDialog(BuildContext context) {
    final _nameController = TextEditingController();
    final _descriptionController = TextEditingController();
    DateTime? _selectedDateTime;
    User? _selectedUser;
    List<User> groupMembers = getGroupMembers(widget.user.groupId);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void _pickDateTime() async {
              // Pick a date
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDateTime ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );

              if (pickedDate != null) {
                // Pick a time after selecting the date
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (pickedTime != null) {
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

            return AlertDialog(
              title: Text('Add Chore'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Chore Name'),
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  DropdownButtonFormField<User>(
                    value: _selectedUser,
                    hint: Text('Assign to'),
                    items: groupMembers.map((user) {
                      return DropdownMenuItem(
                        value: user,
                        child: Text(user.name),
                      );
                    }).toList(),
                    onChanged: (User? newValue) {
                      setState(() {
                        _selectedUser = newValue;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _pickDateTime,
                    child: Text(
                      _selectedDateTime == null
                          ? 'Select Due Date & Time'
                          : 'Due: ${DateFormat('EEE d MMM, HH:mm').format(_selectedDateTime!)}',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
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
                        _selectedUser!.id,
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill all fields')),
                      );
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chores'),
      ),
      body: chores.isEmpty
          ? Center(
              child: Text(
                'No Chores Found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: chores.length,
              itemBuilder: (context, index) {
                final chore = chores[index];
                return ListTile(
                  title: Text(chore.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(chore.description),
                      Text('Due: ${formatDueDate(chore.dueDate.toLocal())}'),
                      Text(
                        'Assigned to: ${dummyUsers.firstWhere(
                              (u) => u.id == chore.userId,
                              orElse: () => User(
                                id: '',
                                name: 'Unknown',
                                email: '',
                                password: '',
                                role: '',
                                groupId: '',
                              ),
                            ).name}',
                      ),
                    ],
                  ),
                  trailing: Checkbox(
                    value: chore.completed,
                    onChanged: (value) {
                      _toggleChoreCompletion(index);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddChoreDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
