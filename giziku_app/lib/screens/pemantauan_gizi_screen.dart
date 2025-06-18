import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giziku_app/utils/gizi_helpers.dart'; // Import helper baru

class PemantauanGiziScreen extends StatefulWidget {
  const PemantauanGiziScreen({super.key});

  @override
  State<PemantauanGiziScreen> createState() => _PemantauanGiziScreenState();
}

class _PemantauanGiziScreenState extends State<PemantauanGiziScreen> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController usiaController = TextEditingController();
  final TextEditingController beratController = TextEditingController();
  final TextEditingController tinggiController = TextEditingController();
  bool _isLoading = false;

  String statusGizi = 'Normal'; // Default
  String rekomendasi = 'Makanan 4 Sehat 5 Sempurna';
  String _namaPengguna = "Pengguna";

  @override
  void initState() {
    super.initState();
    _loadDataPengguna();
  }

  @override
  void dispose() {
    namaController.dispose();
    usiaController.dispose();
    beratController.dispose();
    tinggiController.dispose();
    super.dispose();
  }

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
      return;
    }

    setState(() {
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
            const SnackBar(content: Text('Usia harus lebih dari 0 tahun.')),
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
      } else {
        // IMT >= 30
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

  @override
  Widget build(BuildContext context) {
    // Menggunakan warna dari gizi_helpers.dart, namun jika ingin spesifik untuk halaman ini:
    Color colorKurang = const Color.fromARGB(255, 235, 220, 52); // Kuning
    Color colorNormal = const Color.fromARGB(255, 76, 175, 80); // Hijau
    Color colorBerlebih = const Color.fromARGB(255, 255, 82, 82); // Merah
    Color colorObesitas = const Color.fromARGB(255, 180, 50, 50); // Merah Tua

    return Scaffold(
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
              tileColor: Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(0.1), // Menandai halaman aktif
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
      body: SingleChildScrollView(
        // Menggunakan SingleChildScrollView untuk menghindari overflow
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Agar tombol melebar
          children: [
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
            ),
            const SizedBox(height: 24),
            const Text(
              'Hasil Status Gizi:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Icon(
              getEmoticonForStatus(statusGizi), // Menggunakan helper
              size: 70,
              color:
                  getColorForStatus(statusGizi, context), // Menggunakan helper
            ),
            const SizedBox(height: 8),
            Text(
              statusGizi,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: getColorForStatus(
                    statusGizi, context), // Menggunakan helper
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
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceVariant
                      .withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.5))),
              child: Text(
                rekomendasi,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            const SizedBox(height: 24), // Spasi tambahan di akhir
          ],
        ),
      ),
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
            ),
            _buildBottomNavItem(
              icon: Icons.add_circle_outline,
              label: 'Tambah',
              onPressed: () {
                Navigator.of(context).pushNamed('/tambahmakanan');
              },
            ),
          ],
        ),
      ),
    );
  }

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
    final backgroundColor =
        isCentral ? const Color(0xFF018175) : Colors.transparent;

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

class DotWithText extends StatelessWidget {
  final String text;
  final Color color;

  const DotWithText({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      // Mengubah menjadi Column agar lebih rapi jika teks panjang
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, color: color, size: 12),
        const SizedBox(height: 2), // Sedikit jarak antara dot dan teks
        Text(text, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
