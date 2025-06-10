import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:inner_shadow_widget/inner_shadow_widget.dart';

class EditProfilePhotoScreen extends StatefulWidget {
  final String initialProfileImage;

  const EditProfilePhotoScreen({
    super.key,
    required this.initialProfileImage,
  });

  @override
  State<EditProfilePhotoScreen> createState() => _EditProfilePhotoScreenState();
}

class _EditProfilePhotoScreenState extends State<EditProfilePhotoScreen> {
  late String profileImagePath;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    profileImagePath = widget.initialProfileImage;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Handle any errors
      debugPrint('Error picking image: $e');
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Custom colors matching the design
    final primaryBlue = const Color(0xFF335AAC);

    return Scaffold(
      backgroundColor: primaryBlue,
      // No standard AppBar - we'll create a custom one
      body: Stack(
        children: [
          // Background white for AppBar area
          Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height * 0.30,
          ),
          // Main content
          Column(
            children: [
              // Custom AppBar
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button with logo
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.black54),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(width: 10),
                          Image.asset(
                            'assets/logo/salvus-logo.png', // Path to logo PNG file
                            height: 60,
                            width: 110,
                          ),
                        ],
                      ),
                      // Menu button with circle decoration
                      InnerShadow(
                        blur: 4,
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, 4),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.menu, color: Colors.black54),
                            onPressed: () {},
                            padding: const EdgeInsets.all(10),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // Content area with blue card starting from middle
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // Blue card with rounded corners
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(46),
                        ),
                        child: Column(
                          children: [
                            // User Profile Header
                            Padding(
                              padding: const EdgeInsets.only(top: 25.0),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Shadow for text
                                  Text(
                                    "User Profile",
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.2),
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // Main text with slightly offset for shadow effect
                                  const Text(
                                    "User Profile",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Edit Photo Profile text with icon
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.photo_camera_outlined, color: Colors.white),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Edit Photo Profile',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Profile image with circular border
                            Center(
                              child: Stack(
                                children: [
                                  Container(
                                    height: 150,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 4),
                                    ),
                                    child: ClipOval(
                                      child: _imageFile != null
                                          ? Image.file(
                                              _imageFile!,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              profileImagePath,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Edit Photo Profile button
                            ElevatedButton.icon(
                              icon: const Icon(Icons.photo_camera, color: Color(0xFF335AAC)),
                              label: const Text(
                                'Edit Photo Profile',
                                style: TextStyle(
                                  color: Color(0xFF335AAC),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: _showImageSourceActionSheet,
                            ),

                            const SizedBox(height: 20),

                            // Save button
                            ElevatedButton.icon(
                              icon: const Icon(Icons.save, color: Colors.white),
                              label: const Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {
                                // Here you would typically save the image to storage
                                // and update the user profile
                                Navigator.of(context).pop(_imageFile != null ? _imageFile!.path : profileImagePath);
                              },
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}