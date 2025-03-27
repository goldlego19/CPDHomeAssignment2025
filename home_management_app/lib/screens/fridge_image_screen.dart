import 'dart:io';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:home_management_app/models/fridge_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class FridgeImageScreen extends StatefulWidget {
  final String userId;
  final String groupId;

  FridgeImageScreen({required this.userId, required this.groupId});

  @override
  _FridgeImageScreenState createState() => _FridgeImageScreenState();
}

class _FridgeImageScreenState extends State<FridgeImageScreen> {
  late final DatabaseReference _dbRef;
  String? _imageUrl;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _dbRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://cpd-nestease-denzelbaldacchino-default-rtdb.europe-west1.firebasedatabase.app',
    ).ref("fridgeImages/${widget.groupId}");

    _fetchLatestFridgeImage();
  }

  Future<void> _fetchLatestFridgeImage() async {
    final snapshot = await _dbRef.get();
    if (snapshot.exists) {
      final imageData = snapshot.value as Map<dynamic, dynamic>;

      // Convert Firebase data into FridgeImage object
      FridgeImage fridgeImage = FridgeImage.fromJson(
        Map<String, dynamic>.from(imageData),
      );
      if (mounted) {
        setState(() {
          _imageUrl = fridgeImage.base64;
          _lastUpdated = fridgeImage.lastUpdated;
        });
      }
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      // Convert image to Base64
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // Create a unique ID for the image
      String imageId = "fridge_${widget.groupId}";

      // Get the timestamp
      DateTime timestamp = DateTime.now();

      // Create FridgeImage object
      FridgeImage fridgeImage = FridgeImage(
        id: imageId,
        base64: base64Image,
        groupId: widget.groupId,
        lastUpdated: DateTime.now(),
      );

      // Upload the object to Firebase
      await _dbRef.set(fridgeImage.toJson());

      if (mounted) {
        setState(() {
          _imageUrl = fridgeImage.base64;
          _lastUpdated = fridgeImage.lastUpdated;
        });
      }

      print("Image uploaded successfully.");
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image. Error: $e")),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      _uploadImage(imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Fridge Image", style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon:
                Icon(Icons.arrow_back_ios, color: Colors.white), // 🏠 Home Icon
            onPressed: () {
              Navigator.pop(context); // Navigates back to the previous screen
            },
          ),
          backgroundColor: Colors.deepPurple.shade700),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _imageUrl == null
                  ? Text("No fridge image available",
                      style: TextStyle(fontSize: 18, color: Colors.white))
                  : Column(
                      children: [
                        _imageUrl == null
                            ? Text("No fridge image available",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white))
                            : Image.memory(
                                base64Decode(_imageUrl!),
                                height: 500,
                                fit: BoxFit.cover,
                              ),
                        SizedBox(height: 10),
                        Text(
                          "Last Updated: ${DateFormat('EEE d MMM, HH:mm').format(_lastUpdated!.toLocal())}",
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.camera_alt),
                label: Text("Update Image"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
