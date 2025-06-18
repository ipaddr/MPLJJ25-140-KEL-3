import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _kelasController = TextEditingController();
  final TextEditingController _namaOrtuController = TextEditingController();

  String? _nama;
  String? _email;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _email = user.email;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _nama = data['nama'] ?? '';
        _kelasController.text = data['kelas'] ?? '';
        _namaOrtuController.text = data['namaOrtu'] ?? '';
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _simpanProfil() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'kelas': _kelasController.text.trim(),
        'namaOrtu': _namaOrtuController.text.trim(),
      }, SetOptions(merge: true));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
      }
    }
  }

  @override
  void dispose() {
    _kelasController.dispose();
    _namaOrtuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Color(0xFF10b68d),
                            child: Icon(Icons.person,
                                size: 50, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 30),

                        /// Nama (fixed)
                        const Text('Nama Anak',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(_nama ?? '-',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 20),

                        /// Email (fixed)
                        const Text('Email',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(_email ?? '-',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 20),

                        /// Kelas (editable)
                        TextFormField(
                          controller: _kelasController,
                          decoration: const InputDecoration(labelText: 'Kelas'),
                          validator: (value) => value!.isEmpty
                              ? 'Kelas tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        /// Nama Orang Tua (editable)
                        TextFormField(
                          controller: _namaOrtuController,
                          decoration: const InputDecoration(
                              labelText: 'Nama Orang Tua'),
                          validator: (value) => value!.isEmpty
                              ? 'Nama orang tua tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 30),

                        Center(
                          child: Column(
                            children: [
                              ElevatedButton(
                                onPressed: _simpanProfil,
                                child: const Text('Simpan'),
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton(
                                onPressed: () async {
                                  await FirebaseAuth.instance.signOut();
                                  if (context.mounted) {
                                    Navigator.pushReplacementNamed(
                                        context, '/login');
                                  }
                                },
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
