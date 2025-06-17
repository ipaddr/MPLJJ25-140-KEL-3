import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  String _namaPengguna = "Pengguna"; // Tambahkan state untuk nama pengguna

  @override
  void initState() {
    super.initState();
    _loadDataPengguna(); // Panggil method untuk memuat nama pengguna
  }

  @override
  void dispose() {
    namaController.dispose();
    usiaController.dispose();
    beratController.dispose();
    tinggiController.dispose();
    super.dispose();
  }

  // Method untuk memuat nama pengguna, mirip dengan di HomeScreen
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

      if (berat <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berat badan harus lebih dari 0 kg.')),
          );
        }
        return;
      }

      if (tinggiCm <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Tinggi badan harus lebih dari 0 cm.')),
          );
        }
        return;
      }

      double tinggiM = tinggiCm / 100;
      double imt = berat / (tinggiM * tinggiM);

      String newStatusGizi;
      String newRekomendasi;

      if (imt < 18.5) {
        newStatusGizi = 'Kurang';
        newRekomendasi = 'Konsumsi makanan tinggi kalori dan protein';
      } else if (imt > 25) {
        newStatusGizi = 'Berlebih';
        newRekomendasi = 'Kurangi makanan berlemak dan perbanyak sayur';
      } else {
        newStatusGizi = 'Normal';
        newRekomendasi = 'Makanan 4 Sehat 5 Sempurna';
      }

      setState(() {
        statusGizi = newStatusGizi;
        rekomendasi = newRekomendasi;
      });

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Anda harus login untuk menyimpan data.')),
          );
        }
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
            : double.parse(imt.toStringAsFixed(2)),
        'statusGizi': newStatusGizi,
        'rekomendasi': newRekomendasi,
        'tanggalPengecekan': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('riwayatCekGizi')
          .add(dataToSave);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Status gizi berhasil dihitung dan disimpan.')),
        );
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

  IconData _getEmoticonForStatus(String status) {
    switch (status) {
      case 'Kurang':
        return Icons.sentiment_very_dissatisfied;
      case 'Berlebih':
        return Icons.sentiment_dissatisfied; // Atau Icons.mood_bad
      case 'Normal':
      default:
        return Icons.sentiment_very_satisfied;
    }
  }

  Color _getColorForStatus(String status, BuildContext context) {
    switch (status) {
      case 'Kurang':
        return const Color.fromARGB(255, 187, 255, 0); // Kuning-hijau
      case 'Berlebih':
        return const Color.fromARGB(255, 255, 0, 0); // Merah
      case 'Normal':
      default:
        return const Color.fromARGB(255, 34, 255, 0); // Hijau cerah
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer( // Tambahkan Drawer di sini
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
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Halo, $_namaPengguna', // Gunakan _namaPengguna dari state
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
                Navigator.pop(context); // Tutup drawer terlebih dahulu
                Navigator.pushNamed(context, '/profile');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.monitor_heart),
              title: const Text('Pemantauan Gizi'),
              onTap: () {
                Navigator.pop(context);
                // Jika sudah di halaman Pemantauan Gizi, tidak perlu navigasi lagi
                // Navigator.pushNamed(context, '/pemantauan_gizi'); 
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
        leading: Builder(
          builder: (BuildContext context) {
            // Cek apakah ada drawer, jika tidak ada, tampilkan tombol back standar
            if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            }
            return BackButton(); // Tombol back standar jika tidak ada drawer
          },
        ),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: usiaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Usia (Tahun)'),
            ),
            TextField(
              controller: beratController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Berat Badan (Kg)'),
            ),
            TextField(
              controller: tinggiController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Tinggi Badan (Cm)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
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
                  : const Text('Hitung'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Status Gizi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Icon(
              _getEmoticonForStatus(statusGizi),
              size: 80,
              color: _getColorForStatus(statusGizi, context),
            ),
            const SizedBox(height: 5),
            Text(
              statusGizi, // Display the current status
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _getColorForStatus(statusGizi, context),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                DotWithText(
                    text: 'Kurang', color: Color.fromARGB(255, 187, 255, 0)),
                DotWithText(
                    text: 'Normal', color: Color.fromARGB(255, 34, 255, 0)),
                DotWithText(
                    text: 'Berlebih', color: Color.fromARGB(255, 255, 0, 0)),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Rekomendasi Makanan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
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

            // Tombol Home (tengah, lebih besar seperti FAB)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF018175),
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

class DotWithText extends StatelessWidget {
  final String text;
  final Color color;

  const DotWithText({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 10),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}
