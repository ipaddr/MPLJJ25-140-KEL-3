import 'package:flutter/material.dart';

IconData getEmoticonForStatus(String? status) {
  switch (status) {
    case 'Kurang':
      return Icons.sentiment_very_dissatisfied;
    case 'Berlebih': // Di pemantauan_gizi_screen.dart ada komentar: Atau Icons.mood_bad
      return Icons.sentiment_dissatisfied;
    case 'Obesitas': // Menambahkan case untuk Obesitas, menggunakan ikon yang sama dengan Berlebih
      return Icons.sentiment_dissatisfied;
    case 'Normal':
    default:
      return Icons.sentiment_very_satisfied;
  }
}

Color getColorForStatus(String? status, BuildContext context) {
  switch (status) {
    case 'Kurang':
      // Di PemantauanGiziScreen menggunakan: return const Color.fromARGB(255, 187, 255, 0); // Kuning-hijau
      // Menggunakan warna dari HomeScreen untuk konsistensi awal:
      return const Color.fromARGB(255, 235, 220, 52); // Kuning
    case 'Berlebih':
      return const Color.fromARGB(255, 255, 82, 82); // Merah
    case 'Obesitas': // Menambahkan case untuk Obesitas
      return const Color.fromARGB(255, 180, 50, 50); // Merah Tua (Sesuai PemantauanGiziScreen)
    case 'Normal':
    default:
      // Di PemantauanGiziScreen menggunakan: return const Color.fromARGB(255, 34, 255, 0); // Hijau cerah
      // Menggunakan warna dari HomeScreen untuk konsistensi awal:
      return const Color.fromARGB(255, 76, 175, 80); // Hijau
  }
}
