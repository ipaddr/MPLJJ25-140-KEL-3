import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController tinggiController = TextEditingController();
  final TextEditingController beratController = TextEditingController();
  final TextEditingController umurController = TextEditingController();

  @override
  void dispose() {
    tinggiController.dispose();
    beratController.dispose();
    umurController.dispose();
    super.dispose();
  }

  void cekGizi() {
    // Contoh fungsi cek gizi, nanti bisa diganti dengan logika yang kamu mau
    final tinggi = double.tryParse(tinggiController.text);
    final berat = double.tryParse(beratController.text);
    final umur = int.tryParse(umurController.text);

    if (tinggi == null || berat == null || umur == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi semua data dengan benar')),
      );
      return;
    }

    // Contoh output (bisa diganti dengan kalkulasi sesungguhnya)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Cek gizi untuk tinggi: $tinggi cm, berat: $berat kg, umur: $umur tahun',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10b68d),
      appBar: AppBar(
        backgroundColor: const Color(0xFF018175),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/menu');
          },
        ),
        title: const Text(
          'Beranda',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form input tinggi, berat, umur
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: tinggiController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Tinggi Badan (cm)',
                      prefixIcon: const Icon(
                        Icons.height,
                        color: Color(0xFF018175),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: beratController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Berat Badan (kg)',
                      prefixIcon: const Icon(
                        Icons.monitor_weight,
                        color: Color(0xFF018175),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: umurController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Umur (tahun)',
                      prefixIcon: const Icon(
                        Icons.cake,
                        color: Color(0xFF018175),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: cekGizi,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF018175),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 50,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cek Gizi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Box IMT
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Normal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF018175),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'IMT (Indeks Massa Tubuh):\n18,5 kg/m²',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF018175),
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.show_chart, size: 48, color: Color(0xFF018175)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Rekomendasi Makanan
            const Text(
              'Rekomendasi Makanan Hari ini',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF018175),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: AssetImage('assets/makanan1.jpg'),
                        fit: BoxFit.cover,
                      ),
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

            const SizedBox(height: 24),

            // Edukasi
            const Text(
              'Edukasi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF018175),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/edukasi'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.play_circle_fill,
                      size: 48,
                      color: Color(0xFF018175),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pentingnya Makanan Bergizi untuk Anak',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF018175),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'More'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/add');
          }
          // Tombol More tidak diarahkan ke mana-mana
        },
      ),
    );
  }
}
