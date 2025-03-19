class FridgeImage {
  final String id;
  final String base64; // Path or URL of the image
  final String groupId; // Link to a specific group
  final DateTime lastUpdated;

  FridgeImage({
    required this.id,
    required this.base64,
    required this.groupId,
    required this.lastUpdated,
  });

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'base64': base64,
      'groupId': groupId,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // Create FridgeImage object from JSON (for Firebase)
  static FridgeImage fromJson(Map<String, dynamic> json) {
    return FridgeImage(
      id: json['id'],
      base64: json['base64'],
      groupId: json['groupId'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}
