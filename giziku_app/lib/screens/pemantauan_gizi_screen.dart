import 'package:flutter/material.dart';

class PemantauanGiziScreen extends StatefulWidget {
  const PemantauanGiziScreen({super.key});

  @override
  State<PemantauanGiziScreen> createState() => _PemantauanGiziScreenState();
}

class _PemantauanGiziScreenState extends State<PemantauanGiziScreen> {
<<<<<<< Updated upstream
<<<<<<< Updated upstream
  // Controller untuk nama sudah dihapus
=======
  final TextEditingController namaController = TextEditingController();
>>>>>>> Stashed changes
=======
  final TextEditingController namaController = TextEditingController();
>>>>>>> Stashed changes
  final TextEditingController usiaController = TextEditingController();
  final TextEditingController beratController = TextEditingController();
  final TextEditingController tinggiController = TextEditingController();

  String statusGizi = 'Normal'; // Default
  String rekomendasi = 'Makanan 4 Sehat 5 Sempurna';

<<<<<<< Updated upstream
<<<<<<< Updated upstream

  String _namaPengguna = "Pengguna";

  @override
  void initState() {
    super.initState();
    _loadDataPengguna();
  }
>>>>>>> ebe7fe1d95423783d38848f5a25e3ef7843a0aa1

  // Menambahkan dispose untuk membersihkan controller saat widget tidak lagi digunakan
  @override
  void dispose() {
    usiaController.dispose();
    beratController.dispose();
    tinggiController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  void hitungStatusGizi() {
    // Memastikan form tidak kosong sebelum melakukan perhitungan
    if (beratController.text.isEmpty || tinggiController.text.isEmpty) {
      // Anda bisa menampilkan snackbar atau pesan error di sini jika diperlukan
=======
  Future<void> _loadDataPengguna() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (mounted) {
        setState(() {
          _namaPengguna = user.displayName ?? user.email ?? "Pengguna";
        });
      }
    }
  }

  Future<void> hitungStatusGizi() async {
    if (_isLoading) return;

    if (namaController.text.isEmpty ||
        usiaController.text.isEmpty ||
        beratController.text.isEmpty ||
        tinggiController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua field harus diisi.')),
        );
      }
>>>>>>> ebe7fe1d95423783d38848f5a25e3ef7843a0aa1
      return;
    }
    double berat = double.tryParse(beratController.text) ?? 0;
    double tinggi = double.tryParse(tinggiController.text) ?? 1;

    // Menghindari pembagian dengan nol jika tinggi tidak valid
    if (tinggi == 0) return;

    double imt = berat / ((tinggi / 100) * (tinggi / 100));
    setState(() {
<<<<<<< HEAD
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
=======
      _isLoading = true;
    });

