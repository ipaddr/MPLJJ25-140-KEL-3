import 'package:flutter/material.dart';

class PemantauanGiziScreen extends StatefulWidget {
  const PemantauanGiziScreen({super.key});

  @override
  State<PemantauanGiziScreen> createState() => _PemantauanGiziScreenState();
}

class _PemantauanGiziScreenState extends State<PemantauanGiziScreen> {
  // Controller untuk nama sudah dihapus
  final TextEditingController usiaController = TextEditingController();
  final TextEditingController beratController = TextEditingController();
  final TextEditingController tinggiController = TextEditingController();

  String statusGizi = 'Normal'; // Default
  String rekomendasi = 'Makanan 4 Sehat 5 Sempurna';

  // Menambahkan dispose untuk membersihkan controller saat widget tidak lagi digunakan
  @override
  void dispose() {
    usiaController.dispose();
    beratController.dispose();
    tinggiController.dispose();
    super.dispose();
  }

  void hitungStatusGizi() {
    // Memastikan form tidak kosong sebelum melakukan perhitungan
    if (beratController.text.isEmpty || tinggiController.text.isEmpty) {
      // Anda bisa menampilkan snackbar atau pesan error di sini jika diperlukan
      return;
    }
    double berat = double.tryParse(beratController.text) ?? 0;
    double tinggi = double.tryParse(tinggiController.text) ?? 1;

    // Menghindari pembagian dengan nol jika tinggi tidak valid
    if (tinggi == 0) return;

    double imt = berat / ((tinggi / 100) * (tinggi / 100));
    setState(() {
      if (imt < 18.5) {
        statusGizi = 'Kurang';
        rekomendasi = 'Konsumsi makanan tinggi kalori dan protein';
      } else if (imt >= 18.5 && imt <= 24.9) {
        statusGizi = 'Normal';
        rekomendasi = 'Pertahankan pola makan 4 Sehat 5 Sempurna';
      } else {
        statusGizi = 'Berlebih';
        rekomendasi = 'Kurangi makanan berlemak dan perbanyak sayur';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pemantauan Gizi')),
      // Menggunakan SingleChildScrollView agar tidak overflow saat keyboard muncul
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // TextField untuk nama sudah dihapus dari sini
            TextField(
              controller: usiaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Usia (Tahun)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: beratController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Berat Badan (Kg)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tinggiController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Tinggi Badan (Cm)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: hitungStatusGizi,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(
                    double.infinity, 50), // Membuat tombol lebih lebar
              ),
              child: const Text('Hitung Status Gizi'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Status Gizi Anda',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Widget untuk menampilkan hasil status gizi
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusGizi,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Rekomendasi Makanan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Theme.of(context).colorScheme.tertiary)),
              child: Text(
                rekomendasi,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar tetap sama
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
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (route) => false,
                      );
                    },
                  ),
                ),
                const Text(
                  'Home',
                  style: TextStyle(fontSize: 12, color: Color(0xFF018175)),
                ),
              ],
            ),

            // Tombol Tambah Makanan
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: const Color(0xFF018175),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/tambahmakanan');
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

// Widget ini tidak perlu diubah, jadi saya hapus dari sini agar fokus pada perubahan.
// Pastikan Anda tetap memiliki class DotWithText di file Anda jika masih digunakan.
