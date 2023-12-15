import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gah_1007_flutter/global_variable.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class ReservasiPage extends StatefulWidget {
  final String token;

  String generateImageUrl(String relativePath) {
    final baseUrl = 'https://p3l-be-eric.frederikus.com/';
    return baseUrl + relativePath;
  }

  ReservasiPage({required this.token});

  @override
  _ReservasiPageState createState() => _ReservasiPageState();
}

class _ReservasiPageState extends State<ReservasiPage> {

  List<Widget> cards = [];

  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController dewasaController = TextEditingController();
  final TextEditingController anakController = TextEditingController();
  final TextEditingController superiorController = TextEditingController(text: '0');
  final TextEditingController doubleDeluxeController = TextEditingController(text: '0');
  final TextEditingController executiveDeluxeController = TextEditingController(text: '0');
  final TextEditingController juniorSuiteController = TextEditingController(text: '0');

  String resultMessage = '';
  Map<String, dynamic> availableRooms = {};



  @override
void initState() {
  super.initState();

  // Call fetchDataJenisKamar in initState to fetch data for swiper cards
  fetchDataJenisKamar().then((data) {
    setState(() {
      cards = data.map((item) => buildCard(item)).toList();

      // Add a default card if the cards list is empty
      if (cards.isEmpty) {
        cards.add(buildDefaultCard());
      }
    });
  });
}

Widget buildDefaultCard() {
  return Card(
    child: Center(
      child: Text('No data available'),
    ),
  );
}


Widget buildCard(Map<String, dynamic> item) {
  return Card(
    child: Column(
      children: [
        Container(
          height: 100, // Set the desired height for the entire card
          child: Image.network(
            item['imageUrl'],
            fit: BoxFit.cover,
          ),
        ),
        Padding(
  padding: const EdgeInsets.all(8.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, // Adjust alignment as needed
    children: [
      Text(item['data']['jenis_kamar']),
      Text(item['data']['ukuran_kamar']),
      Text(item['data']['fasilitas_kamar']),
      // Add more Text widgets as needed
    ],
  ),
),
        // Add other data fields as needed
      ],
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservasi Page'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Card Swiper Section
            Container(
              height: 400,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchDataJenisKamar(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No data available'));
                  } else {
                    List<Map<String, dynamic>> data = snapshot.data!;
                    List<Widget> cards = data.map((item) => buildCard(item)).toList();
                    if (cards.isEmpty) {
                      cards.add(buildDefaultCard());
                    }

                    return CardSwiper(
                      cardsCount: cards.length,
                      cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                        return cards[index];
                      },
                    );
                  }
                },
              ),
            ),
          SizedBox(height: 100), // Add some space between the widgets
          TextField(
            controller: startDateController,
            decoration: InputDecoration(
              labelText: 'Start Date',
              suffixIcon: IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () => _selectDate(startDateController),
              ),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: endDateController,
            decoration: InputDecoration(
              labelText: 'End Date',
              suffixIcon: IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () => _selectDate(endDateController),
              ),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              fetchData();
            },
            child: Text('Check Availability'),
          ),
          if (availableRooms.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: availableRooms.entries.map((entry) {
                return RoomTypeCard(
                  roomType: entry.key,
                  roomTypeData: entry.value,
                );
              }).toList(),
            ),
          SizedBox(height: 16),
          TextField(
            controller: dewasaController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Number of Adults'),
          ),
          SizedBox(height: 16),
          TextField(
            controller: anakController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Number of Children'),
          ),
          SizedBox(height: 16),
          TextField(
            controller: superiorController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Superior'),
          ),
          SizedBox(height: 16),
          TextField(
            controller: doubleDeluxeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Double Deluxe'),
          ),
          SizedBox(height: 16),
          TextField(
            controller: executiveDeluxeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Executive Deluxe'),
          ),
          SizedBox(height: 16),
          TextField(
            controller: juniorSuiteController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Junior Suite'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              submitData();
            },
            child: Text('Create Reservasi'),
          ),
          SizedBox(height: 16),
          Text(resultMessage),
        ],
      ),
    ),
  );
}


  Future<void> fetchData() async {
    final Uri url = Uri.parse(
        'https://p3l-be-eric.frederikus.com/api/reservasiAvailable');

    try {
      final response = await http.post(url, body: {
        'tanggal_mulai': startDateController.text,
        'tanggal_selesai': endDateController.text,
        // Add other parameters as needed
      });

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          setState(() {
            availableRooms = data['data'];
          });
        } catch (e) {
          setState(() {
            resultMessage = 'Error decoding response data';
          });
        }
      } else {
        setState(() {
          resultMessage =
              'Error fetching data. Status Code: ${response.statusCode}';
        });
      }
    } catch (error) {
      setState(() {
        resultMessage = 'Error: $error';
      });
    }
  }
void submitData() async {
  // Show a confirmation dialog
  bool confirmed = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmation'),
        content: Text('Do you really want to create a reservation?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(false); // Return false if canceled
            },
          ),
          TextButton(
            child: Text('Confirm'),
            onPressed: () {
              Navigator.of(context).pop(true); // Return true if confirmed
            },
          ),
        ],
      );
    },
  );

  // Check if the user confirmed before proceeding
  if (confirmed == true) {
    // Continue with the reservation creation logic
    final response = await http.post(
      Uri.parse(
          'https://p3l-be-eric.frederikus.com/api/reservasi'),
      headers: {
        'Authorization': 'Bearer ${GLOBALVARIABLES.token}',
      },
      body: {
        'tanggal_mulai': startDateController.text,
        'tanggal_selesai': endDateController.text,
        'dewasa': dewasaController.text,
        'anak': anakController.text,
        'superior': superiorController.text,
        'double_deluxe': doubleDeluxeController.text,
        'executive_deluxe': executiveDeluxeController.text,
        'junior_suite': juniorSuiteController.text,
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
}

  
  Future<List<Map<String, dynamic>>> fetchDataJenisKamar() async {
  final client = http.Client();
 try {
    final response = await client
        .get(Uri.parse(
            'https://p3l-be-eric.frederikus.com/api/jenisKamarPublic'))
        .timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      // Map each item to a map containing image URL and data
      List<Map<String, dynamic>> result = data.map((item) {
        return {
          'imageUrl': widget.generateImageUrl(item['gambar']),
          'data': item,
        };
      }).toList();
      return Future.value(result);
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


  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 10),
    );

    if (pickedDate != null && pickedDate != controller.text) {
      setState(() {
        controller.text = pickedDate.toString().split(' ')[0];
      });
    }
  }
}

class RoomTypeCard extends StatelessWidget {
  final String roomType;
  final dynamic roomTypeData;

  RoomTypeCard({required this.roomType, required this.roomTypeData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                roomType,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Tersedia: ${roomTypeData['tersedia']} available'),
              roomTypeData['tarif_default'] != null
                  ? Text('Tarif Default: ${roomTypeData['tarif_default']}')
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
