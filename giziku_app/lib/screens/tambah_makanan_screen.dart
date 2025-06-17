import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TambahMakananScreen extends StatefulWidget {
  const TambahMakananScreen({super.key});

  @override
  State<TambahMakananScreen> createState() => _TambahMakananScreenState();
}

class _TambahMakananScreenState extends State<TambahMakananScreen> {
  final Map<int, String> deskripsiMakanan = {
    1: 'Nasi, Ayam, Telor, Sayur, Buah',
    2: 'Nasi, Ayam, Tahu, Sayur, Buah',
    3: 'Nasi, Ikan, Telor, Sayur, Buah',
    4: 'Nasi, Daging, Telor, Sayur, Buah',
    5: 'Nasi, Ikan, Tahu, Sayur, Buah',
  };

  final Map<int, String> gambarMakanan = {
    1: 'assets/images/makanan1.png',
    2: 'assets/images/makanan2.png',
    3: 'assets/images/makanan3.png',
    4: 'assets/images/makanan4.png',
    5: 'assets/images/makanan5.png',
  };

  int selectedTipe = 1;
  late TextEditingController deskripsiController;
  final TextEditingController tanggalController = TextEditingController();
  DateTime? _selectedDate; // To store the selected DateTime object
  bool _isSaving = false; // To manage loading state for the save button

  @override
  void initState() {
    super.initState();
    deskripsiController = TextEditingController(
      text: deskripsiMakanan[selectedTipe] ?? '',
    );
  }

  @override
  void dispose() {
    deskripsiController.dispose();
    tanggalController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked; // Store the picked DateTime
        tanggalController.text = DateFormat(
          'dd MMMM yyyy',
          'id_ID',
        ).format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Controller yang update tiap build supaya show deskripsi sesuai selectedTipe
    final TextEditingController deskripsiController = TextEditingController(
      text: deskripsiMakanan[selectedTipe] ?? '',
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Tambah Makanan'),
        backgroundColor: colorScheme.tertiary,
        centerTitle: true,
        leading: IconButton(
<<<<<<< Updated upstream
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
 Navigator.pop(context);
=======
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
>>>>>>> Stashed changes
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade300,
                image: DecorationImage(
                  image: AssetImage(gambarMakanan[selectedTipe]!),
                  fit: BoxFit.cover,
<<<<<<< Updated upstream
                  // onError is not directly available for DecorationImage
                  // but if you switch to Image.asset, you can use errorBuilder:
                  // errorBuilder: (context, error, stackTrace) {
                  //   return const Icon(Icons.broken_image, size: 50, color: Colors.red);
                  // },
=======
>>>>>>> Stashed changes
                ),
              ),
            ),
            const SizedBox(height: 24),

            DropdownButtonFormField<int>(
              value: selectedTipe,
              decoration: const InputDecoration(
                labelText: 'Tipe Paket',
                border: UnderlineInputBorder(),
              ),
              items:
<<<<<<< Updated upstream
                  deskripsiMakanan.entries.map((e) {
                    return DropdownMenuItem(
                      value: e.key,
                      child: Text('Tipe ${e.key}'),
                    );
                  }).toList(),
=======
                  deskripsiMakanan.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text('Tipe ${e.key}'),
                        ),
                      )
                      .toList(),
>>>>>>> Stashed changes
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    selectedTipe = val;
<<<<<<< Updated upstream
                    deskripsiController.text = deskripsiMakanan[selectedTipe] ?? ''; // Update here
=======
>>>>>>> Stashed changes
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              readOnly: true,
              controller: deskripsiController,
<<<<<<< Updated upstream
              decoration: const InputDecoration(
                labelText: 'Detail Paket',
                border: UnderlineInputBorder(),
                suffixIcon: Icon(Icons.info_outline),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              readOnly: true,
              controller: tanggalController,
              onTap: () => _pilihTanggal(context),
              decoration: const InputDecoration(
                labelText: 'Tanggal',
                border: UnderlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),

            Spacer(),

            // Tombol Simpan yang Diperbarui
=======
              decoration: InputDecoration(
                labelText: 'Detail Paket',
                border: const UnderlineInputBorder(),
                suffixIcon: const Icon(Icons.arrow_drop_down),
              ),
            ),

            const Spacer(),

>>>>>>> Stashed changes
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
<<<<<<< Updated upstream
                onPressed: _isSaving ? null : () async {
                  // Validasi
                  if (_selectedDate == null) { // Validate using _selectedDate
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar( // Check mounted before ScaffoldMessenger
                      const SnackBar(content: Text('Tanggal harus diisi')),
                    );
                    return;
                  }

                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Anda harus login untuk menyimpan data')),
                    );
                    return;
                  }

                  if (mounted) {
                    setState(() {
                      _isSaving = true;
                    });
                  }

                  // Simpan ke Firestore
                  try {
                    await FirebaseFirestore.instance
                        .collection('riwayatAmbilMakanan')
                        .add({
                      'userId': user.uid,
                      'tipeMakanan': selectedTipe, // Store the key (integer)
                      'deskripsi': deskripsiMakanan[selectedTipe],
                      'tanggal': _selectedDate, // Store the DateTime object directly
                      'timestamp': FieldValue.serverTimestamp(), // Tambahkan timestamp
                    });

                    if (!mounted) return;
                    // Optionally clear fields after successful save
                    // tanggalController.clear();
                    // _selectedDate = null;
                    // setState(() { selectedTipe = 1; deskripsiController.text = deskripsiMakanan[1] ?? ''; });

                    // Navigasi ke halaman sukses
                    Navigator.pushNamed(
                      context,
                      '/makanan_ditambahkan',
                      arguments: {
                        'deskripsi': deskripsiMakanan[selectedTipe],
                        'tanggal': tanggalController.text,
                      },
                    );
                  } catch (e) {
                    print('Error saving to Firestore: $e');
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Gagal menyimpan data: ${e.toString()}')), // Pesan error yang lebih spesifik
                    );
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isSaving = false;
                      });
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0),
                      )
                    : const Text('Simpan'),
=======
                onPressed: () {
                  // Navigasi ke layar MakananDitambahkan dan kirim data deskripsi
                  Navigator.pushNamed(
                    context,
                    '/makanan_ditambahkan',
                    arguments: deskripsiMakanan[selectedTipe],
                  );
                },
                child: const Text(
                  'Simpan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
>>>>>>> Stashed changes
              ),
            ),
          ],
        ),
      ),
    );
  }
}
