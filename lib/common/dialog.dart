
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ImagePicker _picker = ImagePicker();

  // Method to open the camera
  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      print('Photo taken: ${photo.path}');
    }
  }

  // Method to open the gallery
  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      print('Image selected from gallery: ${image.path}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
          ),
          style: const TextStyle(color: Colors.black),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Take a photo and gallery options container
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 1.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.camera_alt, size: 30),
                      onPressed: _takePhoto,
                    ),
                    const Text("Take a photo", style: TextStyle(fontSize: 12)),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo, size: 30),
                      onPressed: _pickFromGallery,
                    ),
                    const Text("Upload from gallery", style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          // ListView for search suggestions
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8.0),
              children: [
                ListTile(
                  title: const Text("Kika Vargas"),
                  subtitle: const Text("Designer"),
                  leading: const Icon(Icons.history, color: Colors.grey),
                  onTap: () {
                    print("Kika Vargas selected");
                  },
                ),
                ListTile(
                  title: const Text("Maison Margiela"),
                  subtitle: const Text("Designer"),
                  leading: const Icon(Icons.search, color: Colors.grey),
                  onTap: () {
                    print("Maison Margiela selected");
                  },
                ),
                ListTile(
                  title: const Text("Marla Aaron"),
                  subtitle: const Text("Designer"),
                  leading: const Icon(Icons.search, color: Colors.grey),
                  onTap: () {
                    print("Marla Aaron selected");
                  },
                ),
                ListTile(
                  title: const Text("Savette"),
                  subtitle: const Text("Designer"),
                  leading: const Icon(Icons.search, color: Colors.grey),
                  onTap: () {
                    print("Savette selected");
                  },
                ),
                ListTile(
                  title: const Text("CALL IT BY YOUR NAME"),
                  subtitle: const Text("Designer"),
                  leading: const Icon(Icons.search, color: Colors.grey),
                  onTap: () {
                    print("CALL IT BY YOUR NAME selected");
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}