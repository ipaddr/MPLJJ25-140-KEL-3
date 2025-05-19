import 'package:flutter/material.dart';

class RiwayatAmbilMakananScreen extends StatelessWidget {
  const RiwayatAmbilMakananScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> riwayat = [
      {'tanggal': '22/03/2025', 'paket': 'Paket 1', 'status': 'Sudah'},
      {'tanggal': '22/04/2025', 'paket': 'Paket 2', 'status': 'Belum'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF10b68d),
      appBar: AppBar(
        backgroundColor: const Color(0xFF018175),
        title: const Text(
          'Riwayat Ambil Makanan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: riwayat.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = riwayat[index];
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    data['tanggal']!,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    data['paket']!,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    data['status']!,
                    style: TextStyle(
                      color:
                          data['status'] == 'Sudah' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
