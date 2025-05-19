import 'package:flutter/material.dart';

class EdukasiScreen extends StatelessWidget {
  const EdukasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Contoh data video edukasi dan artikel
    final List<String> videoList = [
      'Video Edukasi 1',
      'Video Edukasi 2',
      'Video Edukasi 3',
      'Video Edukasi 4',
    ];

    final List<String> artikelList = ['Artikel 1', 'Artikel 2', 'Artikel 3'];

    return Scaffold(
      backgroundColor: const Color(
        0xFFFDE9E9,
      ), // warna background seperti desain
      appBar: AppBar(
        backgroundColor: const Color(0xFF018175),
        elevation: 0,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        title: const Text(
          'Edukasi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF016BB8)),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
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
                // sudah di halaman edukasi, tidak perlu navigasi ulang
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Grid Video Edukasi 2x2
            Expanded(
              flex: 3,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: videoList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 kolom
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.play_arrow,
                        size: 48,
                        color: Color(0xFF018175),
                      ),
                      onPressed: () {
                        // aksi saat video ditekan, misal buka detail atau play
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Header Artikel dengan "Lihat Semua"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Artikel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF018175),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // navigasi ke halaman artikel lengkap
                    Navigator.pushNamed(context, '/artikel_lengkap');
                  },
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(color: Color(0xFF018175)),
                  ),
                ),
              ],
            ),

            // List Artikel
            Expanded(
              flex: 2,
              child: ListView.separated(
                itemCount: artikelList.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      artikelList[index],
                      style: const TextStyle(color: Colors.black87),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFF018175),
                    ),
                    onTap: () {
                      // aksi membuka detail artikel
                    },
                  );
                },
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

            // Tombol Home
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
                    Navigator.pushNamed(context, '/tambahmakanan');
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
