/*
 Group 2
 Student names: Ka Lung Chan, Xuanyu Wang, Jaden Douglas, Nayeong Lim
 Studnet numbers: 9034150, 9020543, 9032089, 8943403
 Description: an applications that allows users to post, view, like blog posts with photos
 */
import 'package:flutter/material.dart';
import 'package:geo_snap/services/database_service.dart';
import 'package:geo_snap/pages/post_details_page.dart'; // Ensure correct path
import 'package:geo_snap/models/category.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// The HomePage widget displays a list of blog posts with a category filter and pull-to-refresh functionality.
class _HomePageState extends State<HomePage> {
  String? selectedCategory = 'All';
  int _refreshCounter = 0;

  void _refreshData() {
    setState(() {
      _refreshCounter++;
    });
  }

  @override
  // The build method constructs the UI of the HomePage, including a dropdown for category selection and a list of posts.
  Widget build(BuildContext context) {
    // The Column widget arranges the dropdown and the list of posts vertically.
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: selectedCategory,
            // 修复点：添加泛型并确保 toString()，解决类型报错
            items: ['All', ...BlogCategory.categoryNames]
                .map<DropdownMenuItem<String>>((dynamic value) {
                  return DropdownMenuItem<String>(
                    value: value.toString(),
                    child: Text(value.toString()),
                  );
                })
                .toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedCategory = newValue;
              });
            },
          ),
        ),
        // The Expanded widget allows the list of posts to take up the remaining space in the column.
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _refreshData();
            },
            // The FutureBuilder widget is used to fetch and display the list of posts from the database.
            child: FutureBuilder<List<Map<String, dynamic>>?>(
              key: ValueKey(_refreshCounter),
              future: DatabaseService.selectPostsWithCategoryAndUser(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No posts found."));
                }

                // The posts are filtered based on the selected category,
                //and a ListView.builder is used to display the list of posts.
                final posts = snapshot.data!;
                final filteredPosts = selectedCategory == 'All'
                    ? posts
                    : posts
                          .where(
                            (post) => post['categoryName'] == selectedCategory,
                          )
                          .toList();

                return ListView.builder(
                  itemCount: filteredPosts.length,
                  itemBuilder: (context, index) {
                    final post = filteredPosts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      elevation: 4,
                      child: ListTile(
                        title: Text(
                          // 修复点：安全转换为 String
                          post['title']?.toString() ?? 'Untitled',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "By: ${post['username']} • ${post['categoryName']}",
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PostDetailsPage(postId: post['postId']),
                            ),
                          ).then((_) => _refreshData());
                        },
                      ),
                    );
                  },
                );
              }, // 闭合 builder
            ), // 闭合 FutureBuilder
          ), // 闭合 RefreshIndicator
        ), // 闭合 Expanded
      ], // 闭合 Column 的 children
    ); // 闭合 Column
  }
}
