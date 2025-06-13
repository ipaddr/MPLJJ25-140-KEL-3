import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller untuk input form
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nikController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? errorMessage;

  void daftar() {
    setState(() {
      errorMessage = null;
    });

    if (namaController.text.isEmpty ||
        nikController.text.isEmpty ||
        emailController.text.isEmpty ||
        teleponController.text.isEmpty ||
        passwordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Semua field harus diisi!';
      });
      return;
    }

    // Kalau lolos validasi
    setState(() {
      errorMessage = null;
    });

    // Contoh aksi setelah validasi
    print('Daftar berhasil!');
    print('Nama Lengkap: ${namaController.text}');
    print('NIK: ${nikController.text}');
    print('Email: ${emailController.text}');
    print('No Telepon: ${teleponController.text}');
    print('Password: ${passwordController.text}');

    //
    Navigator.pop(context);
  }

  @override
  void dispose() {
    //
    namaController.dispose();
    nikController.dispose();
    emailController.dispose();
    teleponController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10b68d), // latar belakang hijau baru
      appBar: AppBar(
        backgroundColor: const Color(0xFF018175),
        centerTitle: true,
        elevation: 0,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          label: const Text('Kembali', style: TextStyle(color: Colors.white)),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.only(left: 12),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        title: const Text('Register', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset('assets/logo.png', height: 120),
                const SizedBox(height: 30),

                TextField(
                  controller: namaController,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),
                TextField(
                  controller: nikController,
                  decoration: InputDecoration(
                    labelText: 'NIK',
                    prefixIcon: const Icon(Icons.badge),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 16),
                TextField(
                  controller: teleponController,
                  decoration: InputDecoration(
                    labelText: 'No Telepon',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 24),

                if (errorMessage != null) ...[
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                ],

                ElevatedButton(
                  onPressed: daftar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF018175),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 100,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Daftar', style: TextStyle(fontSize: 16)),
                ),

                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Sudah punya akun? Login sekarang!',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
