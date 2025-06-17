import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giziku_app/screens/pemantauan_gizi_screen.dart'; // Untuk akses _getEmoticonForStatus dan _getColorForStatus

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _namaPengguna = "Pengguna";
  Map<String, dynamic>? _dataGiziTerakhir;
  bool _isLoadingGizi = true;

  @override
  void initState() {
    super.initState();
    _loadDataPengguna();
    _loadDataGiziTerakhir();
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

  Future<void> _loadDataGiziTerakhir() async {
    User? user = FirebaseAuth.instance.currentUser;
    print("HomeScreen: Current user UID: ${user?.uid}"); // Log UID pengguna
    if (user == null) {
      if (mounted) setState(() => _isLoadingGizi = false);
      return;
    }

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          // .collection('riwayatCekGiziSalahNama') // Baris ini untuk tes jika nama koleksi salah
          .collection('riwayatCekGizi')
          .where('userId', isEqualTo: user.uid)
          .orderBy('tanggalPengecekan', descending: true)
          .limit(1)
          .get();

      print("HomeScreen: Query executed. Number of docs found: ${querySnapshot.docs.length}"); // Log jumlah dokumen

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        print("HomeScreen: Data found: $data"); // Log data yang ditemukan
        if (mounted) {
          setState(() {
            _dataGiziTerakhir = data;
            _isLoadingGizi = false;
          });
        }
      } else {
        print("HomeScreen: No nutritional data found for this user.");
        if (mounted) setState(() => _isLoadingGizi = false);
      }
    } catch (e) {
          print("HomeScreen: Error loading last nutritional data: $e");
      if (mounted) setState(() => _isLoadingGizi = false);
    }
  }

  // Fungsi helper dari PemantauanGiziScreen (bisa dipindahkan ke file utilitas jika sering digunakan)
  IconData _getEmoticonForStatus(String? status) {
    switch (status) {
      case 'Kurang':
        return Icons.sentiment_very_dissatisfied;
      case 'Berlebih':
        return Icons.sentiment_dissatisfied;
      case 'Normal':
      default:
        return Icons.sentiment_very_satisfied;
    }
  }

  Color _getColorForStatus(String? status, BuildContext context) {
    switch (status) {
      case 'Kurang':
        return const Color.fromARGB(255, 235, 220, 52); // Kuning
      case 'Berlebih':
        return const Color.fromARGB(255, 255, 82, 82); // Merah
      case 'Normal':
      default:
        return const Color.fromARGB(255, 76, 175, 80); // Hijau
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10b68d),
      appBar: AppBar(
        backgroundColor: const Color(0xFF018175),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        title: const Text(
          'Beranda',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
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
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Halo, $_namaPengguna',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            // --- MENU PROFIL DITAMBAHKAN DI SINI ---
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profil'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer terlebih dahulu
                Navigator.pushNamed(context, '/profile');
              },
            ),
            const Divider(), // Menambah garis pemisah
            ListTile(
              leading: const Icon(Icons.monitor_heart),
              title: const Text('Pemantauan Gizi'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/pemantauan_gizi');
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Datang, $_namaPengguna!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pantau terus status gizimu untuk hidup lebih sehat.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),

            // Box IMT
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isLoadingGizi
                    ? const Center(child: CircularProgressIndicator())
                    : _dataGiziTerakhir != null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _dataGiziTerakhir!['statusGizi'] ?? 'Belum Ada Data',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: _getColorForStatus(_dataGiziTerakhir!['statusGizi'], context),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'IMT: ${_dataGiziTerakhir!['imt']?.toStringAsFixed(1) ?? '-'} kg/m²',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    Text(
                                      'Nama: ${_dataGiziTerakhir!['nama'] ?? '-'}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                _getEmoticonForStatus(_dataGiziTerakhir!['statusGizi']),
                                size: 56,
                                color: _getColorForStatus(_dataGiziTerakhir!['statusGizi'], context),
                              ),
                            ],
                          )
                        : const Text(
                            'Belum ada data pemantauan gizi. Yuk, cek sekarang!',
                            style: TextStyle(fontSize: 16, color: Color(0xFF018175)),
                            textAlign: TextAlign.center,
                          ),
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Aksi Cepat
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickActionButton(
                  context,
                  icon: Icons.monitor_heart_outlined,
                  label: 'Cek Gizi',
                  onTap: () => Navigator.pushNamed(context, '/pemantauan_gizi'),
                ),
                _buildQuickActionButton(
                  context,
                  icon: Icons.history_edu_outlined,
                  label: 'Riwayat Gizi',
                  onTap: () => Navigator.pushNamed(context, '/riwayat_cek_gizi'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Rekomendasi Makanan
            const Text(
              'Rekomendasi Makanan Hari Ini',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/makanan1.jpg',
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.fastfood, size: 64, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Nasi, sayur bayam, dan tahu goreng – bergizi dan seimbang untuk kebutuhan harian anak.',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Edukasi
            const Text(
              'Edukasi Gizi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/edukasi'),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.play_circle_fill_rounded,
                        size: 48,
                        color: Color(0xFF018175),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pentingnya Makanan Bergizi untuk Anak',
                          style: TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Tombol Back
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: const Color(0xFF018175),
                  onPressed: () {
                    // Cek jika bisa kembali, maka kembali. Jika tidak, jangan lakukan apa-apa.
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                ),
                const Text(
                  'Back',
                  style: TextStyle(fontSize: 12, color: Color(0xFF018175)),
                ),
              ],
            ),

            // Tombol Home
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
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
                      // Sudah di home, tidak perlu aksi
                    },
                  ),
                ),
              ],
            ),

            // Tombol Tambah Makanan
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
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

  Widget _buildQuickActionButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Icon(icon, size: 30, color: Theme.of(context).colorScheme.tertiary),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
