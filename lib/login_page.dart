import 'package:flutter/material.dart';
import 'package:gah_1007_flutter/dashboard_page.dart';
import 'package:gah_1007_flutter/global_variable.dart';
import 'package:gah_1007_flutter/riwayat_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'register_page.dart';
import 'forget_password.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final storage = FlutterSecureStorage();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> login() async {
    final response = await http.post(
      Uri.parse(
          'https://p3l-be-eric.frederikus.com/api/login'),
      body: {
        'email': emailController.text,
        'password': passwordController.text,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      GLOBALVARIABLES.token = data['data']['access_token'];
      GLOBALVARIABLES.role = 'Customer';
      await storage.write(key: 'token', value: GLOBALVARIABLES.token);
      showErrorMessage('Login successful');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Dashboard(),
        ),
      );
    } else {
      showErrorMessage('Invalid email or password');
    }
  }

  Future<void> loginPegawai() async {
    final response = await http.post(
      Uri.parse(
          'https://p3l-be-eric.frederikus.com/api/loginPegawai'),
      body: {
        'email': emailController.text,
        'password': passwordController.text,
      },
    );

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      GLOBALVARIABLES.token = data['data']['access_token'];
      GLOBALVARIABLES.role = data['data']['pegawai']['id_role'].toString();
      await storage.write(key: 'token', value: GLOBALVARIABLES.token);
      showErrorMessage('Login Pegawai successful');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Dashboard(),
        ),
      );
    } else {
      showErrorMessage('Invalid Pegawai email or password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/gah_logo.png',
                width: 362.0,
                height: 246.0,
              ),
              Card(
                margin: EdgeInsets.only(top: 50.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(labelText: 'Username'),
                      ),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: 'Password'),
                      ),
                      ElevatedButton(
                        onPressed: login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 87, 152, 126),
                          minimumSize: Size(300.0, 40.0),
                        ),
                        child: Text('Masuk',
                            style: TextStyle(color: Colors.black)),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgetPasswordPage()),
                          );
                        },
                        child: Text(
                          'Lupa Password?',
                          style: TextStyle(
                            color: Colors
                                .blue, // You can choose your desired color
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 87, 152, 126),
                          minimumSize: Size(300.0, 40.0),
                        ),
                        child: Text('Daftar',
                            style: TextStyle(color: Colors.black)),
                      ),
                      ElevatedButton(
                        onPressed: loginPegawai,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 87, 152, 126),
                          minimumSize: Size(300.0, 40.0),
                        ),
                        child: Text('Masuk Pegawai',
                            style: TextStyle(color: Colors.black)),
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
