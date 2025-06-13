import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Halaman utama untuk menampilkan profil pengguna
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Variabel untuk menyimpan path file gambar yang telah dipilih oleh pengguna.
  // Awalnya null karena belum ada gambar yang dipilih.
  File? _imageFile;

  // Fungsi ini dipanggil saat pengguna menekan tombol ganti foto.
  // Menggunakan package 'image_picker' untuk membuka galeri.
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    // Membuka galeri untuk memilih sebuah gambar.
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    // Jika pengguna berhasil memilih sebuah file (tidak membatalkan).
    if (pickedFile != null) {
      // Perbarui state untuk menampilkan gambar baru di UI.
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Data statis untuk profil, sesuai permintaan Anda.
    // Nantinya, data ini bisa diambil dari database atau state management.
    final String namaAnak = "Adinda Putri";
    final String umurAnak = "8 Tahun";
    final String kelas = "2 SD";
    final String email = "orangtua.dinda@email.com";
    final String noTelepon = "0812-3456-7890";

    return Scaffold(
      // Scaffold akan menggunakan warna latar belakang dari tema global Anda
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        // AppBar ini akan otomatis menggunakan gaya dari tema global Anda
        // seperti warna latar, teks, dan ikon.
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // --- BAGIAN FOTO PROFIL ---
          Center(
            child: Stack(
              clipBehavior:
                  Clip.none, // Izinkan tombol edit sedikit keluar dari lingkaran
              children: [
                CircleAvatar(
                  radius: 70,
                  // Tampilkan gambar yang dipilih pengguna. Jika _imageFile masih null,
                  // tampilkan ikon orang sebagai default.
                  backgroundImage:
                      _imageFile != null
                          ? FileImage(_imageFile!) // Tampilkan gambar dari file
                          : null, // Atau null jika ingin child (Icon) yang ditampilkan
                  backgroundColor: Colors.grey.shade300,
                  child:
                      _imageFile == null
                          ? Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.grey.shade600,
                          )
                          : null,
                ),
                // Tombol kecil untuk mengganti foto
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Material(
                    color:
                        Theme.of(
                          context,
                        ).colorScheme.tertiary, // Warna dari tema
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    elevation: 4.0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed:
                          _pickImage, // Panggil fungsi untuk memilih gambar
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- BAGIAN DETAIL PROFIL DALAM SEBUAH KARTU ---
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  ProfileInfoTile(
                    icon: Icons.child_care,
                    label: 'Nama Anak',
                    value: namaAnak,
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  ProfileInfoTile(
                    icon: Icons.cake_outlined,
                    label: 'Umur Anak',
                    value: umurAnak,
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  ProfileInfoTile(
                    icon: Icons.school_outlined,
                    label: 'Kelas',
                    value: kelas,
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  ProfileInfoTile(
                    icon: Icons.email_outlined,
                    label: 'Email Orang Tua',
                    value: email,
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  ProfileInfoTile(
                    icon: Icons.phone_outlined,
                    label: 'No. Telepon',
                    value: noTelepon,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget kustom untuk menampilkan setiap baris info profil.
// Dibuat agar kode di dalam 'build' tidak berulang dan lebih rapi.
class ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        label,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }
}
