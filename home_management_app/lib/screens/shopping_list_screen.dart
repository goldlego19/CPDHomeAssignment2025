import 'package:flutter/material.dart';
import 'package:home_management_app/models/shopping_item.dart';
import 'package:home_management_app/models/user.dart';
import 'package:home_management_app/data/dummy_data.dart';

class ShoppingListScreen extends StatefulWidget {
  final User user;

  ShoppingListScreen({required this.user});

  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  List<ShoppingItem> shoppingItems = [];

  @override
  void initState() {
    super.initState();
    _fetchShoppingItems();
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
      appBar: AppBar(title: Text("Shopping List")),
      body: Column(
        children: [
          Expanded(
            child: shoppingItems.isEmpty
                ? Center(child: Text("No items in shopping list"))
                : ListView.builder(
                    itemCount: shoppingItems.length,
                    itemBuilder: (context, index) {
                      final item = shoppingItems[index];
                      return ListTile(
                        title: Text(
                          item.name,
                          style: TextStyle(
                            decoration: item.purchased ? TextDecoration.lineThrough : null,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _resetShoppingList,
                child: Text("Reset List"),
              ),
              ElevatedButton(
                onPressed: _showAddItemDialog,
                child: Text("Add Item"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
