import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geo_snap/services/database_service.dart';
import 'package:geo_snap/models/photo.dart';
import 'package:geo_snap/models/post.dart';
import 'package:geo_snap/pages/edit.dart';
import 'package:geo_snap/pages/delete_confirmation.dart';
import 'map_location_page.dart';

class PostDetailsPage extends StatefulWidget {
  final Map<String, dynamic> postData;

  const PostDetailsPage({super.key, required this.postData});

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  late final Future<int?> _currentUserIdFuture;
  late int _likesCount;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.postData['likesCount'] as int;
    _currentUserIdFuture = _loadCurrentUserId();
  }

  Future<int?> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  bool _isOwner(int? currentUserId) {
    final dynamic userIdValue = widget.postData['userId'];
    final int? postOwnerId = userIdValue is int
        ? userIdValue
        : int.tryParse(userIdValue?.toString() ?? '');
    return currentUserId != null &&
        postOwnerId != null &&
        postOwnerId == currentUserId;
  }

  Future<void> _likePost() async {
    setState(() {
      _likesCount++;
    });

    try {
      Post updatedPost = Post(
        postId: widget.postData['postId'],
        userId: widget.postData['userId'],
        categoryId: widget.postData['categoryId'],
        title: widget.postData['title'],
        description: widget.postData['description'],
        likesCount: _likesCount,
        latitude: widget.postData['latitude'],
        longitude: widget.postData['longitude'],
        createdAt: widget.postData['createdAt'],
      );

      final result = await DatabaseService.updatePost(updatedPost);
      if (result == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to update like count")),
          );
        }
        // Revert the like count on failure
        setState(() {
          _likesCount--;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error updating like count")),
        );
      }
      // Revert the like count on error
      setState(() {
        _likesCount--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: _currentUserIdFuture,
      builder: (context, snapshot) {
        final showActions =
            snapshot.connectionState == ConnectionState.done &&
            _isOwner(snapshot.data);
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.postData['title']),
            actions: showActions
                ? [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditPage(
                              postToEdit: Post.fromMap(widget.postData),
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        DeleteConfirmationDialog.show(
                          context,
                          widget.postData['postId'],
                        );
                      },
                    ),
                  ]
                : [],
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
                        leading: const Icon(
                          Icons.location_on,
                          color: Colors.blue,
                        ),
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
                      const SizedBox(height: 10),
                      ListTile(
                        leading: const Icon(Icons.favorite, color: Colors.red),
                        title: const Text("Likes"),
                        subtitle: Text("$_likesCount people liked this"),
                        trailing: IconButton(
                          icon: const Icon(Icons.thumb_up, color: Colors.blue),
                          onPressed: _likePost,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
