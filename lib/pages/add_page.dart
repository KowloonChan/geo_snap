import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:reactive_forms/reactive_forms.dart';

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

  Future<void> _takePhoto() async {
    try {
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
        _imagesBytesList.add(optimizedBytes);
      });
    } catch (e) {
      debugPrint("Error taking photo: $e");
    }
  }

  Future<void> _onSubmit() async {
    if (form.valid) {
      final Position? position = await _getCurrentPosition();

      Post newPost = Post(
        userId: 1, // 模拟当前登录用户
        categoryId: form.control('categoryId').value as int,
        title: form.control('title').value as String,
        description: form.control('description').value as String,
        likesCount: 0,
        latitude: position?.latitude ?? 0.0,
        longitude: position?.longitude ?? 0.0,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      int? insertedPostId = await DatabaseService.insertPost(newPost);

      if (insertedPostId != null && _imagesBytesList.isNotEmpty) {
        for (var bytes in _imagesBytesList) {
          await DatabaseService.insertPhoto(
            Photo(postId: insertedPostId, photoBlob: bytes),
          );
        }
      }

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

  Future<Position?> _getCurrentPosition() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

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

  Uint8List _optimizeImageBytes(Uint8List bytes) {
    final img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return bytes;
    }

    final img.Image resized = decoded.width > 1280
        ? img.copyResize(decoded, width: 1280)
        : decoded;
    final List<int> jpg = img.encodeJpg(resized, quality: 70);
    return Uint8List.fromList(jpg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Post")),
      body: ReactiveForm(
        formGroup: form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
                                _imagesBytesList[index],
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
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Icon(
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickMultiImages,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text("Select Photos"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Take Photo"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ReactiveTextField<String>(
              formControlName: 'title',
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ReactiveTextField<String>(
              formControlName: 'description',
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ReactiveDropdownField<int>(
              formControlName: 'categoryId',
              decoration: const InputDecoration(
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _onSubmit,
              child: const Text("Publish Post"),
            ),
          ],
        ),
      ),
    );
  }
}
