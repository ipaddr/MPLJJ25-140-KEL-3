import 'package:flutter/material.dart';

class MakananDitambahkanScreen extends StatelessWidget {
  const MakananDitambahkanScreen({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< Updated upstream
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? deskripsi = args?['deskripsi'] as String?;
    final String? tanggal = args?['tanggal'] as String?;
=======
    final String? deskripsi =
        ModalRoute.of(context)?.settings.arguments as String?;
>>>>>>> Stashed changes

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Makanan Ditambahkan'),
        backgroundColor: colorScheme.tertiary,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 100,
                color: Color(0xFF018175),
              ),
              const SizedBox(height: 24),
              const Text(
                'Makanan berhasil ditambahkan!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF018175),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (deskripsi != null)
                Text(
                  deskripsi,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              if (tanggal != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Tanggal: $tanggal',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName('/home'));
                },
                child: const Text('Selesai'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
