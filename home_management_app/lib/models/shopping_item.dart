class ShoppingItem {
  String id;
  String name;
  bool purchased;
  String groupId; // To link items to a specific group

  ShoppingItem({
    required this.id,
    required this.name,
    this.purchased = false,
    required this.groupId,
  });

  // Convert to JSON (for Firebase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'purchased': purchased,
      'groupId': groupId,
    };
  }

  // Create a ShoppingItem from JSON (for Firebase)
  static ShoppingItem fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'],
      name: json['name'],
      purchased: json['purchased'],
      groupId: json['groupId'],
    );
  }
}
