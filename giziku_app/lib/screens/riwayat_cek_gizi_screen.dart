import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giziku_app/utils/gizi_helpers.dart'; // Import helper untuk warna
import 'package:intl/intl.dart'; // Import untuk formatting tanggal

class RiwayatCekGiziScreen extends StatefulWidget {
  const RiwayatCekGiziScreen({super.key});

  @override
  State<RiwayatCekGiziScreen> createState() => _RiwayatCekGiziScreenState();
}

class _RiwayatCekGiziScreenState extends State<RiwayatCekGiziScreen> {
  String _namaPengguna = "Pengguna";
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadDataPengguna();
  }

  Future<void> _loadDataPengguna() async {
    if (_currentUser != null) {
      if (mounted) {
        setState(() {
          _namaPengguna = _currentUser!.displayName ?? _currentUser!.email ?? "Pengguna";
        });
      }
    }
  }

  Stream<QuerySnapshot>? _getRiwayatStream() {
    if (_currentUser == null) {
      return null;
    }
    return FirebaseFirestore.instance
        .collection('riwayatCekGizi')
        .where('userId', isEqualTo: _currentUser!.uid) // Filter
        .orderBy('tanggalPengecekan', descending: true) // Order
        .snapshots();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10b68d),
      appBar: AppBar(
        backgroundColor: const Color(0xFF018175),
        elevation: 0,
        // Leading button (menu atau back) akan otomatis ditangani oleh Flutter
        // berdasarkan keberadaan Drawer atau kemampuan untuk pop.
        title: const Text(
          'Riwayat Cek Gizi',
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
              tileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1), // Menandai halaman aktif
              onTap: () {
                Navigator.pop(context);
                // Sudah di halaman ini, tidak perlu navigasi
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _getRiwayatStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                  child: Text('Belum ada riwayat cek gizi.',
                      style: TextStyle(color: Colors.white70, fontSize: 16)));
            }

            final riwayatDocs = snapshot.data!.docs;

            return ListView.separated(
              itemCount: riwayatDocs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final data = riwayatDocs[index].data() as Map<String, dynamic>;
                final Timestamp timestamp = data['tanggalPengecekan'] as Timestamp? ?? Timestamp.now();
                final DateTime tanggal = timestamp.toDate();
                final String tanggalFormatted = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(tanggal);

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                     boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tanggalFormatted,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Nama Anak: ${data['nama'] ?? '-'}', style: const TextStyle(fontSize: 14)),
                      Text('Usia: ${data['usia']?.toString() ?? '-'} tahun', style: const TextStyle(fontSize: 14)),
                      Text('Berat Badan: ${data['beratBadan']?.toStringAsFixed(1) ?? '-'} kg', style: const TextStyle(fontSize: 14)),
                      Text('Tinggi Badan: ${data['tinggiBadan']?.toStringAsFixed(0) ?? '-'} cm', style: const TextStyle(fontSize: 14)),
                      Text('IMT: ${data['imt']?.toStringAsFixed(1) ?? '-'}', style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        'Status Gizi: ${data['statusGizi'] ?? '-'}',
                        style: TextStyle(
                          color: getColorForStatus(data['statusGizi'], context),
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        color: Colors.white,
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
                if (ModalRoute.of(context)?.settings.name != '/home') {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  );
                }
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
            padding: const EdgeInsets.all(4),
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
        if (!isCentral)
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
      ],
    );
  }
}
