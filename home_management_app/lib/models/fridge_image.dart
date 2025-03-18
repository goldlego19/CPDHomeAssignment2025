class FridgeImage {
  final String id;
  final String path; // Path or URL of the image
  final String groupId; // Link to a specific group
  final DateTime lastUpdated;

  FridgeImage({
    required this.id,
    required this.path,
    required this.groupId,
    required this.lastUpdated,
  });

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'groupId': groupId,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // Create FridgeImage object from JSON (for Firebase)
  static FridgeImage fromJson(Map<String, dynamic> json) {
    return FridgeImage(
      id: json['id'],
      path: json['path'],
      groupId: json['groupId'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}
