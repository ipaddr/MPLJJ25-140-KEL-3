import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onSwipeToMenu;

  const HomeScreen({Key? key, required this.onSwipeToMenu}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Geser ke kiri untuk ke Menu
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
          onSwipeToMenu(); // Navigasi ke menu saat swipe kiri
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F9FF),
        appBar: AppBar(
          backgroundColor: const Color(0xFF016BB8),
          title: const Text('Beranda'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan salam dan nama pengguna
              const Text(
                "Halo, Thoriq!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF016BB8),
                ),
              ),
              const SizedBox(height: 12),

              // Banner Info Gizi
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF319FE8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  "Pantau perkembangan gizi si kecil secara rutin untuk hasil maksimal!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Tombol navigasi ke menu
              ElevatedButton.icon(
                onPressed: onSwipeToMenu,
                icon: const Icon(Icons.menu),
                label: const Text("Lihat Menu"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF016BB8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
