import 'package:flutter/material.dart';
import 'package:geo_snap/services/database_service.dart';
import 'package:geo_snap/pages/post_details_page.dart'; // Ensure correct path

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>?>(
      // Use the join query from your DatabaseService to get usernames and titles
      future: DatabaseService.selectPostsWithCategoryAndUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No posts found."));
        }

        final posts = snapshot.data!;

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            // Custom Widget for Level 4 Rubric
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 4,
              child: ListTile(
                title: Text(
                  post['title'] ?? 'Untitled',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("By: ${post['username']} • ${post['categoryName']}"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to your Post Details screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailsPage(postData: post),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}