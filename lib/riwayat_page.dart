import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'profile_page.dart';
import 'bayar_page.dart';

class RiwayatPage extends StatefulWidget {
  final String token;

  RiwayatPage({required this.token});

  @override
  _RiwayatPageState createState() => _RiwayatPageState(token: token);
}

class _RiwayatPageState extends State<RiwayatPage> {
  final String token;
  late PageController _pageController;

  _RiwayatPageState({required this.token}) {
    _pageController = PageController(initialPage: 0);
  }

  Future<List<dynamic>> fetchReservations() async {
    final client = http.Client();
    try {
      final response = await client.get(
        Uri.parse(
          'https://p3l-be-eric.frederikus.com/api/reservasi',
        ),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data;
      } else {
        throw Exception(
            'Failed to load reservations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect: $e');
    } finally {
      client.close();
    }
  }

  Future<void> _showAdditionalFacilityModal(int reservationId) async {
    int facilityQuantity = 1;
    List<Map<String, dynamic>> availableFacilities = [];

    await _fetchFacilities().then((facilities) {
      availableFacilities = facilities;
    });
    print('Available Facilities: $availableFacilities');
    int facilityId = availableFacilities.isNotEmpty
        ? availableFacilities[0]['id_fasilitas']
        : 0;

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Tambah Fasilitas Tambahan'),
                  DropdownButtonFormField<int>(
                    value: facilityId,
                    items: availableFacilities
                        .map((facility) => DropdownMenuItem<int>(
                              value: facility['id_fasilitas'],
                              child: Text(facility['fasilitas_tambahan']),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        facilityId = value!;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Nama Fasilitas'),
                  ),
                  TextFormField(
                    onChanged: (value) {
                      facilityQuantity = int.tryParse(value) ?? 1;
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Jumlah'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _storeAdditionalFacility(
                          reservationId, facilityId, facilityQuantity);
                      Navigator.pop(context); 
                    },
                    child: Text('Simpan'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchFacilities() async {
    final client = http.Client();
    try {
      final response = await client.get(
        Uri.parse(
          'https://p3l-be-eric.frederikus.com/api/fasilitasTambahan',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception(
            'Failed to load facilities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect: $e');
    } finally {
      client.close();
    }
  }

  Future<void> _storeAdditionalFacility(
      int reservationId, int facilityId, int facilityQuantity) async {
    final client = http.Client();
    try {
      final requestBody = {
        'id_reservasi': reservationId,
        'id_fasilitas': facilityId,
        'jumlah': facilityQuantity,
      };

      final response = await client
          .post(
            Uri.parse(
              'https://p3l-be-eric.frederikus.com/api/transaksiFasilitas',
            ),
            headers: {
              'Authorization': token,
              'Content-Type': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 302) {
        final redirectedResponse =
            await client.get(Uri.parse(response.headers['location']!));
        if (redirectedResponse.statusCode == 200) {
          print('Facility stored successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Facility stored successfully'),
              duration: Duration(seconds: 2),
            ),
          );
          setState(() {});
        } else {
          throw Exception(
              'Failed to store facility after redirection: ${redirectedResponse.statusCode}');
        }
      } else if (response.statusCode == 200) {
        print('Facility stored successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Facility stored successfully'),
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {});
      } else {
        throw Exception(
            'Failed to store facility: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to connect: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Reservasi'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchReservations(),
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
                var reservation = snapshot.data![index];
                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) {
                        return Container(
                          padding: EdgeInsets.all(16),
                          child: Card(
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                      'ID_RESERVASI: ${reservation['id_reservasi'] ?? "-"}'),
                                ),
                                ListTile(
                                  title: Text(
                                      'Reservation ID: ${reservation['id_booking'] ?? "-"}'),
                                ),
                                ListTile(
                                  title: Text(
                                      'Tanggal Reservasi: ${reservation['tanggal_reservasi'] ?? "-"}'),
                                ),
                                ListTile(
                                  title: Text(
                                      'Tanggal Mulai: ${reservation['tanggal_mulai'] ?? "-"}'),
                                ),
                                ListTile(
                                  title: Text(
                                      'Tanggal Selesai: ${reservation['tanggal_selesai'] ?? "-"}'),
                                ),
                                ListTile(
                                  title: Text(
                                      'Permintaan Khusus: ${reservation['permintaan_khusus'] ?? "-"}'),
                                ),
                                ListTile(
                                  title: Text(
                                      'Nomor Kamar: ${reservation['transaksi_kamar'].isNotEmpty ? reservation['transaksi_kamar'][0]['kamar']['no_kamar'] ?? "-" : "-"}'),
                                ),
                                ListTile(
                                  title: Text(
                                      'Jenis Kamar: ${reservation['transaksi_kamar'].isNotEmpty && reservation['transaksi_kamar'][0]['kamar']['jenis_kamar'] != null ? reservation['transaksi_kamar'][0]['kamar']['jenis_kamar']['jenis_kamar'] ?? "-" : "-"}'),
                                ),
                                ListTile(
                                  title: Text(
                                      'Jenis Bed: ${reservation['transaksi_kamar'].isNotEmpty ? reservation['transaksi_kamar'][0]['kamar']['pilih_bed'] ?? "-" : "-"}'),
                                ),
                                ListTile(
                                  title: Text(
                                      'Nomor Nota: ${reservation['nota_pelunasan'].isNotEmpty ? reservation['nota_pelunasan'][0]['no_nota'] ?? "-" : "-"}'),
                                ),
                                ListTile(
                                  title: Text(
                                      'Total Harga: ${reservation['nota_pelunasan'].isNotEmpty ? reservation['nota_pelunasan'][0]['total_harga'] ?? "-" : "-"}'),
                                ),
                                ListTile(
                                  title: Text(
                                      'Total Pajak: ${reservation['nota_pelunasan'].isNotEmpty ? reservation['nota_pelunasan'][0]['total_pajak'] ?? "-" : "-"}'),
                                ),
                                ListTile(
                                  title: Text(
                                      'Total Semua: ${reservation['nota_pelunasan'].isNotEmpty ? reservation['nota_pelunasan'][0]['total_semua'] ?? "-" : "-"}'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Card(
                    child: ListTile(
                      title: Column(children: [
                        Text('Reservation ID: ${reservation['id_booking']}'),
                        Text(
                            'Tanggal Reservasi: ${reservation['tanggal_reservasi']}'),
                        Text('Tanggal Mulai: ${reservation['tanggal_mulai']}'),
                        Text(
                            'Tanggal Selesai: ${reservation['tanggal_selesai']}'),
                        Text(
                            'Permintaan Khusus: ${reservation['permintaan_khusus']}'),
                        Text('Jumlah Dewasa: ${reservation['dewasa']}'),
                        Text('Jumlah Anak: ${reservation['anak']}'),
                        Text('Status: ${reservation['status']}'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () {
                                if (reservation['status'] != 'Lunas') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BayarPage(reservation: reservation),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Reservation is already paid'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              child: Text('Bayar'),
                            ),
                            TextButton(
                              onPressed: () {
                                if (reservation['status'] != 'Lunas') {
                                  _showAdditionalFacilityModal(
                                      reservation['id_reservasi']);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Facility cannot be added for paid reservation'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              child: Text('Fasilitas Tambahan'),
                            ),
                          ],
                        ),
                      ]),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
