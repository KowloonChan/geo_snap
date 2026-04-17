/*
Group 2
Student names: Ka Lung Chan, Xuanyu Wang, Jaden Douglas, Nayeong Lim
Studnet numbers: 9034150, 9020543, 9032089, 8943403
Description: An applications that allows users to post, view, like blog posts with photos
*/
import "package:flutter/material.dart";
import 'package:geo_snap/pages/add_page.dart';
import 'package:geo_snap/pages/home_page.dart';
import 'package:geo_snap/pages/login_page.dart';
import 'package:geo_snap/pages/profile_page.dart';
import 'package:geo_snap/services/database_service.dart';



Future<void> main() async {
  // Initialize the database before running the app
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.getDatabase();
  runApp(MyApp());
}

// Returns the MaterialApp
class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: LoginPage());
  }
}

// Returns the Scaffold
class MainScreen extends StatefulWidget {
  MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;
  List<Widget> pages = [HomePage(), AddPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("GeoSnap")),
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        // Always show the labels
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Add"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        onTap: (index) {
          setState(() {
            _index = index;
          });
        },
      ),
    );
  }
}
