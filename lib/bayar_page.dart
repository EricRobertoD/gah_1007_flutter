import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class BayarPage extends StatefulWidget {
  final Map<String, dynamic> reservation;

  BayarPage({required this.reservation});

  @override
  _BayarPageState createState() => _BayarPageState();
}

class _BayarPageState extends State<BayarPage> {
  late File _imageFile;
  final picker = ImagePicker();

  // Function to open the image picker
Future<void> _pickImage() async {
 final ImagePicker _picker = ImagePicker();
 final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

 if (pickedFile != null) {
    setState(() {
      _imageFile = File(pickedFile.path);
    });
 }
}

  Future<void> _uploadAndBayar() async {
    try {
      String apiUrl =
          'https://p3l-be-eric.frederikus.com/api/updateBayar/${widget.reservation['id_reservasi']}';
      var request =
          http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Attach image file
      request.files.add(
          await http.MultipartFile.fromPath('gambar', _imageFile.path));

      // Add payment status to the request
      request.fields['status'] = 'Lunas';

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Bayar successful');
        // Show success SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment successful'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print('Bayar failed');
        // Show failure SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      // Show error SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showConfirmationModal() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi Pembayaran"),
          content: Text("Apakah Anda yakin ingin melakukan pembayaran?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _uploadAndBayar();
              },
              child: Text("Ya, Bayar"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _imageFile = File(''); // Initialize with an empty file
  }

  Widget buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value?.toString() ?? '-'), // Use null-aware operator
        ],
      ),
    );
  }

  // Function to calculate the total price from a list of items
  double calculateTotal(List<dynamic> items, String attribute) {
    double total = 0.0;
    for (var item in items) {
      total += item[attribute] ?? 0.0;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    print(widget.reservation); // Print the reservation data

    double totalHargaKamar =
        calculateTotal(widget.reservation['transaksi_kamar'] ?? [], 'harga_total');

    double totalHargaFasilitasTambahan =
        calculateTotal(widget.reservation['transaksi_fasilitas_tambahan'] ?? [], 'total_harga_fasilitas');

    double totalHarga = totalHargaKamar + totalHargaFasilitasTambahan;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pembayaran'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildDetailRow('ID Booking', widget.reservation['id_booking']),
              if (widget.reservation['id_pegawai'] != null)
                buildDetailRow('PIC', widget.reservation['pegawai']['nama_pegawai']),
            ],
          ),
          SizedBox(height: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildDetailRow('Nama', widget.reservation['customer']['nama']),
              buildDetailRow('Alamat', widget.reservation['customer']['alamat']),
            ],
          ),
          SizedBox(height: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildDetailRow('Check In', widget.reservation['tanggal_mulai']),
              buildDetailRow('Check Out', widget.reservation['tanggal_selesai']),
              buildDetailRow('Dewasa', widget.reservation['dewasa']),
              buildDetailRow('Anak-anak', widget.reservation['anak']),
              buildDetailRow(
                  'Tanggal Pembayaran', widget.reservation['tanggal_pembayaran']),
            ],
          ),
          SizedBox(height: 16.0),
          // Display Nomor Kamar and Jenis Kamar for each item in transaksi_kamar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data Kamar :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              for (var transaksi in widget.reservation['transaksi_kamar'])
                Column(
                  children: [
                    buildDetailRow(
                        'Nomor Kamar', transaksi['kamar']['no_kamar']),
                    buildDetailRow('Jenis Kamar',
                        transaksi['kamar']['jenis_kamar']['jenis_kamar']),
                    buildDetailRow('Harga', transaksi['harga_total']),
                    SizedBox(height: 16.0), // Add space between items
                  ],
                ),
            ],
          ),
          SizedBox(height: 16.0),
          // Display Nomor Kamar and Jenis Kamar for each item in transaksi_kamar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data Fasilitas :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              for (var fasilitas
                  in widget.reservation['transaksi_fasilitas_tambahan'])
                Column(
                  children: [
                    buildDetailRow('Fasilitas Tambahan',
                        fasilitas['fasilitas_tambahan']['fasilitas_tambahan']),
                    buildDetailRow('Jumlah', fasilitas['jumlah']),
                    buildDetailRow('Total Harga Fasilitas',
                        fasilitas['total_harga_fasilitas']),
                    SizedBox(height: 16.0), // Add space between items
                  ],
                ),
            ],
          ),
          
          SizedBox(height: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Permintaan Khusus :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(widget.reservation['permintaan_khusus'] ?? '-'), // Use null-aware operator
            ],
          ),

          SizedBox(height: 25.0),
          // Display Total Harga
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Harga :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              buildDetailRow('Kamar', totalHargaKamar),
              buildDetailRow('Fasilitas Tambahan', totalHargaFasilitasTambahan),
              buildDetailRow('Total Harga', totalHarga),
            ],
          ),

          SizedBox(height: 16.0),

          // File uploader
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload Bukti Pembayaran :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Choose Image'),
              ),
              SizedBox(height: 8.0),
              _imageFile.path.isNotEmpty
                  ? Image.file(_imageFile, height: 100.0)
                  : Container(),
            ],
          ),

          SizedBox(height: 16.0),

          // Bayar Button
          
    ElevatedButton(
      onPressed: () async {
        // Check if an image is selected before proceeding to Bayar
        if (_imageFile.path.isNotEmpty) {
          await _showConfirmationModal();
        } else {
          // Show an error message or alert that an image must be selected
          print('Please choose an image');
        }
      },
      child: Text('Bayar'),
    ),
        ],
      ),
    );
  }
}
