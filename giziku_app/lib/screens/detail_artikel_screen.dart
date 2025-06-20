import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DetailArtikelScreen extends StatefulWidget {
  final String edukasiId;
  final Map<String, dynamic> edukasiData;

  const DetailArtikelScreen({
    Key? key,
    required this.edukasiId,
    required this.edukasiData,
  }) : super(key: key);

  @override
  State<DetailArtikelScreen> createState() => _DetailArtikelScreenState();
}

class _DetailArtikelScreenState extends State<DetailArtikelScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _hasError = false;
  Map<String, dynamic>? _artikelData;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadArtikelData();
    _incrementViewCount();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    super.dispose();
  }

  Future<void> _loadArtikelData() async {
    try {
      // Load data artikel dari Firestore
      final doc = await FirebaseFirestore.instance
          .collection('edukasi')
          .doc(widget.edukasiId)
          .get();

      if (doc.exists && mounted) {
        setState(() {
          _artikelData = {
            'id': doc.id,
            ...doc.data()!,
          };
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading artikel: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _incrementViewCount() async {
    try {
      // Increment view count
      await FirebaseFirestore.instance
          .collection('edukasi')
          .doc(widget.edukasiId)
          .update({
        'dilihat': FieldValue.increment(1),
        'lastViewed': FieldValue.serverTimestamp(),
      });

      // Track user reading history (optional)
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('userReadingHistory').add({
          'userId': user.uid,
          'edukasiId': widget.edukasiId,
          'type': 'artikel',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Tanggal tidak tersedia';

    final date = timestamp.toDate();
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  String _estimateReadingTime(String content) {
    // Estimasi waktu baca: rata-rata 200 kata per menit
    final wordCount = content.split(' ').length;
    final minutes = (wordCount / 200).ceil();
    return '$minutes menit';
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF018175),
                Color(0xFF10b68d),
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Memuat artikel...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_hasError || _artikelData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: const Color(0xFF018175),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Artikel tidak ditemukan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Artikel mungkin telah dihapus atau terjadi kesalahan',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF018175),
                ),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                slivers: [
                  // Modern SliverAppBar with Hero Image
                  SliverAppBar(
                    expandedHeight: 280,
                    floating: false,
                    pinned: true,
                    backgroundColor: const Color(0xFF018175),
                    leading: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child:
                            const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.share, color: Colors.white),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fitur berbagi akan segera hadir'),
                              backgroundColor: Color(0xFF018175),
                            ),
                          );
                        },
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background Image or Gradient
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF018175),
                                  Color(0xFF10b68d),
                                  Color(0xFF4fd1c7),
                                ],
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.article,
                                size: 100,
                                color: Colors.white54,
                              ),
                            ),
                          ),

                          // Gradient Overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.4),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Article Content
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Article Header
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF018175).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                (_artikelData!['jenis'] ?? 'ARTIKEL')
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF018175),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Article Title
                            Text(
                              _artikelData!['judul'] ?? 'Tanpa Judul',
                              style: TextStyle(
                                fontSize: isTablet ? 32 : 28,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2D3748),
                                height: 1.2,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Article Meta Info
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor:
                                      const Color(0xFF018175).withOpacity(0.1),
                                  child: const Icon(
                                    Icons.person,
                                    color: Color(0xFF018175),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _artikelData!['penulis'] ??
                                            'Admin GiziKu',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        _formatDate(_artikelData!['createdAt']),
                                        style: const TextStyle(
                                          color: Color(0xFF718096),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: Colors.blue.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _artikelData!['waktuBaca'] ??
                                            _estimateReadingTime(
                                                _artikelData!['konten'] ?? ''),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Article Content
                            Container(
                              width: double.infinity,
                              child: Text(
                                _artikelData!['konten'] ??
                                    'Konten tidak tersedia',
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
                                  color: const Color(0xFF2D3748),
                                  height: 1.8,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Article Stats
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7FAFC),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      const Icon(
                                        Icons.visibility,
                                        color: Color(0xFF018175),
                                        size: 24,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${_artikelData!['dilihat'] ?? 0}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2D3748),
                                        ),
                                      ),
                                      const Text(
                                        'Views',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF718096),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 1,
                                    height: 50,
                                    color: Colors.grey.shade300,
                                  ),
                                  Column(
                                    children: [
                                      const Icon(
                                        Icons.schedule,
                                        color: Color(0xFF018175),
                                        size: 24,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _artikelData!['waktuBaca'] ??
                                            _estimateReadingTime(
                                                _artikelData!['konten'] ?? ''),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2D3748),
                                        ),
                                      ),
                                      const Text(
                                        'Waktu Baca',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF718096),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Back Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Kembali ke Edukasi'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF018175),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
