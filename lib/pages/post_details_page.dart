import 'package:flutter/material.dart';
import 'package:geo_snap/services/database_service.dart';
import 'package:geo_snap/models/photo.dart';
import 'map_location_page.dart';

class PostDetailsPage extends StatelessWidget {
  final Map<String, dynamic> postData;

  const PostDetailsPage({super.key, required this.postData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(postData['title'])),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery (Level 4: Storing/Displaying images from DB)
            FutureBuilder<List<Photo>?>(
              future: DatabaseService.selectPhotosByPost(postData['postId']),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(height: 250, color: Colors.grey);
                }
                return SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) => Image.memory(
                      snapshot.data![index].photoBlob,
                      fit: BoxFit.cover,
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
                  Text(postData['description'], style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  // Link to Map Screen
                  ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.blue),
                    title: const Text("View Location on Map"),
                    subtitle: Text("Lat: ${postData['latitude']}, Lon: ${postData['longitude']}"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapLocationPage(
                            lat: postData['latitude'],
                            lon: postData['longitude'],
                            title: postData['title'],
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