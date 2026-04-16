// Only for testing database operations, to be deleted in the final version

import 'package:flutter/material.dart';
import 'package:geo_snap/models/user.dart';
import 'package:geo_snap/services/database_service.dart';

class TestingPage extends StatefulWidget {
  const TestingPage({super.key});

  @override
  State<TestingPage> createState() => _TestingPageState();
}

class _TestingPageState extends State<TestingPage> {
  String _testOutput = "No tests run yet";

  Future<void> _testSelectAllUsers() async {
    try {
      final users = await DatabaseService.selectAllUsers();
      debugPrint("\n=== TEST: selectAllUsers ===");
      if (users != null) {
        debugPrint("✓ Found ${users.length} users");
        for (var user in users) {
          debugPrint(
            "  • ${user.username} (ID: ${user.userId}, Age: ${user.age})",
          );
        }
        setState(() {
          _testOutput = "✓ Found ${users.length} users";
        });
      } else {
        debugPrint("✗ Returned null");
        setState(() {
          _testOutput = "✗ selectAllUsers returned null";
        });
      }
    } catch (e) {
      debugPrint("✗ Exception: $e");
      setState(() {
        _testOutput = "✗ Exception: $e";
      });
    }
  }

  Future<void> _testSelectAllCategories() async {
    try {
      final categories = await DatabaseService.selectAllCategories();
      debugPrint("\n=== TEST: selectAllCategories ===");
      if (categories != null) {
        debugPrint("✓ Found ${categories.length} categories");
        for (var category in categories) {
          debugPrint("  • ${category.categoryName}");
        }
        setState(() {
          _testOutput = "✓ Found ${categories.length} categories";
        });
      } else {
        debugPrint("✗ Returned null");
        setState(() {
          _testOutput = "✗ selectAllCategories returned null";
        });
      }
    } catch (e) {
      debugPrint("✗ Exception: $e");
      setState(() {
        _testOutput = "✗ Exception: $e";
      });
    }
  }

  Future<void> _testSelectAllPosts() async {
    try {
      final posts = await DatabaseService.selectAllPosts();
      debugPrint("\n=== TEST: selectAllPosts ===");
      if (posts != null) {
        debugPrint("✓ Found ${posts.length} posts");
        for (var post in posts) {
          debugPrint(
            "  • \"${post.title}\" (ID: ${post.postId}, User: ${post.userId})",
          );
        }
        setState(() {
          _testOutput = "✓ Found ${posts.length} posts";
        });
      } else {
        debugPrint("✗ Returned null");
        setState(() {
          _testOutput = "✗ selectAllPosts returned null";
        });
      }
    } catch (e) {
      debugPrint("✗ Exception: $e");
      setState(() {
        _testOutput = "✗ Exception: $e";
      });
    }
  }

  Future<void> _testInsertUser() async {
    try {
      final newUser = User(
        userId: 0,
        username: "testuser_${DateTime.now().millisecondsSinceEpoch}",
        password: "testpass123",
        age: 20,
        gender: "Other",
        topicPreference: "General",
      );
      debugPrint("\n=== TEST: insertUser ===");
      debugPrint("Inserting user: ${newUser.username}");
      await DatabaseService.insertUser(newUser);
      debugPrint("✓ User inserted successfully");
      setState(() {
        _testOutput = "✓ User inserted: ${newUser.username}";
      });
    } catch (e) {
      debugPrint("✗ Exception: $e");
      setState(() {
        _testOutput = "✗ Exception: $e";
      });
    }
  }

  Future<void> _testAuthenticateUser() async {
    try {
      debugPrint("\n=== TEST: authenticateUser ===");
      debugPrint("Authenticating: admin / admin123");
      final user = await DatabaseService.authenticateUser(
        username: "admin",
        password: "admin123",
      );
      if (user != null) {
        debugPrint("✓ Authentication successful!");
        debugPrint("  • Username: ${user.username}");
        debugPrint("  • User ID: ${user.userId}");
        debugPrint("  • Age: ${user.age}, Gender: ${user.gender}");
        setState(() {
          _testOutput = "✓ Auth successful: ${user.username}";
        });
      } else {
        debugPrint("✗ Authentication failed - credentials not found or error");
        setState(() {
          _testOutput = "✗ Auth failed";
        });
      }
    } catch (e) {
      debugPrint("✗ Exception: $e");
      setState(() {
        _testOutput = "✗ Exception: $e";
      });
    }
  }

  Future<void> _testSelectPostsWithCategoryAndUser() async {
    try {
      debugPrint("\n=== TEST: selectPostsWithCategoryAndUser ===");
      final results = await DatabaseService.selectPostsWithCategoryAndUser();
      if (results != null) {
        debugPrint(
          "✓ Found ${results.length} posts with category and user info",
        );
        for (var result in results) {
          debugPrint(
            "  • \"${result['title']}\" by ${result['username']} in ${result['categoryName']}",
          );
        }
        setState(() {
          _testOutput = "✓ Found ${results.length} posts with details";
        });
      } else {
        debugPrint("✗ Returned null");
        setState(() {
          _testOutput = "✗ selectPostsWithCategoryAndUser returned null";
        });
      }
    } catch (e) {
      debugPrint("✗ Exception: $e");
      setState(() {
        _testOutput = "✗ Exception: $e";
      });
    }
  }

  Future<void> _testClearAllData() async {
    try {
      debugPrint("\n=== TEST: clearAllData ===");
      debugPrint("Clearing all data from database...");
      await DatabaseService.clearAllData();
      debugPrint("✓ All data cleared successfully");
      setState(() {
        _testOutput = "✓ All data cleared";
      });
    } catch (e) {
      debugPrint("✗ Exception: $e");
      setState(() {
        _testOutput = "✗ Exception: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile & Database Tests"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Last Test Output:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _testOutput,
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "(Check Debug Console for detailed output)",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Read Tests",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testSelectAllUsers,
              child: const Text("Test: Select All Users"),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testSelectAllCategories,
              child: const Text("Test: Select All Categories"),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testSelectAllPosts,
              child: const Text("Test: Select All Posts"),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testSelectPostsWithCategoryAndUser,
              child: const Text("Test: Select Posts with Details (JOIN)"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Write Tests",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testInsertUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
              ),
              child: const Text(
                "Test: Insert New User",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Auth Tests",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testAuthenticateUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
              ),
              child: const Text(
                "Test: Authenticate Admin",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Destructive Tests",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testClearAllData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
              ),
              child: const Text(
                "Test: Clear All Data",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "⚠ Note: Detailed output is printed to Debug Console. Open Debug Console (Ctrl+Shift+Y or View > Debug Console) to see all test results.",
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
