/*
 Group 2
 Student names: Ka Lung Chan, Xuanyu Wang, Jaden Douglas, Nayeong Lim
 Studnet numbers: 9034150, 9020543, 9032089, 8943403
 Description: an applications that allows users to post, view, like blog posts with photos
 */
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:geo_snap/models/post.dart';
import 'package:geo_snap/models/category.dart';
import 'package:geo_snap/services/database_service.dart';

class EditPage extends StatefulWidget {
  final Post postToEdit; // The post to be edited

  const EditPage({super.key, required this.postToEdit});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late FormGroup form;

  @override
  void initState() {
    super.initState();
    // Initialize the form with the current post data
    form = FormGroup({
      'title': FormControl<String>(validators: [Validators.required]),
      'description': FormControl<String>(validators: [Validators.required]),
      'categoryId': FormControl<int>(validators: [Validators.required]),
    });

    // Fill the post data into the form
    form.patchValue({
      'title': widget.postToEdit.title,
      'description': widget.postToEdit.description,
      'categoryId': widget.postToEdit.categoryId,
    });
  }

  Future<void> _onSubmit() async {
    if (form.valid) {
      // Only able to update the text fields and category, everything else will not be changable
      Post updatedPost = Post(
        postId: widget.postToEdit.postId,
        userId: widget.postToEdit.userId,
        categoryId: form.control('categoryId').value as int,
        title: form.control('title').value as String,
        description: form.control('description').value as String,
        likesCount: widget.postToEdit.likesCount,
        latitude: widget.postToEdit.latitude,
        longitude: widget.postToEdit.longitude,
        createdAt: widget.postToEdit.createdAt,
      );

      // Call the database service method to update the post
      await DatabaseService.updatePost(updatedPost);

      if (mounted) {
        // Show a snackbar to confirm
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Post Updated!')));
        Navigator.pop(
          context,
          updatedPost,
        ); // Return the updated post to the previous page
      }
    } else {
      form.markAllAsTouched();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Post")),
      body: ReactiveForm(
        formGroup: form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ReactiveTextField<String>(
              formControlName: 'title',
              decoration: InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ReactiveTextField<String>(
              formControlName: 'description',
              decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
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
            ElevatedButton(onPressed: _onSubmit, child: Text("Save Changes")),
          ],
        ),
      ),
    );
  }
}
