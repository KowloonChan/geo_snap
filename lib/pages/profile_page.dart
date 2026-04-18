/*
 Group 2
 Student names: Ka Lung Chan, Xuanyu Wang, Jaden Douglas, Nayeong Lim
 Studnet numbers: 9034150, 9020543, 9032089, 8943403
 Description: an applications that allows users to post, view, like blog posts with photos
 */
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:geo_snap/services/database_service.dart';
import 'package:geo_snap/models/category.dart';
import 'package:geo_snap/models/user.dart';
import 'package:geo_snap/pages/login_page.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Save the userId for update databsase
  int? userId;

  // The profile page with a form to display username, age, gender, and topic preference of the current user retrived from shared preferences, and allow the user to edit and save the information back to the database and shared preferences
  // Form controls
  FormGroup form = FormGroup({
    "userName": FormControl<String>(
      validators: [
        Validators.required,
        Validators.minLength(2),
        Validators.maxLength(20),
      ],
      value: "",
    ),
    "password": FormControl<String>(
      validators: [
        Validators.required,
        Validators.minLength(6),
        Validators.maxLength(20),
      ],
      value: "",
    ),
    "age": FormControl<int>(
      validators: [
        Validators.required,
        Validators.min(15),
        Validators.max(100),
      ],
      value: null,
    ),
    "gender": FormControl<String>(validators: [Validators.required], value: ""),
    "topicPreference": FormControl<String>(
      validators: [Validators.required],
      value: "",
    ),
  });

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  // Get current user information from shared preferences
  Future<void> _loadCurrentUser() async {
    var prefs = await SharedPreferences.getInstance();
    String userName = prefs.getString('userName')!;
    String password = prefs.getString('password')!;
    int age = prefs.getInt('age')!;
    String gender = prefs.getString('gender')!;
    String topicPreference = prefs.getString('topicPreference')!;
    userId = prefs.getInt('userId')!;

    form.control('userName').value = userName;
    form.control('password').value = password;
    form.control('age').value = age;
    form.control('gender').value = gender;
    form.control('topicPreference').value = topicPreference;
  }

  // Display the current user's information in a form and allow the user to edit and save the information back to the database and shared preferences
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ReactiveForm(
            formGroup: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReactiveTextField<String>(
                  formControlName: 'userName',
                  decoration: InputDecoration(labelText: 'Username'),
                  validationMessages: {
                    "required": (err) => "Username is required",
                    "minLength": (err) =>
                        "Username must be at least 2 characters long",
                    "maxLength": (err) =>
                        "Username must be at most 20 characters long",
                  },
                ),

                ReactiveTextField<String>(
                  formControlName: 'password',
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validationMessages: {
                    "required": (err) => "Password is required",
                    "minLength": (err) =>
                        "Password must be at least 6 characters long",
                    "maxLength": (err) =>
                        "Password must be at most 20 characters long",
                  },
                ),

                ReactiveTextField<int>(
                  formControlName: 'age',
                  decoration: InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  validationMessages: {
                    "required": (err) => "Age is required",
                    "min": (err) => "Age must be at least 15",
                    "max": (err) => "Age must be at most 100",
                  },
                ),

                ReactiveDropdownField<String>(
                  formControlName: 'gender',
                  decoration: InputDecoration(labelText: 'Gender'),
                  items: [
                    DropdownMenuItem(value: "Male", child: Text("Male")),
                    DropdownMenuItem(value: "Female", child: Text("Female ")),
                    DropdownMenuItem(value: "Other", child: Text("Other")),
                  ],
                  validationMessages: {
                    "required": (err) => "Gender is required",
                  },
                ),

                ReactiveDropdownField<String>(
                  formControlName: 'topicPreference',
                  decoration: const InputDecoration(
                    // labelText: "Topic Preference",
                    border: OutlineInputBorder(),
                  ),
                  items: BlogCategory.categoryNames.asMap().entries.map((
                    entry,
                  ) {
                    return DropdownMenuItem<String>(
                      value: entry.value,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  hint: Text("Select Topic Preference"),
                  validationMessages: {
                    "required": (err) => "A business type must be selected",
                  },
                ),

                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () async {
                    if (form.valid) {
                      // Creqate the updated User
                      User updatedUser = User(
                        userId: userId,
                        username: form.control('userName').value as String,
                        password: form.control('password').value as String,
                        age: form.control('age').value as int,
                        gender: form.control('gender').value as String,
                        topicPreference:
                            form.control('topicPreference').value as String,
                      );

                      // Update the database
                      await DatabaseService.updateUser(updatedUser);

                      // Update SharedPreferences
                      var prefs = await SharedPreferences.getInstance();
                      await prefs.setString('userName', updatedUser.username);
                      await prefs.setString('password', updatedUser.password);
                      await prefs.setInt('age', updatedUser.age);
                      await prefs.setString('gender', updatedUser.gender);
                      await prefs.setString(
                        'topicPreference',
                        updatedUser.topicPreference,
                      );

                      // Show success feedback to the user
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Profile updated successfully!"),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      form.markAllAsTouched();
                    }
                  },
                  child: Text("Save Changes"),
                ),

                // Space between buttons
                SizedBox(height: 12),

                // A logout button to clear the current user's information from shared preferences and navigate back to the login page
                ElevatedButton(
                  onPressed: () async {
                    var prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    if (!context.mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text("Logout"),
                ),

                // A button go to the testing page to test database operations, to be deleted in the final version
                // TODO: delete this button and the testing page after testing is done
                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (context) => TestingPage()),
                //     );
                //   },
                //   child: Text("Go to Testing Page"),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
