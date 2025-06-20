import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:giziku_app/screens/detail_artikel_screen.dart';

class ArtikelLengkapScreen extends StatefulWidget {
  const ArtikelLengkapScreen({Key? key}) : super(key: key);

  @override
  State<ArtikelLengkapScreen> createState() => _ArtikelLengkapScreenState();
}

class _ArtikelLengkapScreenState extends State<ArtikelLengkapScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  List<Map<String, dynamic>> _artikelList = [];
  String _searchQuery = '';
  String _selectedFilter = 'Semua'; // Semua, Artikel, Video

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadArtikelData();
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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadArtikelData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      print('Loading data from Firebase...'); // Debug log

      // Load semua data edukasi dari Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('edukasi')
          .orderBy('createdAt', descending: true)
          .get();

      print('Firebase returned ${snapshot.docs.length} documents'); // Debug log

      List<Map<String, dynamic>> edukasiData = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        edukasiData.add(data);
        print('Document: ${doc.id} - ${data['judul']}'); // Debug log
      }

      if (mounted) {
        setState(() {
          _artikelList = edukasiData;
          _isLoading = false;
        });
      }

      print(
          'Data loaded successfully: ${_artikelList.length} items'); // Debug log
    } catch (e) {
      print('Error loading artikel data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error memuat data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _incrementViewCount(String edukasiId) async {
    try {
      await FirebaseFirestore.instance
          .collection('edukasi')
          .doc(edukasiId)
          .update({
        'views': FieldValue.increment(1),
        'lastViewed': FieldValue.serverTimestamp(),
      });

      // Track user reading history
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('userReadingHistory').add({
          'userId': user.uid,
          'edukasiId': edukasiId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  List<Map<String, dynamic>> _getFilteredArticles() {
    List<Map<String, dynamic>> filtered = _artikelList;

    // Filter berdasarkan tipe
    if (_selectedFilter == 'Artikel') {
      filtered = filtered
          .where((item) =>
              (item['jenis'] == 'Artikel' || item['type'] == 'artikel'))
          .toList();
    } else if (_selectedFilter == 'Video') {
      filtered = filtered
          .where(
              (item) => (item['jenis'] == 'Video' || item['type'] == 'video'))
          .toList();
    }

    // Filter berdasarkan search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final judul = (item['judul'] ?? '').toLowerCase();
        final deskripsi = (item['deskripsi'] ?? '').toLowerCase();
        final author = (item['penulis'] ?? item['author'] ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();

        return judul.contains(query) ||
            deskripsi.contains(query) ||
            author.contains(query);
      }).toList();
    }

    return filtered;
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Tanggal tidak tersedia';

    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is String) {
      try {
        date = DateTime.parse(timestamp);
      } catch (e) {
        return 'Tanggal tidak valid';
      }
    } else {
      return 'Format tanggal tidak dikenali';
    }

    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  String _estimateReadingTime(String content) {
    if (content.isEmpty) return '1 menit';
    final wordCount = content.split(' ').length;
    final minutes = (wordCount / 200).ceil();
    return '$minutes menit';
  }

  @override
  Widget build(BuildContext context) {
    final filteredArticles = _getFilteredArticles();

    return Scaffold(
      body: Container(
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
        child: CustomScrollView(
          slivers: [
            // Modern SliverAppBar
            SliverAppBar(
              expandedHeight: 160,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _loadArtikelData,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Semua Edukasi',
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
                        Color(0xFF018175),
                        Color(0xFF10b68d),
                        Color(0xFF4fd1c7),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.school,
                      size: 80,
                      color: Colors.white24,
                    ),
                  ),
                ),
              ),
            ),

            // Search and Filter Section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(20),
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
                child: Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari artikel, video, atau penulis...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF018175),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF018175),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                    ),

                    // Filter Chips
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 16),
                      child: Row(
                        children: [
                          const Text(
                            'Filter: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children:
                                    ['Semua', 'Artikel', 'Video'].map((filter) {
                                  final isSelected = _selectedFilter == filter;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text(filter),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          _selectedFilter = filter;
                                        });
                                      },
                                      selectedColor: const Color(0xFF018175)
                                          .withOpacity(0.2),
                                      checkmarkColor: const Color(0xFF018175),
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFF018175)
                                            : Colors.grey.shade600,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  );
                                }).toList(),
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

            // Content List
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Daftar Konten (${filteredArticles.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          if (filteredArticles.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF018175).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _selectedFilter,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF018175),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(
                            color: Color(0xFF018175),
                          ),
                        ),
                      )
                    else if (filteredArticles.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'Tidak ada hasil untuk "${_searchQuery}"'
                                    : 'Belum ada konten edukasi',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredArticles.length,
                              separatorBuilder: (_, __) => const Divider(
                                height: 1,
                                color: Color(0xFFE2E8F0),
                              ),
                              itemBuilder: (context, index) {
                                final artikel = filteredArticles[index];
                                return _buildArtikelItem(artikel, index);
                              },
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtikelItem(Map<String, dynamic> artikel, int index) {
    return InkWell(
      onTap: () {
        _incrementViewCount(artikel['id']);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailArtikelScreen(
              edukasiId: artikel['id'],
              edukasiData: artikel,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail/Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF018175).withOpacity(0.8),
                    const Color(0xFF10b68d).withOpacity(0.6),
                  ],
                ),
              ),
              child: artikel['thumbnail'] != null &&
                      artikel['thumbnail'].isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        artikel['thumbnail'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            _getItemType(artikel) == 'video'
                                ? Icons.video_library
                                : Icons.article,
                            color: Colors.white,
                            size: 32,
                          );
                        },
                      ),
                    )
                  : Icon(
                      _getItemType(artikel) == 'video'
                          ? Icons.video_library
                          : Icons.article,
                      color: Colors.white,
                      size: 32,
                    ),
            ),

            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getItemType(artikel) == 'video'
                          ? Colors.red.shade100
                          : Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getItemType(artikel) == 'video' ? 'VIDEO' : 'ARTIKEL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getItemType(artikel) == 'video'
                            ? Colors.red.shade700
                            : Colors.blue.shade700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Title
                  Text(
                    artikel['judul'] ?? 'Tanpa Judul',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Description
                  Text(
                    artikel['deskripsi'] ?? 'Tanpa deskripsi',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Meta Info
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          artikel['penulis'] ?? artikel['author'] ?? 'Admin',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.visibility,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${artikel['views'] ?? artikel['dilihat'] ?? 0}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Date and Reading Time
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(artikel['createdAt'] ?? artikel['tanggal']),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      if (_getItemType(artikel) == 'artikel') ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          artikel['waktuBaca'] ??
                              _estimateReadingTime(artikel['konten'] ?? ''),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF018175).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF018175),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getItemType(Map<String, dynamic> item) {
    // Check multiple possible field names for type
    return item['type'] ?? item['jenis']?.toLowerCase() ?? 'artikel';
  }
}
