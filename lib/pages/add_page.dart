/*
 Group 2
 Student names: Ka Lung Chan, Xuanyu Wang, Jaden Douglas, Nayeong Lim
 Studnet numbers: 9034150, 9020543, 9032089, 8943403
 Description: an applications that allows users to post, view, like blog posts with photos
 */
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:geo_snap/models/post.dart';
import 'package:geo_snap/models/photo.dart';
import 'package:geo_snap/models/category.dart';
import 'package:geo_snap/services/database_service.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final List<Uint8List> _imagesBytesList = [];
  final ImagePicker _picker = ImagePicker();
  late FormGroup form;

  @override
  void initState() {
    super.initState();
    form = FormGroup({
      'title': FormControl<String>(validators: [Validators.required]),
      'description': FormControl<String>(validators: [Validators.required]),
      'categoryId': FormControl<int>(validators: [Validators.required]),
    });
  }

  // Method to pick multiple images from gallery on testing devices
  // This method used image_picker's pickMultiImage
  Future<void> _pickMultiImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        for (var image in images) {
          final Uint8List bytes = await image.readAsBytes();
          final Uint8List optimizedBytes = _optimizeImageBytes(bytes);
          setState(() {
            _imagesBytesList.add(optimizedBytes);
          });
        }
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
    }
  }

  // Method to take photo using camera on real devices
  Future<void> _takePhoto() async {
    try {
      // Open camera to take photo by image_picker's pickImage
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 25,
        maxWidth: 1000,
      );

      if (image == null) {
        return;
      }

      final Uint8List bytes = await image.readAsBytes();
      final Uint8List optimizedBytes = _optimizeImageBytes(bytes);
      setState(() {
        // Add image to the list while refreshing the UI
        _imagesBytesList.add(optimizedBytes);
      });
    } catch (e) {
      debugPrint("Error taking photo: $e");
    }
  }

  // Method to submit the form and create a new post
  Future<void> _onSubmit() async {
    if (form.valid) {
      final Position? position = await _getCurrentPosition();
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getInt('userId') ?? 1;

      // Create a Post object with the form data and current location(if not provided then set it to 0.0)
      // Set likesCount to 0 for new posts
      // Set createdAt to current timestamp
      Post newPost = Post(
        userId: currentUserId,
        categoryId: form.control('categoryId').value as int,
        title: form.control('title').value as String,
        description: form.control('description').value as String,
        likesCount: 0,
        latitude: position?.latitude ?? 0.0,
        longitude: position?.longitude ?? 0.0,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      // Call the database service method to insert the new post and get the inserted postId
      int? insertedPostId = await DatabaseService.insertPost(newPost);

      // if the post is inserted successfully, and there are images to upload, insert each image into the photos table with the corresponding postId as foreign key
      if (insertedPostId != null && _imagesBytesList.isNotEmpty) {
        for (var bytes in _imagesBytesList) {
          // Calling the database service method to insert the photo
          await DatabaseService.insertPhoto(
            Photo(postId: insertedPostId, photoBlob: bytes),
          );
        }
      }

      // after submission, display a snackbar and reset the form and clear the selected images
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Post Created!')));
        form.reset();
        setState(() {
          _imagesBytesList.clear();
        });
      }
    } else {
      form.markAllAsTouched();
    }
  }

  // This method is used to get the current location of the user using geolocator package
  Future<Position?> _getCurrentPosition() async {
    // Check if location services are enabled
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // If not enabled, return null
    if (!serviceEnabled) {
      return null;
    }
    // Check location permissions and request it to the user if it's not granted
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  // This method is to make sure the image size is reduced before uploading to the database
  Uint8List _optimizeImageBytes(Uint8List bytes) {
    final img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return bytes;
    }

    // Check if the image width is greater than 1280 pixels
    // if so, resize it to 1280 while maintaining the aspect ratio.
    final img.Image resized = decoded.width > 1280
        ? img.copyResize(decoded, width: 1280)
        : decoded;
    final List<int> jpg = img.encodeJpg(resized, quality: 70);
    return Uint8List.fromList(jpg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Post")),
      body: ReactiveForm(
        formGroup: form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Display the selected images in list view
            if (_imagesBytesList.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imagesBytesList.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: Image.memory(
                                _imagesBytesList[index], // Display the image from _imagesBytesList
                              ).image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 12,
                          top: 4,
                          child: GestureDetector(
                            onTap: () => setState(
                              () => _imagesBytesList.removeAt(index),
                            ),
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Icon(
                                // A small 'X' icon to delete the image
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            SizedBox(height: 16),
            // Two buttons to select images from gallery or take photo using camera
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickMultiImages,
                    icon: Icon(Icons.add_photo_alternate),
                    label: Text("Select Photos"),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: Icon(Icons.camera_alt),
                    label: Text("Take Photo"),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ReactiveTextField<String>(
              formControlName: 'title',
              decoration: InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // Text field for description
            ReactiveTextField<String>(
              formControlName: 'description',
              decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            // Dropdown for category selection
            ReactiveDropdownField<int>(
              formControlName: 'categoryId',
              decoration: InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
              items: BlogCategory.categoryNames.asMap().entries.map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key + 1,
                  child: Text(entry.value),
                );
              }).toList(),
            ),
            SizedBox(height: 24),
            // Submit button
            ElevatedButton(onPressed: _onSubmit, child: Text("Publish Post")),
          ],
        ),
      ),
    );
  }
}
