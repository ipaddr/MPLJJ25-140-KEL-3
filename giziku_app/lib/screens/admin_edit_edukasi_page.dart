import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEditEdukasiScreen extends StatefulWidget {
  final String edukasiId;
  final Map<String, dynamic> edukasiData;

  const AdminEditEdukasiScreen({
    super.key,
    required this.edukasiId,
    required this.edukasiData,
  });

  @override
  State<AdminEditEdukasiScreen> createState() => _AdminEditEdukasiScreenState();
}

class _AdminEditEdukasiScreenState extends State<AdminEditEdukasiScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _judulController;
  late TextEditingController _deskripsiController;
  late TextEditingController _kontenController;
  late TextEditingController _authorController;
  late TextEditingController _thumbnailController;
  late TextEditingController _videoUrlController;
  
  String _selectedType = 'artikel'; // artikel atau video
  bool _isLoading = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
  }

  void _initializeControllers() {
    _judulController = TextEditingController(text: widget.edukasiData['judul'] ?? '');
    _deskripsiController = TextEditingController(text: widget.edukasiData['deskripsi'] ?? '');
    _kontenController = TextEditingController(text: widget.edukasiData['konten'] ?? '');
    _authorController = TextEditingController(text: widget.edukasiData['author'] ?? '');
    _thumbnailController = TextEditingController(text: widget.edukasiData['thumbnail'] ?? '');
    _videoUrlController = TextEditingController(text: widget.edukasiData['videoUrl'] ?? '');
    _selectedType = widget.edukasiData['type'] ?? 'artikel';
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _judulController.dispose();
    _deskripsiController.dispose();
    _kontenController.dispose();
    _authorController.dispose();
    _thumbnailController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  Future<void> _updateEdukasi() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final edukasiData = {
        'judul': _judulController.text.trim(),
        'deskripsi': _deskripsiController.text.trim(),
        'konten': _kontenController.text.trim(),
        'author': _authorController.text.trim(),
        'thumbnail': _thumbnailController.text.trim(),
        'type': _selectedType,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Tambahkan videoUrl jika tipe video
      if (_selectedType == 'video') {
        edukasiData['videoUrl'] = _videoUrlController.text.trim();
      }

      await FirebaseFirestore.instance
          .collection('edukasi')
          .doc(widget.edukasiId)
          .update(edukasiData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Edukasi berhasil diperbarui!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context, true); // Return true untuk indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

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
            // Modern SliverAppBar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save, color: Colors.white),
                  onPressed: _isLoading ? null : _updateEdukasi,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Edit Edukasi',
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

            // Main Content
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: EdgeInsets.all(isTablet ? 32.0 : 20.0),
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: isTablet ? 600 : double.infinity,
                          ),
                          child: Column(
                            children: [
                              // Form Card
                              Container(
                                padding: EdgeInsets.all(isTablet ? 32 : 24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Header
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2E7D32).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.edit,
                                              color: Color(0xFF2E7D32),
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          const Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Edit Konten Edukasi',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF2D3748),
                                                  ),
                                                ),
                                                Text(
                                                  'Perbarui informasi edukasi gizi',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF718096),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 32),

                                      // Type Selection
                                      const Text(
                                        'Tipe Konten',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2D3748),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      
                                      Row(
                                        children: [
                                          Expanded(
                                            child: RadioListTile<String>(
                                              title: const Text('Artikel'),
                                              value: 'artikel',
                                              groupValue: _selectedType,
                                              activeColor: const Color(0xFF2E7D32),
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedType = value!;
                                                });
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            child: RadioListTile<String>(
                                              title: const Text('Video'),
                                              value: 'video',
                                              groupValue: _selectedType,
                                              activeColor: const Color(0xFF2E7D32),
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedType = value!;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 24),

                                      // Judul Field
                                      TextFormField(
                                        controller: _judulController,
                                        decoration: InputDecoration(
                                          labelText: 'Judul *',
                                          hintText: 'Masukkan judul edukasi',
                                          prefixIcon: const Icon(
                                            Icons.title,
                                            color: Color(0xFF2E7D32),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF2E7D32),
                                              width: 2,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Judul wajib diisi';
                                          }
                                          return null;
                                        },
                                      ),

                                      const SizedBox(height: 20),

                                      // Deskripsi Field
                                      TextFormField(
                                        controller: _deskripsiController,
                                        maxLines: 3,
                                        decoration: InputDecoration(
                                          labelText: 'Deskripsi *',
                                          hintText: 'Masukkan deskripsi singkat',
                                          prefixIcon: const Icon(
                                            Icons.description,
                                            color: Color(0xFF2E7D32),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF2E7D32),
                                              width: 2,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Deskripsi wajib diisi';
                                          }
                                          return null;
                                        },
                                      ),

                                      const SizedBox(height: 20),

                                      // Author Field
                                      TextFormField(
                                        controller: _authorController,
                                        decoration: InputDecoration(
                                          labelText: 'Penulis/Author *',
                                          hintText: 'Masukkan nama penulis',
                                          prefixIcon: const Icon(
                                            Icons.person,
                                            color: Color(0xFF2E7D32),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF2E7D32),
                                              width: 2,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Nama penulis wajib diisi';
                                          }
                                          return null;
                                        },
                                      ),

                                      const SizedBox(height: 20),

                                      // Thumbnail URL Field
                                      TextFormField(
                                        controller: _thumbnailController,
                                        decoration: InputDecoration(
                                          labelText: 'URL Thumbnail',
                                          hintText: 'Masukkan URL gambar thumbnail',
                                          prefixIcon: const Icon(
                                            Icons.image,
                                            color: Color(0xFF2E7D32),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF2E7D32),
                                              width: 2,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      // Video URL Field (only for video type)
                                      if (_selectedType == 'video') ...[
                                        TextFormField(
                                          controller: _videoUrlController,
                                          decoration: InputDecoration(
                                            labelText: 'URL Video *',
                                            hintText: 'Masukkan URL video YouTube/lainnya',
                                            prefixIcon: const Icon(
                                              Icons.video_library,
                                              color: Color(0xFF2E7D32),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF2E7D32),
                                                width: 2,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey.shade50,
                                          ),
                                          validator: (value) {
                                            if (_selectedType == 'video' && 
                                                (value == null || value.isEmpty)) {
                                              return 'URL video wajib diisi untuk tipe video';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                      ],

                                      // Konten Field
                                      TextFormField(
                                        controller: _kontenController,
                                        maxLines: 8,
                                        decoration: InputDecoration(
                                          labelText: 'Konten *',
                                          hintText: _selectedType == 'artikel' 
                                              ? 'Masukkan isi artikel lengkap'
                                              : 'Masukkan deskripsi video',
                                          prefixIcon: const Icon(
                                            Icons.article,
                                            color: Color(0xFF2E7D32),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF2E7D32),
                                              width: 2,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Konten wajib diisi';
                                          }
                                          return null;
                                        },
                                      ),

                                      const SizedBox(height: 32),

                                      // Action Buttons
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: _isLoading ? null : () => Navigator.pop(context),
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(color: Color(0xFF2E7D32)),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                padding: const EdgeInsets.symmetric(vertical: 16),
                                              ),
                                              child: const Text(
                                                'Batal',
                                                style: TextStyle(
                                                  color: Color(0xFF2E7D32),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: _isLoading ? null : _updateEdukasi,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF2E7D32),
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                padding: const EdgeInsets.symmetric(vertical: 16),
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
                                                      'Simpan Perubahan',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Info Card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.blue.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.blue.shade600,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        'Pastikan semua informasi sudah benar sebelum menyimpan. Perubahan akan langsung terlihat oleh pengguna.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF1565C0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}