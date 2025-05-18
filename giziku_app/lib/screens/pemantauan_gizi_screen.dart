import 'package:flutter/material.dart';

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

  String statusGizi = 'Normal'; // Default
  String rekomendasi = 'Makanan 4 Sehat 5 Sempurna';

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
