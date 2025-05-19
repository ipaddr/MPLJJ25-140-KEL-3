import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

    deskripsiController.text = deskripsiMakanan[selectedTipe] ?? '';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Tambah Makanan'),
        backgroundColor: colorScheme.tertiary,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
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
                  deskripsiMakanan.entries.map((e) {
                    return DropdownMenuItem(
                      value: e.key,
                      child: Text('Tipe ${e.key}'),
                    );
                  }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    selectedTipe = val;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              readOnly: true,
              controller: deskripsiController,
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

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/makanan_ditambahkan',
                    arguments: {
                      'deskripsi': deskripsiMakanan[selectedTipe],
                      'tanggal': tanggalController.text,
                    },
                  );
                },
                child: const Text(
                  'Simpan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
