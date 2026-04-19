/*
 Group 2
 Student names: Ka Lung Chan, Xuanyu Wang, Jaden Douglas, Nayeong Lim
 Studnet numbers: 9034150, 9020543, 9032089, 8943403
 Description: an applications that allows users to post, view, like blog posts with photos
 */
import 'package:flutter/material.dart';
import 'package:geo_snap/services/database_service.dart';

class DeleteConfirmationPage extends StatelessWidget {
  final int postId;

  DeleteConfirmationPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Delete Post')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Are you sure you want to delete this post? This action cannot be undone.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
                      'Delete',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      // Call the delete function from the database service
                      await DatabaseService.deletePost(postId);
                      // After deletion, pop back to the previous screen and show a confirmation message
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        // Show a snackbar to confirm deletion
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Post deleted successfully')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
