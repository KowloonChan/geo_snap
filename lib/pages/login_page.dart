/*
Group 2
Student names: Ka Lung Chan, Xuanyu Wang, Jaden Douglas, Nayeong Lim
Studnet numbers: 9034150, 9020543, 9032089, 8943403
Description: An applications that allows users to post, view, like blog posts with photos
*/
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:geo_snap/main.dart';
import 'package:geo_snap/models/user.dart';
import 'package:geo_snap/services/database_service.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Get the first user from the database and set it as the current user
  Future<void> _loadCurrentUser() async {
    User? currentUser = await DatabaseService.getUser();
    if (currentUser != null) {
      await saveUsername(currentUser);
      setState(() {});
    }
  }

  // Save the current user's information to shared preferences for create, edit, and delete operations in the add page
  Future<void> saveUsername(User currentUser) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', currentUser.userId!);
    await prefs.setString('userName', currentUser.username);
    await prefs.setString('password', currentUser.password!);
    await prefs.setInt('age', currentUser.age);
    await prefs.setString('gender', currentUser.gender);
    await prefs.setString('topicPreference', currentUser.topicPreference);
  }

  @override
  Widget build(BuildContext context) {
    // Temporary login page with a button to skip to the home page
    return Scaffold(
      appBar: AppBar(title: Text("GeoSnap - Login")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _loadCurrentUser();
            // Navigate to the main screen (home page) when the button is pressed
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          },
          child: Text("Skip"),
        ),
      ),
    );
  }
}
