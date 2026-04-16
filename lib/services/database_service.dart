/*
 Group 2
 Student names: Ka Lung Chan, Xuanyu Wang, Jaden Douglas, Nayeong Lim
 Studnet numbers: 9034150, 9020543, 9032089, 8943403
 Description: an applications that allows users to post, view, like blog posts with photos
 */
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:geo_snap/models/category.dart';
import 'package:geo_snap/models/photo.dart';
import 'package:geo_snap/models/post.dart';
import 'package:geo_snap/models/user.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> getDatabase() async {
    // need path_provider for this
    Directory dbDirectory = await getApplicationDocumentsDirectory();
    debugPrint(dbDirectory.toString());
    String path = "trueReview.db";

    if (_db == null) {
      debugPrint("_db is null, creating a new one or opening an existing");
      try {
        _db = await openDatabase(
          path,
          version: 1,
          onCreate: (db, version) async {
            // Create category tables
            await db.execute('''
            CREATE TABLE categories (
              categoryId INTEGER PRIMARY KEY AUTOINCREMENT,
              categoryName TEXT NOT NULL UNIQUE
            )
          ''');

            debugPrint("categories tables created");

            // Create user tables
            await db.execute('''
            CREATE TABLE users (
              userId INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT NOT NULL UNIQUE,
              password TEXT NOT NULL,
              age INTEGER NOT NULL,
              gender TEXT NOT NULL,
              topicPreference TEXT NOT NULL
            )
          ''');

            debugPrint("users tables created");

            // Create post tables
            await db.execute('''
            CREATE TABLE posts (
              postId INTEGER PRIMARY KEY AUTOINCREMENT,
              userId INTEGER NOT NULL,
              categoryId INTEGER NOT NULL,
              title TEXT NOT NULL,
              description TEXT NOT NULL,
              likesCount INTEGER NOT NULL DEFAULT 0,
              latitude REAL NOT NULL,
              longitude REAL NOT NULL,
              createdAt INTEGER NOT NULL,
              FOREIGN KEY (userId) REFERENCES users(userId)
                ON DELETE CASCADE ON UPDATE CASCADE,
              FOREIGN KEY (categoryId) REFERENCES categories(categoryId)
                ON DELETE RESTRICT ON UPDATE CASCADE
            )
          ''');

            debugPrint("posts tables created");

            // Create photo tables
            await db.execute('''
            CREATE TABLE photos (
              photoId INTEGER PRIMARY KEY AUTOINCREMENT,
              postId INTEGER NOT NULL,
              photoBlob BLOB NOT NULL,
              photoCaption TEXT,
              FOREIGN KEY (postId) REFERENCES posts(postId)
                ON DELETE CASCADE ON UPDATE CASCADE
            )
          ''');

            debugPrint("photos tables created");

            // Seed initial categories and an user
            Batch batch = await db.batch();
            for (String categoryName in BlogCategory.categoryNames) {
              batch.insert('categories', {'categoryName': categoryName});
            }
            batch.insert('users', {
              'username': 'admin',
              'password': 'admin123',
              'age': 25,
              'gender': 'Other',
              'topicPreference': 'General',
            });
            await batch.commit();
            debugPrint(
              "Inserted initial data into categories and users tables",
            );
          },
          onOpen: (db) {
            debugPrint('Database opened');
          },
        );
      } catch (e) {
        debugPrint("Fatal error: can't proceed - terminating: $e");
        exit(0);
      }
    }

    return _db!;
    // also works
    // return Future.value(_db);
  }

  // ----------------- CRUD for Categories -----------------
  // static Future<int> insertCategory(BlogCategory category) async {
  //   var db = await getDatabase();
  //   return db.insert('categories', category.toMap());
  // }

  static Future<List<BlogCategory>?> selectAllCategories() async {
    try {
      var db = await getDatabase();
      var data = await db.query('categories', orderBy: 'categoryName ASC');
      debugPrint("All categories retrieved successfully");
      return data.map(BlogCategory.fromMap).toList();
    } catch (e) {
      debugPrint("ERROR in selectAllCategories: $e");
      return null;
    }
  }

  // ----------------- CRUD for User -----------------
  // For testing only
  static Future<void> insertUser(User user) async {
    try {
      var db = await getDatabase();
      int userId = await db.insert('users', user.toMap());
      debugPrint("User inserted successfully with ID: $userId");
    } catch (e) {
      debugPrint("ERROR in insertUser: $e");
    }
  }

  // Function for testing only
  static Future<List<User>?> selectAllUsers() async {
    try {
      var db = await getDatabase();
      var data = await db.query('users', orderBy: 'username ASC');
      debugPrint("All users retrieved successfully");
      return data.map(User.fromMap).toList();
    } catch (e) {
      debugPrint("ERROR in selectAllUsers: $e");
      return null;
    }
  }

  static Future<User?> authenticateUser({
    required String username,
    required String password,
  }) async {
    try {
      var db = await getDatabase();
      var data = await db.query(
        'users',
        where: 'username = ? AND password = ?',
        whereArgs: [username, password],
        limit: 1,
      );
      if (data.isNotEmpty) {
        debugPrint("User authenticated successfully: $username");
        return User.fromMap(data.first);
      } else {
        debugPrint("Authentication failed for user: $username");
        return null;
      }
    } catch (e) {
      debugPrint("ERROR in authenticateUser: $e");
      return null;
    }
  }

  // For testing only - get the first user (admin) and set it as the current user
  // TODO: it should select the login user based on the authenticateUser() result
  static Future<User?> getUser() async {
    try {
      var db = await getDatabase();
      var data = await db.query(
        'users',
        where: 'userId = ?',
        whereArgs: [1],
        limit: 1,
      );
      debugPrint("First user retrieved successfully");
      return data.isNotEmpty ? User.fromMap(data.first) : null;
    } catch (e) {
      debugPrint("ERROR in getUser: $e");
      return null;
    }
  }

  // Update user information in the database when the user edits their profile
  static Future<int?> updateUser(User user) async {
    try {
      var db = await getDatabase();
      return db.update(
        'users',
        user.toMap(),
        where: 'userId = ?',
        whereArgs: [user.userId],
      );
    } catch (e) {
      debugPrint("ERROR in updateUser: $e");
      return null;
    }
  }

  // ----------------- CRUD for Post -----------------
  static Future<int?> insertPost(Post post) async {
    try {
      var db = await getDatabase();
      return db.insert('posts', post.toMap());
    } catch (e) {
      debugPrint("ERROR in insertPost: $e");
      return null;
    }
  }

  static Future<int?> updatePost(Post post) async {
    try {
      var db = await getDatabase();
      return db.update(
        'posts',
        post.toMap(),
        where: 'postId = ?',
        whereArgs: [post.postId],
      );
    } catch (e) {
      debugPrint("ERROR in updatePost: $e");
      return null;
    }
  }

  static Future<int?> deletePost(int postId) async {
    try {
      var db = await getDatabase();
      return db.delete('posts', where: 'postId = ?', whereArgs: [postId]);
    } catch (e) {
      debugPrint("ERROR in deletePost: $e");
      return null;
    }
  }

  static Future<List<Post>?> selectAllPosts() async {
    try {
      var db = await getDatabase();
      var data = await db.query('posts', orderBy: 'createdAt DESC');
      return data.map(Post.fromMap).toList();
    } catch (e) {
      debugPrint("ERROR in selectAllPosts: $e");
      return null;
    }
  }

  static Future<List<Post>?> selectPostsByUser(int userId) async {
    try {
      var db = await getDatabase();
      var data = await db.query(
        'posts',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'createdAt DESC',
      );
      return data.map(Post.fromMap).toList();
    } catch (e) {
      debugPrint("ERROR in selectPostsByUser: $e");
      return null;
    }
  }

  static Future<List<Post>?> selectPostsByCategory(int categoryId) async {
    try {
      var db = await getDatabase();
      var data = await db.query(
        'posts',
        where: 'categoryId = ?',
        whereArgs: [categoryId],
        orderBy: 'createdAt DESC',
      );
      return data.map(Post.fromMap).toList();
    } catch (e) {
      debugPrint("ERROR in selectPostsByCategory: $e");
      return null;
    }
  }

  // ----------------- CRUD for Photo -----------------
  static Future<int?> insertPhoto(Photo photo) async {
    try {
      var db = await getDatabase();
      return db.insert('photos', photo.toMap());
    } catch (e) {
      debugPrint("ERROR in insertPhoto: $e");
      return null;
    }
  }

  static Future<int?> deletePhoto(int photoId) async {
    try {
      var db = await getDatabase();
      return db.delete('photos', where: 'photoId = ?', whereArgs: [photoId]);
    } catch (e) {
      debugPrint("ERROR in deletePhoto: $e");
      return null;
    }
  }

  static Future<List<Photo>?> selectPhotosByPost(int postId) async {
    try {
      var db = await getDatabase();
      var data = await db.query(
        'photos',
        where: 'postId = ?',
        whereArgs: [postId],
        orderBy: 'photoId ASC',
      );
      return data.map(Photo.fromMap).toList();
    } catch (e) {
      debugPrint("ERROR in selectPhotosByPost: $e");
      return null;
    }
  }

  // ----------------- Delete everything -----------------
  static Future<void> clearAllData() async {
    try {
      var db = await getDatabase();
      await db.delete('photos');
      await db.delete('posts');
      await db.delete('users');
      await db.delete('categories');
      debugPrint("All data cleared successfully");
    } catch (e) {
      debugPrint("ERROR in clearAllData: $e");
    }
  }

  static Future<List<Map<String, dynamic>>?>
  selectPostsWithCategoryAndUser() async {
    try {
      var db = await getDatabase();
      return db.rawQuery('''
        SELECT
          p.postId,
        p.userId,
        u.username,
        p.categoryId,
        c.categoryName,
        p.title,
        p.description,
        p.likesCount,
        p.latitude,
        p.longitude,
        p.createdAt
      FROM posts p
      INNER JOIN users u ON u.userId = p.userId
      INNER JOIN categories c ON c.categoryId = p.categoryId
      ORDER BY p.createdAt DESC
    ''');
    } catch (e) {
      debugPrint("ERROR in selectPostsWithCategoryAndUser: $e");
      return null;
    }
  }

  static Future<void> seedDemoPhoto(int postId, Uint8List photoBlob) async {
    try {
      await insertPhoto(
        Photo(postId: postId, photoBlob: photoBlob, photoCaption: 'Demo photo'),
      );
      debugPrint("Demo photo inserted successfully for postId: $postId");
    } catch (e) {
      debugPrint("ERROR in seedDemoPhoto: $e");
    }
  }
}
