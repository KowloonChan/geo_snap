/*
 Group 2
 Student names: Ka Lung Chan, Xuanyu Wang, Jaden Douglas, Nayeong Lim
 Studnet numbers: 9034150, 9020543, 9032089, 8943403
 Description: an applications that allows users to post, view, like blog posts with photos
 */
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
  final int postId;

  const PostDetailsPage({super.key, required this.postId});

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  late final Future<int?> _currentUserIdFuture;
  Map<String, dynamic>? _postData;
  int _likesCount = 0;

  @override
  void initState() {
    super.initState();
    _currentUserIdFuture = _loadCurrentUserId();
    _loadData();
  }

  Future<int?> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<void> _loadData() async {
    final allPosts = await DatabaseService.selectPostsWithCategoryAndUser();
    final post = allPosts?.firstWhere((p) => p['postId'] == widget.postId);
    if (post != null) {
      final photos = await DatabaseService.selectPhotosByPost(widget.postId);
      setState(() {
        _postData = {...post, 'photos': photos ?? []};
        _likesCount = _postData!['likesCount'];
      });
    }
  }

  bool _isOwner(int? currentUserId) {
    if (_postData == null) return false;
    final dynamic userIdValue = _postData!['userId'];
    final int? postOwnerId = userIdValue is int
        ? userIdValue
        : int.tryParse(userIdValue?.toString() ?? '');
    return currentUserId != null &&
        postOwnerId != null &&
        postOwnerId == currentUserId;
  }

  Future<void> _likePost() async {
    if (_postData == null) return;
    try {
      Post updatedPost = Post(
        postId: _postData!['postId'],
        userId: _postData!['userId'],
        categoryId: _postData!['categoryId'],
        title: _postData!['title'],
        description: _postData!['description'],
        likesCount: _likesCount + 1,
        latitude: _postData!['latitude'],
        longitude: _postData!['longitude'],
        createdAt: _postData!['createdAt'],
      );

      final result = await DatabaseService.updatePost(updatedPost);
      if (result == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to update like count")),
          );
        }
      } else {
        _loadData(); // Refresh data
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error updating like count")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_postData == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return FutureBuilder<int?>(
      future: _currentUserIdFuture,
      builder: (context, snapshot) {
        final showActions =
            snapshot.connectionState == ConnectionState.done &&
            _isOwner(snapshot.data);
        return Scaffold(
          appBar: AppBar(
            title: Text(_postData!['title']),
            actions: showActions
                ? [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditPage(postToEdit: Post.fromMap(_postData!)),
                          ),
                        );
                        if (result == true) {
                          _loadData();
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeleteConfirmationPage(
                              postId: _postData!['postId'],
                            ),
                          ),
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
                if (_postData!['photos'].isEmpty)
                  Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Icon(Icons.image_not_supported, size: 50),
                  )
                else
                  SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _postData!['photos'].length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Image.memory(
                          _postData!['photos'][index].photoBlob,
                          fit: BoxFit.cover,
                          width: 300,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _postData!['description'],
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      ListTile(
                        leading: Icon(Icons.location_on, color: Colors.blue),
                        title: Text("View Location on Map"),
                        subtitle: Text(
                          "Lat: ${_postData!['latitude']}, Lon: ${_postData!['longitude']}",
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapLocationPage(
                                lat: _postData!['latitude'],
                                lon: _postData!['longitude'],
                                title: _postData!['title'],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 10),
                      ListTile(
                        leading: Icon(Icons.favorite, color: Colors.red),
                        title: Text("Likes"),
                        subtitle: Text("$_likesCount people liked this"),
                        trailing: IconButton(
                          icon: Icon(Icons.thumb_up, color: Colors.blue),
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
