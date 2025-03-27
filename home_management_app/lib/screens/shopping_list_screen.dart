import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:home_management_app/models/group.dart';
import 'package:home_management_app/models/shopping_item.dart';
import 'fridge_image_screen.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ShoppingListScreen extends StatefulWidget {
  final String userId;
  final String groupId;

  ShoppingListScreen({required this.userId, required this.groupId});

  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final DatabaseReference _groupsRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://cpd-nestease-denzelbaldacchino-default-rtdb.europe-west1.firebasedatabase.app',
  ).ref("groups");
  List<ShoppingItem> _shoppingItems = [];
  bool _isLoading = true;
  Group? _group;
  DatabaseReference? _dbRef;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _fetchShoppingItems();
    _initializeGroup();
    _initializeNotifications();
  }

  Future<void> _initializeGroup() async {
    _groupsRef.child(widget.groupId).once().then((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        if (mounted) {
          setState(() {
            _group = Group(
              id: widget.groupId,
              name: data["name"],
            );
            _dbRef = FirebaseDatabase.instanceFor(
              app: Firebase.app(),
              databaseURL:
                  'https://cpd-nestease-denzelbaldacchino-default-rtdb.europe-west1.firebasedatabase.app',
            ).ref("shopping_lists/${_group!.id}");
          });
        }
        _fetchShoppingItems();
      }
    });
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

  Future<void> _sendNewItemNotification(
      String itemName, String groupName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'item_channel', // Unique ID
      'Items', // Name
      channelDescription: 'Notifications for added items',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'New Item Added',
      '$itemName was added to the shopping list for $groupName',
      platformChannelSpecifics,
    );
  }

  Future<void> _sendCompletionNotification(String groupName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'completion_channel', // Unique channel ID
      'Completed List',
      channelDescription: 'Notifications when a List is completed',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'List Completed',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      1, // Notification ID (should be different from the "new chore" notification)
      'Shopping List Completed 🎉',
      'The shopping list for $groupName has been completed!',
      platformChannelSpecifics,
    );
  }

  void _fetchShoppingItems() {
    if (_dbRef == null) return;

    _dbRef!.onValue.listen((event) {
      if (event.snapshot.exists) {
        List<ShoppingItem> loadedItems = [];
        final data = event.snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, itemData) {
          loadedItems.add(ShoppingItem(
            id: key,
            name: itemData["name"],
            purchased: itemData["purchased"] ?? false,
            groupId: itemData["groupId"],
          ));
        });
        if (mounted) {
          setState(() {
            _shoppingItems = loadedItems;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _shoppingItems = [];
            _isLoading = false;
          });
        }
      }
    });
  }

  void _addShoppingItem(String name, String groupName) {
    String newItemId = _dbRef!.push().key!;
    _dbRef?.child(newItemId).set({
      "id": newItemId,
      "name": name,
      "purchased": false,
      "groupId": widget.groupId,
    });
    _sendNewItemNotification(name, groupName);
  }

  void _togglePurchased(String itemId, bool isPurchased) {
    _dbRef?.child(itemId).update({"purchased": isPurchased});
  }

  void _resetShoppingList() {
    _shoppingItems.forEach((item) {
      if (item.purchased) {
        _dbRef?.child(item.id).update({"purchased": false});
      }
    });
    _sendCompletionNotification(_group!.name);
    _dbRef?.remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shopping List", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple.shade700,
        leading: IconButton(
          icon: Icon(Icons.home, color: Colors.white), // 🏠 Home Icon
          onPressed: () {
            Navigator.pop(context); // Navigates back to the previous screen
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.kitchen, color: Colors.white), // 🧊 Fridge Icon
            tooltip: "View Fridge",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FridgeImageScreen(
                      userId: widget.userId, groupId: widget.groupId),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            tooltip: "Reset List",
            onPressed: _resetShoppingList,
          ),
        ],
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
            : _shoppingItems.isEmpty
                ? Center(
                    child: Text("No items in shopping list",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)))
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _shoppingItems.length,
                    itemBuilder: (context, index) {
                      final item = _shoppingItems[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              decoration: item.purchased
                                  ? TextDecoration.lineThrough
                                  : null,
                              color:
                                  item.purchased ? Colors.grey : Colors.black,
                            ),
                          ),
                          trailing: Checkbox(
                            value: item.purchased,
                            onChanged: (value) =>
                                _togglePurchased(item.id, value!),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(),
        backgroundColor: Colors.white,
        child: Icon(Icons.add, color: Colors.deepPurple.shade700),
      ),
    );
  }

  void _showAddItemDialog() {
    final _nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Item"),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
                labelText: "Item Name", border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  _addShoppingItem(_nameController.text, _group!.name);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter an item name")));
                }
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }
}
