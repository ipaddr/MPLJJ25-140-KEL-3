import 'package:flutter/material.dart';

class TambahMakananScreen extends StatefulWidget {
  const TambahMakananScreen({super.key});

  @override
  State<TambahMakananScreen> createState() => _TambahMakananScreenState();
}

class _TambahMakananScreenState extends State<TambahMakananScreen> {
  // Data tipe makanan dan deskripsinya
  final Map<int, String> deskripsiMakanan = {
    1: 'Nasi, Ayam, Telor, Sayur, Buah',
    2: 'Nasi, Ayam, Tahu, Sayur, Buah',
    3: 'Nasi, Ikan, Telor, Sayur, Buah',
    4: 'Nasi, Daging, Telor, Sayur, Buah',
    5: 'Nasi, Ikan, Tahu, Sayur, Buah',
  };

  int selectedTipe = 1;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Tambah Makanan'),
        backgroundColor: colorScheme.tertiary,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Tipe Makanan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Radio pilihan tipe makanan
            ...deskripsiMakanan.entries.map(
              (entry) => RadioListTile<int>(
                title: Text(entry.value),
                value: entry.key,
                groupValue: selectedTipe,
                activeColor: colorScheme.primary,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedTipe = value;
                    });
                  }
                },
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/makanan_ditambahkan',
                    arguments: deskripsiMakanan[selectedTipe],
                  );
                },
                child: const Text('Tambah Makanan'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Tombol Back
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: const Color(0xFF018175),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Text(
                  'Back',
                  style: TextStyle(fontSize: 12, color: Color(0xFF018175)),
                ),
              ],
            ),

            // Tombol Home (tengah, lebih besar seperti FAB)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF018175),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.home),
                    iconSize: 30,
                    color: Colors.white,
                    onPressed: () {
                      Navigator.popUntil(context, ModalRoute.withName('/home'));
                    },
                  ),
                ),
                const Text(
                  'Home',
                  style: TextStyle(fontSize: 12, color: Color(0xFF018175)),
                ),
              ],
            ),

            // Tombol Tambah Makanan (aktif, tetap di halaman ini)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: const Color(0xFF018175),
                  onPressed: () {
                    // Bisa untuk reset pilihan jika ingin
                    setState(() {
                      selectedTipe = 1;
                    });
                  },
                ),
                const Text(
                  'Tambah',
                  style: TextStyle(fontSize: 12, color: Color(0xFF018175)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
