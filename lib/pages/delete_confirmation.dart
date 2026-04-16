import 'package:flutter/material.dart';
import 'package:geo_snap/services/database_service.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final int postId;

  const DeleteConfirmationDialog({super.key, required this.postId});

  // 提供一个静态方法方便其他页面直接调用
  static Future<void> show(BuildContext context, int postId) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          DeleteConfirmationDialog(postId: postId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Post'),
      content: const Text(
        'Are you sure you want to delete this post? This action cannot be undone.',
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop(); // 关闭弹窗
          },
        ),
        TextButton(
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
          onPressed: () async {
            // 执行数据库删除操作 (由于外键设置了 CASCADE，相关的照片也会被一并删除)
            await DatabaseService.deletePost(postId);

            if (context.mounted) {
              Navigator.of(context).pop(); // 1. 关闭弹窗
              Navigator.of(context).pop(); // 2. 退出详情页，返回主页

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post deleted successfully')),
              );
            }
          },
        ),
      ],
    );
  }
}
