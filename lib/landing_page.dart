import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

String generateImageUrl(String relativePath) {
  final baseUrl = 'https://p3l-be-eric.frederikus.com/';
  return baseUrl + relativePath;
}

class _LandingPageState extends State<LandingPage> {
  Future<List<dynamic>> fetchData() async {
    final client = http.Client();
    try {
      final response = await client
          .get(Uri.parse(
              'https://p3l-be-eric.frederikus.com/api/jenisKamarPublic'))
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data;
      } else {
        throw Exception(
            'Failed to load jenis kamar data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect: $e');
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hotel Information'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
            child: Text(
              'Login',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data?.isEmpty ?? true) {
            return Center(child: Text('No data available'));
          } else {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var jenisKamar = snapshot.data![index];
                      final imageUrl = generateImageUrl(jenisKamar['gambar']);
                      return ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Card(
                          child: Column(
                            children: [
                            Image.network(imageUrl),
                            Text( 
                              '${jenisKamar['jenis_kamar']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              jenisKamar['jenis_bed'] ?? 'N/A',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                jenisKamar['fasilitas_kamar'] ?? 'N/A',),
                            )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        
                        Text(
                          textAlign:TextAlign.center,
                          'Grand Atma Hotel'),
                        Text(
                          textAlign:TextAlign.center,'⭐⭐⭐⭐⭐'),
                        Text(
                          textAlign:TextAlign.center,'Telepon: (0274) 487711'),
                        Text(
                          textAlign:TextAlign.center,'Email: GrandAtmaHotel@gmail.com'),
                        Text(
                          textAlign:TextAlign.center,'Jl. P. Mangkubumi No.18, Yogyakarta 55233'),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '200711007 - Eric Roberto Djohan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
