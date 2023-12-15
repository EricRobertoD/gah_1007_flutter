import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final noTelpController = TextEditingController();
  final noIdentitasController = TextEditingController();
  final alamatController = TextEditingController();
  final jawabanSQController = TextEditingController();

  void register() async {
    final response = await http.post(
      Uri.parse('https://p3l-be-eric.frederikus.com/api/register'),
      body: {
        'username': usernameController.text,
        'nama': namaController.text,
        'email': emailController.text,
        'password': passwordController.text,
        'no_telp': noTelpController.text,
        'no_identitas': noIdentitasController.text,
        'alamat': alamatController.text,
        'jawaban_sq': jawabanSQController.text,
      },
    );
  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    final message = responseData['message'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  } else {
    final responseData = json.decode(response.body);
    final message = responseData['message'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/gah_logo.png',
                width: 262.0,
                height: 146.0,
              ),
              Card(
                margin: EdgeInsets.only(top: 20.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: usernameController,
                        decoration: InputDecoration(labelText: 'Username'),
                      ),
                      TextField(
                        controller: namaController,
                        decoration: InputDecoration(labelText: 'Nama'),
                      ),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                      ),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: 'Password'),
                      ),
                      TextField(
                        controller: noTelpController,
                        decoration: InputDecoration(labelText: 'Nomor Telepon'),
                      ),
                      TextField(
                        controller: noIdentitasController,
                        decoration: InputDecoration(labelText: 'Nomor Identitas'),
                      ),
                      TextField(
                        controller: alamatController,
                        decoration: InputDecoration(labelText: 'Alamat'),
                      ),
                      TextField(
                        controller: jawabanSQController,
                        decoration: InputDecoration(labelText: 'Apa nama hewan peliharaan pertamamu'),
                      ),
                      ElevatedButton(
                        onPressed: register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF574C7E),
                          minimumSize: Size(300.0, 40.0),
                        ),
                        child: Text('Register', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
