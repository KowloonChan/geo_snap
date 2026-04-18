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
  final Post postToEdit; // 必须传入要编辑的帖子

  const EditPage({super.key, required this.postToEdit});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late FormGroup form;

  @override
  void initState() {
    super.initState();
    form = FormGroup({
      'title': FormControl<String>(validators: [Validators.required]),
      'description': FormControl<String>(validators: [Validators.required]),
      'categoryId': FormControl<int>(validators: [Validators.required]),
    });

    // 将传入的帖子数据填充到表单中
    form.patchValue({
      'title': widget.postToEdit.title,
      'description': widget.postToEdit.description,
      'categoryId': widget.postToEdit.categoryId,
    });
  }

  Future<void> _onSubmit() async {
    if (form.valid) {
      // 保持原有 postId, userId, likesCount, location 和 createdAt 不变，只更新文本和类别
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

      await DatabaseService.updatePost(updatedPost);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Post Updated!')));
        Navigator.pop(context); // 更新完成后返回上一页（详情页或主页）
      }
    } else {
      form.markAllAsTouched();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Post")),
      body: ReactiveForm(
        formGroup: form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
