import 'package:flutter/material.dart';
import 'package:home_management_app/models/shopping_item.dart';
import 'package:home_management_app/models/user.dart';
import 'package:home_management_app/data/dummy_data.dart';
import 'fridge_image_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class ShoppingListScreen extends StatefulWidget {
  final User user;

  ShoppingListScreen({required this.user});

  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  List<ShoppingItem> shoppingItems = [];

   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _fetchShoppingItems();
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

  Future<void> _sendNotification(String itemName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'item_channel', // Unique channel ID
      'Item Notifications',
      channelDescription: 'Notifications for added Items',
      importance: Importance.max, // Ensure high importance
      priority: Priority.high,
      ticker: 'Item Reminder',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'New Item Added',
      '$itemName has been added to the shopping list',
      platformChannelSpecifics,
    );
  }

  Future<void> _sendEmptyListNotification(String groupName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'item_channel', // Unique channel ID
      'Item Notifications',
      channelDescription: 'Notifications for added Items',
      importance: Importance.max, // Ensure high importance
      priority: Priority.high,
      ticker: 'Item Reminder',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Shopping List Emptied',
      'The shopping list for $groupName has been emptied',
      platformChannelSpecifics,
    );
  }

  // Fetch items based on the user's group
  void _fetchShoppingItems() {
    setState(() {
      shoppingItems = dummyShoppingItems
          .where((item) => item.groupId == widget.user.groupId)
          .toList();
    });
  }

  //Toggle purchased status
  void _togglePurchased(int index) {
    setState(() {
      shoppingItems[index].purchased = !shoppingItems[index].purchased;
    });
  }

  //Reset all items (Clear the list)
  void _resetShoppingList() {
    final groupId = widget.user.groupId;
    final groupName = dummyGroups.firstWhere((group) => group.id == groupId).name;
    _sendEmptyListNotification(groupName); // Send a notification
    setState(() {
      shoppingItems.clear(); // Clear the UI list
      dummyShoppingItems.removeWhere((item) => item.groupId == widget.user.groupId); // Remove from dummy data
    });
}

  // Add a new item
  void _addShoppingItem(String name) {
    String newItemId = DateTime.now().millisecondsSinceEpoch.toString();
    ShoppingItem newItem = ShoppingItem(
      id: newItemId,
      name: name,
      purchased: false,
      groupId: widget.user.groupId,
    );

    _sendNotification(name); // Send a notification

    setState(() {
      shoppingItems.add(newItem);
      dummyShoppingItems.add(newItem); // Add it to the dummy list
    });
  }

  //Show dialog to add an item
  void _showAddItemDialog() {
    final TextEditingController _nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Item"),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: "Item Name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  _addShoppingItem(_nameController.text);
                  Navigator.pop(context);
                }
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("Shopping List"),
      actions: [
        IconButton(
          icon: Icon(Icons.kitchen), // 🧊 Fridge Icon
          tooltip: "View Fridge",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FridgeImageScreen(user: widget.user),
              ),
            );
          },
        ),
      ],
    ),
    body: Column(
      children: [
        Expanded(
          child: shoppingItems.isEmpty
              ? Center(
                  child: Text(
                    "No items in shopping list",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  itemCount: shoppingItems.length,
                  itemBuilder: (context, index) {
                    final item = shoppingItems[index];
                    return ListTile(
                      title: Text(
                        item.name,
                        style: TextStyle(
                          decoration:
                              item.purchased ? TextDecoration.lineThrough : null,
                          color: item.purchased ? Colors.grey : Colors.black,
                        ),
                      ),
                      trailing: Checkbox(
                        value: item.purchased,
                        onChanged: item.purchased ? null : (_) => _togglePurchased(index),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _resetShoppingList,
                child: Text("Reset List"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                ),
              ),
              ElevatedButton(
                onPressed: _showAddItemDialog,
                child: Text("Add Item"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}