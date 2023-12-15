import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gah_1007_flutter/change_password.dart';
import 'package:gah_1007_flutter/landing_page.dart';
import 'package:http/http.dart' as http;
import 'package:gah_1007_flutter/global_variable.dart';

class ProfilePage extends StatefulWidget {
  final String token;

  ProfilePage({required this.token});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> userData = {
    'nama': '',
    'email': '',
  };
  bool isEditMode = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController noTelpController = TextEditingController();
  TextEditingController noIdentController = TextEditingController();
  TextEditingController alamatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> logoutUser() async {
    final apiUrl = 'https://p3l-be-eric.frederikus.com/api/logout';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${GLOBALVARIABLES.token}',
        },
      );

      if (response.statusCode == 200) {
        showSnackBar("Logout successful", Colors.green);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LandingPage(),
          ),
        );
      } else {
        showSnackBar("Failed to logout. Please try again.", Colors.red);
      }
    } catch (error) {
      showSnackBar("An error occurred. Please try again.$error", Colors.red);
    }
  }

  Future<void> fetchData() async {
    final apiUrl =
        'https://p3l-be-eric.frederikus.com/api/customer';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    print("Response Status Code: " + response.statusCode.toString());

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final customerData = data['data'][0];

      setState(() {
        userData['nama'] = customerData['nama'];
        userData['email'] = customerData['email'];
        userData['username'] = customerData['username'];
        userData['no_telp'] = customerData['no_telp'];
        userData['no_identitas'] = customerData['no_identitas'];
        userData['alamat'] = customerData['alamat'];

        // Populate text controllers with user data
        nameController.text = userData['nama'];
        emailController.text = userData['email'];
        usernameController.text = userData['username'];
        noTelpController.text = userData['no_telp'];
        noIdentController.text = userData['no_identitas'];
        alamatController.text = userData['alamat'];
      });
    }
  }

  // Function to save the edited data
  Future<void> saveData() async {
    final apiUrl =
        'https://p3l-be-eric.frederikus.com/api/customer';
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'nama': nameController.text,
          'email': emailController.text,
          'username': usernameController.text,
          'no_telp': noTelpController.text,
          'no_identitas': noIdentController.text,
          'alamat': alamatController.text,
        },
      );

      if (response.statusCode == 200) {
        // Data saved successfully
        setState(() {
          userData['nama'] = nameController.text;
          userData['email'] = emailController.text;
          userData['username'] = usernameController.text;
          userData['no_telp'] = noTelpController.text;
          userData['no_identitas'] = noIdentController.text;
          userData['alamat'] = alamatController.text;
          isEditMode = false; // Exit edit mode
        });
        showSnackBar("Data updated successfully", Colors.green);
      } else {
        showSnackBar("Failed to update data. Please try again.", Colors.red);
      }
    } catch (error) {
      showSnackBar("An error occurred. Please try again.", Colors.red);
    }
  }

  void showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(isEditMode ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditMode) {
                showAlertDialog(context);
              }
              setState(() {
                isEditMode = !isEditMode;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Wrap the body with a SingleChildScrollView
        child: Center(
          child: Card(
            margin: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Image.asset('assets/profilegah.png'),
                ),
                ListTile(
                  title: isEditMode
                      ? TextField(
                          controller: nameController,
                        )
                      : Text('Name: ${userData['nama']}'),
                ),
                ListTile(
                  title: isEditMode
                      ? TextField(
                          controller: emailController,
                        )
                      : Text('Email: ${userData['email']}'),
                ),
                ListTile(
                  title: isEditMode
                      ? TextField(
                          controller: noTelpController,
                        )
                      : Text('Nomor Telepon: ${userData['no_telp']}'),
                ),
                ListTile(
                  title: isEditMode
                      ? TextField(
                          controller: noIdentController,
                        )
                      : Text('Nomor Identitas: ${userData['no_identitas']}'),
                ),
                ListTile(
                  title: isEditMode
                      ? TextField(
                          controller: alamatController,
                        )
                      : Text('Alamat: ${userData['alamat']}'),
                ),
                ListTile(
                  title: ElevatedButton(
                    // Button to navigate to ChangePassword page
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChangePasswordPage(), // ChangePasswordPage should be defined in your code
                        ),
                      );
                    },
                    child: Text('Change Password'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    logoutUser();
                  },
                  child: Text('Logout'),
                )
                // Add more ListTile widgets for other data fields
              ],
            ),
          ),
        ),
      ),
    );
    
  }
  showAlertDialog(BuildContext context) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text("Cancel"),
    onPressed:  () {Navigator.pop(context);},
  );
  Widget continueButton = TextButton(
    child: Text("Continue"),
    onPressed:  () {saveData(); Navigator.pop(context);},
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Edit Profile"),
    content: Text("Apakah yakin ingin edit profile"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
}
