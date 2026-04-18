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
  final _formKey = GlobalKey<FormState>();

  String username = '';
  String password = '';
  bool isLoading = false;

  // Save logged-in user to SharedPreferences
  Future<void> saveUsername(User currentUser) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', currentUser.userId!);
    await prefs.setString('userName', currentUser.username);
    await prefs.setString('password', currentUser.password!);
    await prefs.setInt('age', currentUser.age);
    await prefs.setString('gender', currentUser.gender);
    await prefs.setString('topicPreference', currentUser.topicPreference);
  }

  // LOGIN FUNCTION
  void login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() => isLoading = true);

      User? user = await DatabaseService.authenticateUser(
        username: username,
        password: password,
      );

      setState(() => isLoading = false);

      if (user != null) {
        await saveUsername(user);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Invalid username or password")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("GeoSnap - Login")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, size: 80),
              SizedBox(height: 10),
              Text(
                "GeoSnap",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 30),

              // USERNAME
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter username";
                  }
                  return null;
                },
                onSaved: (value) => username = value!,
              ),

              SizedBox(height: 15),

              // PASSWORD
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 4) {
                    return "Password must be at least 4 characters";
                  }
                  return null;
                },
                onSaved: (value) => password = value!,
              ),

              SizedBox(height: 20),

              // LOGIN BUTTON
              ElevatedButton(
                onPressed: isLoading ? null : login,
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Login"),
              ),

              SizedBox(height: 20),

              // TEST ACCOUNT INFO
              Text(
                "username: admin\npassword: admin123",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
