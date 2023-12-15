// LaporanPage.dart

import 'package:flutter/material.dart';
import 'package:gah_1007_flutter/global_variable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LaporanPage extends StatefulWidget {
  final String token;

  LaporanPage({required this.token});

  @override
  _LaporanPageState createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  Map<String, dynamic>? dataLaporanCustomer;
  Map<String, dynamic>? dataTop5Customer;
  int selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    getDataLaporanCustomer();
    getDataTop5Customer();
  }

  Future<void> getDataLaporanCustomer() async {
    final url = Uri.parse('https://p3l-be-eric.frederikus.com/api/getNewCustomer?tahun=$selectedYear');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${widget.token}',
    });
    print('Laporan Customer Response: ${response.body}');
    setState(() {
      dataLaporanCustomer = jsonDecode(response.body);
      dataLaporanCustomer = dataLaporanCustomer!['data'];
    });
  }

  Future<void> getDataTop5Customer() async {
    final url = Uri.parse('https://p3l-be-eric.frederikus.com/api/getTopCustomersWithMostBookings?tahun=$selectedYear');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${widget.token}',
    });
    print('Top 5 Customer Response: ${response.body}');
    setState(() {
      dataTop5Customer = jsonDecode(response.body);
      dataTop5Customer = dataTop5Customer!['data'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan Tamu'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              // Section for Laporan Customer Baru
              
              DropdownButton<int>(
                value: selectedYear,
                items: List.generate(DateTime.now().year - 2021 + 1, (index) => index + 2021)
                    .map((int year) => DropdownMenuItem<int>(
                          value: year,
                          child: Text(year.toString()),
                        ))
                    .toList(),
                onChanged: (int? year) {
                  if (year != null) {
                    setState(() {
                      selectedYear = year;
                    });
                    getDataLaporanCustomer();
                    getDataTop5Customer();
                  }
                },
              ),
              dataLaporanCustomer != null
                  ? Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://i.ibb.co/dbTn7nD/logo.jpg',
                              height: 100,
                              width: 1000,
                            ),
                            SizedBox(height: 16),
                            Center(
                              child: Text(
                                'LAPORAN TAMU',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Divider(
                              thickness: 2,
                              color: Colors.black,
                            ),
                            Column(
                              children: [
                                Text(
                                  'Jl. P. Mangkubumi No.18, Yogyakarta 55233',
                                ),
                                Text('Telp. (0274) 487711'),
                              ],
                            ),
                            SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Tahun: ${dataLaporanCustomer!['tahun']}',
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: [
                                  DataColumn(label: Text('No')),
                                  DataColumn(label: Text('Bulan')),
                                  DataColumn(label: Text('Jumlah')),
                                ],
                                rows: (dataLaporanCustomer!['dataLaporan']
                                            as List<dynamic>? ??
                                        [])
                                    .map<DataRow>((item) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          (dataLaporanCustomer!['dataLaporan']
                                                      .indexOf(item) +
                                                  1)
                                              .toString(),
                                        ),
                                      ),
                                      DataCell(Text(item['bulan'].toString())),
                                      DataCell(
                                        Text(
                                          item['jumlah_customer'].toString(),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Total Tamu: ${dataLaporanCustomer!['total_customer_baru']} tamu',
                            ),
                          ],
                        ),
                      ),
                    )
                  : CircularProgressIndicator(),

              SizedBox(width: 16),

              // Section for Top 5 Customers
              dataTop5Customer != null
                  ? Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://i.ibb.co/dbTn7nD/logo.jpg',
                              height: 100,
                              width: 1000,
                            ),
                            SizedBox(height: 16),
                            Column(
                              children: [
                                Text(
                                  'LAPORAN TOP 5 CUSTOMERS',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              thickness: 2,
                              color: Colors.black,
                            ),
                            Column(
                              children: [
                                Text(
                                  'Jl. P. Mangkubumi No.18, Yogyakarta 55233',
                                ),
                                Text('Telp. (0274) 487711'),
                              ],
                            ),
                            SizedBox(height: 16),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: [
                                  DataColumn(label: Text('No')),
                                  DataColumn(label: Text('Nama Customer')),
                                  DataColumn(label: Text('Total Reservasi')),
                                  DataColumn(label: Text('Total Pembayaran')),
                                ],
                                rows: (dataTop5Customer!['dataLaporan']
                                            as List<dynamic>? ??
                                        [])
                                    .map<DataRow>((item) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          (dataTop5Customer!['dataLaporan']
                                                      .indexOf(item) +
                                                  1)
                                              .toString(),
                                        ),
                                      ),
                                      DataCell(
                                        Text(item['nama'].toString()),
                                      ),
                                      DataCell(
                                        Text(
                                          item['jumlah_reservasi'].toString(),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          item['total_pembayaran'].toString(),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Tanggal Cetak: ${dataTop5Customer!['tanggal_cetak']}',
                            ),
                          ],
                        ),
                      ),
                    )
                  : CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
