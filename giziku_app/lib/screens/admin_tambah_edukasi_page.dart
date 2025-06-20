import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminTambahEdukasiScreen extends StatefulWidget {
  const AdminTambahEdukasiScreen({super.key});

  @override
  State<AdminTambahEdukasiScreen> createState() => _AdminTambahEdukasiScreenState();
}

class _AdminTambahEdukasiScreenState extends State<AdminTambahEdukasiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _kontenController = TextEditingController();
  final _penulisController = TextEditingController();
  final _waktuBacaController = TextEditingController();
  final _durasiController = TextEditingController();
  final _urlController = TextEditingController();
  
  String _jenisKonten = 'Artikel';
  bool _isLoading = false;

  @override
  void dispose() {
    _judulController.dispose();
    _kontenController.dispose();
    _penulisController.dispose();
    _waktuBacaController.dispose();
    _durasiController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _saveEdukasi() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('edukasi').add({
        'judul': _judulController.text.trim(),
        'jenis': _jenisKonten,
        'konten': _jenisKonten == 'Artikel' ? _kontenController.text.trim() : '',
        'penulis': _jenisKonten == 'Artikel' ? _penulisController.text.trim() : 'Admin',
        'waktuBaca': _jenisKonten == 'Artikel' ? _waktuBacaController.text.trim() : '',
        'durasi': _jenisKonten == 'Video' ? _durasiController.text.trim() : '',
        'url': _jenisKonten == 'Video' ? _urlController.text.trim() : '',
        'dilihat': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konten edukasi berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error saving edukasi: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menambahkan konten edukasi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF388E3C),
              Color(0xFF43A047),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Tambah Konten Edukasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2E7D32),
                        Color(0xFF388E3C),
                        Color(0xFF43A047),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Jenis Konten
                        const Text(
                          'Jenis Konten',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Artikel'),
                                value: 'Artikel',
                                groupValue: _jenisKonten,
                                onChanged: (value) {
                                  setState(() {
                                    _jenisKonten = value!;
                                  });
                                },
                                activeColor: const Color(0xFF2E7D32),
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Video'),
                                value: 'Video',
                                groupValue: _jenisKonten,
                                onChanged: (value) {
                                  setState(() {
                                    _jenisKonten = value!;
                                  });
                                },
                                activeColor: const Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Judul
                        TextFormField(
                          controller: _judulController,
                          decoration: InputDecoration(
                            labelText: 'Judul',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF2E7D32),
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Judul wajib diisi';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Conditional Fields based on content type
                        if (_jenisKonten == 'Artikel') ...[
                          // Konten Artikel
                          TextFormField(
                            controller: _kontenController,
                            decoration: InputDecoration(
                              labelText: 'Konten Artikel',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2E7D32),
                                  width: 2,
                                ),
                              ),
                            ),
                            maxLines: 8,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Konten artikel wajib diisi';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Penulis
                          TextFormField(
                            controller: _penulisController,
                            decoration: InputDecoration(
                              labelText: 'Penulis',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2E7D32),
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Penulis wajib diisi';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Waktu Baca
                          TextFormField(
                            controller: _waktuBacaController,
                            decoration: InputDecoration(
                              labelText: 'Waktu Baca (contoh: 5 min)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2E7D32),
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Waktu baca wajib diisi';
                              }
                              return null;
                            },
                          ),
                        ] else ...[
                          // Durasi Video
                          TextFormField(
                            controller: _durasiController,
                            decoration: InputDecoration(
                              labelText: 'Durasi Video (contoh: 5:30)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2E7D32),
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Durasi video wajib diisi';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // URL Video
                          TextFormField(
                            controller: _urlController,
                            decoration: InputDecoration(
                              labelText: 'URL Video (opsional)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2E7D32),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 32),
                        
                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveEdukasi,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Simpan Konten',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}