    try {
      double berat = double.tryParse(beratController.text) ?? 0;
      double tinggiCm = double.tryParse(tinggiController.text) ?? 0;
      int usia = int.tryParse(usiaController.text) ?? 0;

      if (berat <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berat badan harus lebih dari 0 kg.')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      if (tinggiCm <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Tinggi badan harus lebih dari 0 cm.')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
       if (usia <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Usia harus lebih dari 0 tahun.')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }


      double tinggiM = tinggiCm / 100;
      double imt = berat / (tinggiM * tinggiM);

      String newStatusGizi;
      String newRekomendasi;

      if (imt < 18.5) {
        newStatusGizi = 'Kurang';
        newRekomendasi =
            'Perbanyak konsumsi makanan tinggi kalori dan protein seperti daging, telur, alpukat, dan kacang-kacangan. Pastikan porsi makan lebih sering.';
      } else if (imt >= 18.5 && imt <= 24.9) {
        newStatusGizi = 'Normal';
        newRekomendasi =
            'Pertahankan pola makan seimbang dengan variasi 4 sehat 5 sempurna. Cukupi kebutuhan sayur, buah, karbohidrat kompleks, protein, dan lemak baik.';
      } else if (imt >= 25 && imt <= 29.9) {
        newStatusGizi = 'Berlebih';
        newRekomendasi =
            'Kurangi porsi makan, batasi makanan tinggi lemak jenuh, gula, dan garam. Perbanyak konsumsi serat dari sayur dan buah, serta tingkatkan aktivitas fisik.';
      } else { // IMT >= 30
        newStatusGizi = 'Obesitas';
        newRekomendasi =
            'Segera konsultasikan dengan ahli gizi atau dokter. Perlu perubahan gaya hidup signifikan meliputi diet rendah kalori, tinggi serat, dan peningkatan aktivitas fisik secara teratur.';
      }


      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Anda harus login untuk menyimpan data.')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      final dataToSave = {
        'userId': user.uid,
        'nama': namaController.text,
        'usia': int.tryParse(usiaController.text),
        'beratBadan': berat,
        'tinggiBadan': tinggiCm,
        'imt': imt.isNaN || imt.isInfinite
            ? null
            : double.parse(imt.toStringAsFixed(1)), // Ubah ke 1 angka desimal
        'statusGizi': newStatusGizi,
        'rekomendasi': newRekomendasi,
        'tanggalPengecekan': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('riwayatCekGizi')
          .add(dataToSave);
      
      if (mounted) {
        setState(() {
          statusGizi = newStatusGizi;
          rekomendasi = newRekomendasi;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Status gizi berhasil dihitung dan disimpan.')),
        );
        // Pertimbangkan untuk membersihkan field setelah berhasil atau navigasi
        // namaController.clear();
        // usiaController.clear();
        // beratController.clear();
        // tinggiController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
        );
      }
      print('Error in hitungStatusGizi: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Fungsi helper _getEmoticonForStatus dan _getColorForStatus sudah dipindahkan ke gizi_helpers.dart
  // Namun, jika Anda ingin warna yang berbeda khusus untuk halaman ini, Anda bisa mendefinisikannya di sini
  // atau memodifikasi gizi_helpers.dart untuk menerima parameter tema/konteks yang berbeda.
  // Untuk saat ini, kita akan menggunakan yang dari gizi_helpers.dart.
>>>>>>> ebe7fe1d95423783d38848f5a25e3ef7843a0aa1

  @override
  Widget build(BuildContext context) {
    // Menggunakan warna dari gizi_helpers.dart, namun jika ingin spesifik untuk halaman ini:
    Color colorKurang = const Color.fromARGB(255, 235, 220, 52); // Kuning
    Color colorNormal = const Color.fromARGB(255, 76, 175, 80); // Hijau
    Color colorBerlebih = const Color.fromARGB(255, 255, 82, 82); // Merah
    Color colorObesitas = const Color.fromARGB(255, 180, 50, 50); // Merah Tua


    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(title: const Text('Pemantauan Gizi')),
      // Menggunakan SingleChildScrollView agar tidak overflow saat keyboard muncul
      body: SingleChildScrollView(
=======
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF016BB8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Giziku App',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Halo, $_namaPengguna',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.monitor_heart),
              title: const Text('Pemantauan Gizi'),
              tileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1), // Menandai halaman aktif
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.volunteer_activism),
              title: const Text('Riwayat Ambil Makanan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/riwayat_ambil_makanan');
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Edukasi'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/edukasi');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Dashboard Statistik'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/dashboard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Riwayat Cek Gizi'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/riwayat_cek_gizi');
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Pemantauan Gizi'),
        // Leading button (menu atau back) akan otomatis ditangani oleh Flutter
        // berdasarkan keberadaan Drawer.
      ),
      body: SingleChildScrollView( // Menggunakan SingleChildScrollView untuk menghindari overflow
>>>>>>> ebe7fe1d95423783d38848f5a25e3ef7843a0aa1
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Agar tombol melebar
          children: [
<<<<<<< HEAD
            // TextField untuk nama sudah dihapus dari sini
=======
=======
>>>>>>> Stashed changes
  void hitungStatusGizi() {
    double berat = double.tryParse(beratController.text) ?? 0;
    double tinggi = double.tryParse(tinggiController.text) ?? 1;

    double imt = berat / ((tinggi / 100) * (tinggi / 100));
    setState(() {
      if (imt < 18.5) {
        statusGizi = 'Kurang';
        rekomendasi = 'Konsumsi makanan tinggi kalori dan protein';
      } else if (imt > 25) {
        statusGizi = 'Berlebih';
        rekomendasi = 'Kurangi makanan berlemak dan perbanyak sayur';
      } else {
        statusGizi = 'Normal';
        rekomendasi = 'Makanan 4 Sehat 5 Sempurna';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pemantauan Gizi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
            TextField(
              controller: usiaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Usia (Tahun)'),
            ),
<<<<<<< Updated upstream
<<<<<<< Updated upstream
            const SizedBox(height: 12),
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
            TextField(
              controller: beratController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Berat Badan (Kg)'),
            ),
<<<<<<< Updated upstream
<<<<<<< Updated upstream
            const SizedBox(height: 12),
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
            TextField(
              controller: tinggiController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Tinggi Badan (Cm)'),
            ),
<<<<<<< Updated upstream
<<<<<<< Updated upstream
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: hitungStatusGizi,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(
                    double.infinity, 50), // Membuat tombol lebih lebar
              ),
              child: const Text('Hitung Status Gizi'),
=======
            _buildTextField(
                controller: namaController, label: 'Nama Lengkap Anak'),
            _buildTextField(
                controller: usiaController,
                label: 'Usia (Tahun)',
                keyboardType: TextInputType.number),
            _buildTextField(
                controller: beratController,
                label: 'Berat Badan (Kg)',
                keyboardType: TextInputType.number),
            _buildTextField(
                controller: tinggiController,
                label: 'Tinggi Badan (Cm)',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: _isLoading ? null : hitungStatusGizi,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0,
                      ),
                    )
                  : const Text('Hitung & Simpan Status Gizi'),
>>>>>>> ebe7fe1d95423783d38848f5a25e3ef7843a0aa1
            ),
            const SizedBox(height: 24),
            const Text(
<<<<<<< HEAD
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
=======
=======
>>>>>>> Stashed changes
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: hitungStatusGizi,
              child: const Text('Hitung'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Status Gizi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Icon(
              Icons.pie_chart,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                DotWithText(text: 'Kurang', color: Colors.black),
                DotWithText(text: 'Normal', color: Colors.black),
                DotWithText(text: 'Berlebih', color: Colors.black),
              ],
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
            ),
            const SizedBox(height: 20),
            const Text(
              'Rekomendasi Makanan',
<<<<<<< Updated upstream
<<<<<<< Updated upstream
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
=======
              'Hasil Status Gizi:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Icon(
              getEmoticonForStatus(statusGizi), // Menggunakan helper
              size: 70,
              color: getColorForStatus(statusGizi, context), // Menggunakan helper
            ),
            const SizedBox(height: 8),
            Text(
              statusGizi,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: getColorForStatus(statusGizi, context), // Menggunakan helper
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DotWithText(text: 'Kurang', color: colorKurang),
                  DotWithText(text: 'Normal', color: colorNormal),
                  DotWithText(text: 'Berlebih', color: colorBerlebih),
                  DotWithText(text: 'Obesitas', color: colorObesitas),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Rekomendasi Makanan:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
>>>>>>> ebe7fe1d95423783d38848f5a25e3ef7843a0aa1
=======
              style: TextStyle(fontWeight: FontWeight.bold),
>>>>>>> Stashed changes
=======
              style: TextStyle(fontWeight: FontWeight.bold),
>>>>>>> Stashed changes
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
<<<<<<< Updated upstream
<<<<<<< Updated upstream
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
<<<<<<< HEAD
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Theme.of(context).colorScheme.tertiary)),
              child: Text(
                rekomendasi,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
=======
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5))
              ),
              child: Text(
                rekomendasi,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
>>>>>>> ebe7fe1d95423783d38848f5a25e3ef7843a0aa1
              ),
            ),
             const SizedBox(height: 24), // Spasi tambahan di akhir
          ],
        ),
      ),
      // Bottom Navigation Bar tetap sama
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        color: Colors.white, // Atau Theme.of(context).bottomAppBarTheme.color
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(
              icon: Icons.arrow_back_ios_new_rounded,
              label: 'Back',
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
<<<<<<< HEAD
=======
=======
>>>>>>> Stashed changes
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(rekomendasi, textAlign: TextAlign.center),
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
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes

            // Tombol Home (tengah, lebih besar seperti FAB)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
<<<<<<< Updated upstream
<<<<<<< Updated upstream
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF018175),
=======
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF018175),
>>>>>>> Stashed changes
=======
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF018175),
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
<<<<<<< Updated upstream
=======
            _buildBottomNavItem(
              icon: Icons.home,
              label: 'Home',
              isCentral: true,
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                );
              },
