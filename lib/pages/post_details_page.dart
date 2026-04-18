import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Add this
import 'package:image/image.dart' as img;
import 'package:geo_snap/services/database_service.dart';
import 'package:geo_snap/models/photo.dart';
import 'map_location_page.dart';

class PostDetailsPage extends StatefulWidget {
  final Map<String, dynamic> postData;

  const PostDetailsPage({super.key, required this.postData});

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final ImagePicker _picker = ImagePicker();

  // Function to capture and compress image
  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 25,
        maxWidth: 1000,
      );

      if (image == null) {
        debugPrint('Image capture cancelled or failed before file creation.');
        return;
      }

      final int? postId = widget.postData['postId'] as int?;
      if (postId == null) {
        debugPrint('postId is null in postData: ${widget.postData}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to attach photo to this post.'),
            ),
          );
        }
        return;
      }

      final bytes = await image.readAsBytes();
      final optimizedBytes = _optimizeImageBytes(bytes);
      final int? photoId = await DatabaseService.insertPhoto(
        Photo(postId: postId, photoBlob: optimizedBytes),
      );

      debugPrint('insertPhoto result photoId: $photoId for postId: $postId');

      if (photoId == null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to save photo.')));
      }

      // Refresh the UI to show the new photo
      setState(() {});
    } catch (e) {
      debugPrint('Error taking photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error capturing photo.')));
      }
    }
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
      appBar: AppBar(
        title: Text(widget.postData['title']),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo),
            onPressed: _takePhoto,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<Photo>?>(
              future: DatabaseService.selectPhotosByPost(
                widget.postData['postId'],
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  debugPrint('Error loading photos: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  );
                }
                return SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Image.memory(
                        snapshot.data![index].photoBlob,
                        fit: BoxFit.cover,
                        width: 300,
                      ),
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.postData['description'],
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.blue),
                    title: const Text("View Location on Map"),
                    subtitle: Text(
                      "Lat: ${widget.postData['latitude']}, Lon: ${widget.postData['longitude']}",
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapLocationPage(
                            lat: widget.postData['latitude'],
                            lon: widget.postData['longitude'],
                            title: widget.postData['title'],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
