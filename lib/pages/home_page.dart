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

class _HomePageState extends State<HomePage> {
  String? selectedCategory = 'All';
  int _refreshCounter = 0;

  void _refreshData() {
    setState(() {
      _refreshCounter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: selectedCategory,
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
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _refreshData();
            },
            child: FutureBuilder<List<Map<String, dynamic>>?>(
              key: ValueKey(_refreshCounter),
              future: DatabaseService.selectPostsWithCategoryAndUser(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No posts found."));
                }

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
                          post['title']?.toString() ?? 'Untitled',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "By: ${post['username']} • ${post['categoryName']}",
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
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
              },
            ),
          ),
        ),
      ],
    );
  }
}
