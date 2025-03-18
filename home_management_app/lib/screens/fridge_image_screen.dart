import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:home_management_app/models/fridge_image.dart';
import 'package:home_management_app/data/dummy_data.dart';
import 'package:home_management_app/models/user.dart';
import 'package:intl/intl.dart';


class FridgeImageScreen extends StatefulWidget {
  final User user;

  FridgeImageScreen({required this.user});

  @override
  _FridgeImageScreenState createState() => _FridgeImageScreenState();
}

class _FridgeImageScreenState extends State<FridgeImageScreen> {
  FridgeImage? fridgeImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchFridgeImage();
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

  String formatlastUpdatedDate(DateTime lastUpdated) {
    final day = lastUpdated.day;
    final suffix = getSuffix(day);
    return DateFormat('EEE d\'$suffix\' MMMM, HH:mm').format(lastUpdated);
  }


  // Fetch the latest fridge image for the user's group
  void _fetchFridgeImage() {
    setState(() {
      fridgeImage = dummyFridgeImages.firstWhere(
        (image) => image.groupId == widget.user.groupId,
        orElse: () => FridgeImage(
          id: '',
          path: '',
          groupId: widget.user.groupId,
          lastUpdated: DateTime.now(),
        ),
      );
    });
  }

  // Take a new fridge photo
  Future<void> _updateFridgeImage() async {
  final XFile? image = await _picker.pickImage(source: ImageSource.camera);
  if (image == null) return;

  print("Picked image path: ${image.path}"); // Debugging

  setState(() {
    fridgeImage = FridgeImage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      path: image.path, // Ensure this path is correct
      groupId: widget.user.groupId,
      lastUpdated: DateTime.now(),
    );

    // Remove previous fridge image for this group
    dummyFridgeImages.removeWhere((img) => img.groupId == widget.user.groupId);
    dummyFridgeImages.add(fridgeImage!);
  });

  print("Stored image path: ${fridgeImage!.path}"); // Debugging
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Fridge Image")),
      body: Center(
        child: fridgeImage == null || fridgeImage!.path.isEmpty
            ? Text("No fridge image available")
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildImage(fridgeImage!.path),
                  SizedBox(height: 10),
                  Text("Last updated: ${formatlastUpdatedDate(fridgeImage!.lastUpdated.toLocal())}"),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateFridgeImage,
                    child: Text("Update Image"),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    File file = File(imagePath);

    if (!file.existsSync()) {
      return Text("Image file not found.");
    }

    try {
      return Image.file(file, height: 300, width: 300, fit: BoxFit.cover);
    } catch (e) {
      return Text("Error loading image: $e");
    }
  }
}
