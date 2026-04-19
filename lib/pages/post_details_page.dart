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
  final int
  postId; // The ID passed from the previous screen to know which post to load.

  const PostDetailsPage({super.key, required this.postId});

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

//This manages the loading of post data, checking if the current user is the owner of the post, and handling the like functionality.
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

  // This method retrieves the current user's ID from shared preferences,
  //which is used to determine if the user is the owner of the post and to manage like functionality.
  Future<int?> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  // This method loads the post data from the database to display this information on the UI.
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

  // This method checks if the current user is the owner of the post by comparing the user ID from the post data
  //with the current user's ID.
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

  //This method handles the logic for liking a post, including updating the like count locally and in the database,
  // and providing feedback to the user if the operation fails.
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

      // The like count is incremented locally first to provide immediate feedback to the user,
      //and then the updated post is sent to the database to update the like count persistently
      final result = await DatabaseService.updatePost(updatedPost);
      if (result == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to update like count")),
          );
        }
      } else {
        _loadData(); // Refresh the data
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Error updating like count",
            ), // Show a generic error message if something goes wrong during the like operation.
          ),
        );
      }
    }
  }

  @override
  // The main build method that constructs the UI of the post details page, including the post's title, description, photos, location, and like functionality.
  Widget build(BuildContext context) {
    if (_postData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // The FutureBuilder is used to determine if the current user is the owner of the post,
    //which controls whether the edit and delete buttons are shown in the app bar.
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
                    // If the current user is the owner of the post, show edit and delete buttons in the app bar.
                    IconButton(
                      icon: const Icon(Icons.edit),
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
                    // The delete button navigates to a confirmation page before actually deleting the post.
                    IconButton(
                      icon: const Icon(Icons.delete),
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
          // The body of the page displays the post's photos in a horizontal list,
          //the description, location information with a link to view on the map, and the like count with a button to like the post.
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_postData!['photos'].isEmpty)
                  Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 50),
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
                // The description, location, and like information are displayed below the photos in a column layout.
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _postData!['description'],
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
                          "Lat: ${_postData!['latitude']}, Lon: ${_postData!['longitude']}",
                        ),
                        onTap: () {
                          // When the location tile is tapped, it navigates to the MapLocationPage,
                          //passing the latitude, longitude, and title of the post to display the location on a map.
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
                      // The like section shows the number of likes and includes a button to like the post,
                      // which updates the like count in the database and refreshes the UI.
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
