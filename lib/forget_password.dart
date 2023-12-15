import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgetPasswordPage extends StatefulWidget {
  @override
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController answerController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  String errorMessage = '';

  Future<void> forgetPassword() async {
    final String email = emailController.text;
    final String answer = answerController.text;
    final String newPassword = newPasswordController.text;

    final Uri uri = Uri.parse('https://p3l-be-eric.frederikus.com/api/forgetPassword');

    final response = await http.post(
      uri,
      body: {
        'email': email,
        'jawaban_sq': answer,
        'password': newPassword,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        errorMessage = 'Password changed successfully';
      });
    } else if (response.statusCode == 400) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        errorMessage = data['errors']['message'][0];
      });
    } else {
      setState(() {
        errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: answerController,
              decoration: InputDecoration(
                labelText: 'Security Question Answer',
              ),
            ),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
              ),
            ),
            ElevatedButton(
              onPressed: forgetPassword,
              child: Text('Change Password'),
            ),
            Text(
              errorMessage,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
