import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PembatalanPage extends StatefulWidget {
  final String token;

  PembatalanPage({required this.token});

  @override
  _PembatalanPageState createState() => _PembatalanPageState(token: token);
}

class _PembatalanPageState extends State<PembatalanPage> {
  final String token;
  late PageController _pageController;

  _PembatalanPageState({required this.token}) {
    _pageController = PageController(initialPage: 0);
  }

  String _searchQuery = '';

  Future<List<dynamic>> fetchPembatalan() async {
    final client = http.Client();
    try {
      final response = await client.get(
        Uri.parse(
            'https://p3l-be-eric.frederikus.com/api/getPembatalan'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data;
      } else {
        throw Exception('Failed to load pembatalan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect: $e');
    } finally {
      client.close();
    }
  }


Future<void> _cancelReservation(int reservationId) async {
  final client = http.Client();
  try {
    final response = await client.delete(
      Uri.parse(
        'https://p3l-be-eric.frederikus.com/api/reservasi/$reservationId',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    ).timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      // Parse the response JSON
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Show an alert dialog with the message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Cancellation Status'),
            content: Text(responseData['message']),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      // Reload the page after cancellation
      setState(() {});
    } else {
      throw Exception('Failed to cancel reservation: ${response.statusCode}');
    }
  } catch (e) {
    print('Failed to connect: $e');
    // Show a Snackbar for connection error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to connect: $e'),
        duration: Duration(seconds: 2),
      ),
    );
  } finally {
    client.close();
  }
}

  Future<void> _showConfirmationDialog(int reservationId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to cancel this reservation?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                _cancelReservation(reservationId);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pembatalan Reservasi'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: fetchPembatalan(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.data?.isEmpty ?? true) {
                  return Center(child: Text('No data available'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var pembatalan = snapshot.data![index];
                      if (_searchQuery.isEmpty ||
                          pembatalan['customer']['nama']
                              .toLowerCase()
                              .contains(_searchQuery) ||
                          pembatalan['id_booking']
                              .toString()
                              .toLowerCase()
                              .contains(_searchQuery)) {
                        return Card(
                          child: ListTile(
                            title: Column(
                              children: [
                                Text('Reservation ID: ${pembatalan['id_booking']}'),
                                Text('Nama Customer: ${pembatalan['customer']['nama']}'),
                                Text('Tanggal Menginap: ${pembatalan['tanggal_mulai']}'),
                                Text('Alasan Selesai: ${pembatalan['tanggal_selesai']}'),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        _showConfirmationDialog(pembatalan['id_reservasi']);
                                      },
                                      child: Text('Cancel Reservation'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