>>>>>>> ebe7fe1d95423783d38848f5a25e3ef7843a0aa1
            ),
            _buildBottomNavItem(
              icon: Icons.add_circle_outline,
              label: 'Tambah',
              onPressed: () {
                Navigator.of(context).pushNamed('/tambahmakanan');
              },
=======
=======
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
            ),
          ],
        ),
      ),
    );
  }
<<<<<<< Updated upstream
<<<<<<< Updated upstream

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isCentral = false,
  }) {
    final color = isCentral ? Colors.white : const Color(0xFF018175);
    final iconColor = isCentral ? Colors.white : const Color(0xFF018175);
    final backgroundColor = isCentral ? const Color(0xFF018175) : Colors.transparent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (isCentral)
          Container(
            padding: const EdgeInsets.all(4), // Padding untuk lingkaran FAB
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
            ),
            child: IconButton(
              icon: Icon(icon, color: iconColor),
              iconSize: 30,
              onPressed: onPressed,
            ),
          )
        else
          IconButton(
            icon: Icon(icon, color: iconColor),
            onPressed: onPressed,
          ),
        if (!isCentral) // Hanya tampilkan teks jika bukan tombol tengah
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
      ],
    );
  }
}

<<<<<<< HEAD
// Widget ini tidak perlu diubah, jadi saya hapus dari sini agar fokus pada perubahan.
// Pastikan Anda tetap memiliki class DotWithText di file Anda jika masih digunakan.
=======
=======
}

>>>>>>> Stashed changes
=======
}

>>>>>>> Stashed changes
class DotWithText extends StatelessWidget {
  final String text;
  final Color color;

  const DotWithText({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
<<<<<<< Updated upstream
<<<<<<< Updated upstream
    return Column( // Mengubah menjadi Column agar lebih rapi jika teks panjang
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, color: color, size: 12),
        const SizedBox(height: 2), // Sedikit jarak antara dot dan teks
        Text(text, style: const TextStyle(fontSize: 11)),
=======
=======
>>>>>>> Stashed changes
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 10),
        const SizedBox(width: 4),
        Text(text),
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
      ],
    );
  }
}
<<<<<<< Updated upstream
<<<<<<< Updated upstream
>>>>>>> ebe7fe1d95423783d38848f5a25e3ef7843a0aa1
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
