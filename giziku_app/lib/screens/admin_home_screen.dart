import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giziku_app/screens/admin_bottom_navigation_bar.dart';
import 'package:intl/intl.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 1;
  String _namaAdmin = "Admin";
  bool _isLoading = true;

  Map<String, int> _statusGiziData = {};
  List<Map<String, dynamic>> _recentActivities = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAdminData();
    _loadStatistikData();
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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final adminDoc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(user.uid)
            .get();

        if (adminDoc.exists && mounted) {
          setState(() {
            _namaAdmin = adminDoc.data()?['nama'] ?? 'Admin';
          });
        }
      } catch (e) {
        print('Error loading admin data: $e');
      }
    }
  }

  Future<void> _loadStatistikData() async {
    try {
      print('Mulai loading statistik data...'); // Debug log

      // Load status gizi anak (dari collection riwayatCekGizi)
      await _loadStatusGizi();

      // Load aktivitas terbaru
      await _loadRecentActivities();

      print('Selesai loading statistik data'); // Debug log

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading statistik data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadStatusGizi() async {
    try {
      // Ambil data status gizi terbaru untuk setiap anak
      final giziSnapshot = await FirebaseFirestore.instance
          .collection('riwayatCekGizi')
          .orderBy('tanggalPengecekan', descending: true)
          .get();

      Map<String, String> latestStatusByUser = {};
      Map<String, int> statusCount = {
        'Normal': 0,
        'Kurang': 0,
        'Berlebih': 0,
        'Obesitas': 0,
      };

      // Ambil status terbaru untuk setiap user
      for (var doc in giziSnapshot.docs) {
        final data = doc.data();
        final userId = data['userId'] as String;
        final status = data['statusGizi'] as String? ?? 'Normal';

        if (!latestStatusByUser.containsKey(userId)) {
          latestStatusByUser[userId] = status;
        }
      }

      // Hitung jumlah setiap status
      for (var status in latestStatusByUser.values) {
        if (statusCount.containsKey(status)) {
          statusCount[status] = statusCount[status]! + 1;
        }
      }

      if (mounted) {
        setState(() {
          _statusGiziData = statusCount;
        });
      }
    } catch (e) {
      print('Error loading status gizi: $e');
    }
  }

  Future<void> _loadRecentActivities() async {
    try {
      // Ambil aktivitas terbaru dari riwayat cek gizi
      final recentGizi = await FirebaseFirestore.instance
          .collection('riwayatCekGizi')
          .orderBy('tanggalPengecekan', descending: true)
          .limit(5)
          .get();

      // Ambil aktivitas terbaru dari riwayat ambil makanan
      final recentMakanan = await FirebaseFirestore.instance
          .collection('riwayatAmbilMakanan')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();

      List<Map<String, dynamic>> activities = [];

      // Tambahkan aktivitas cek gizi
      for (var doc in recentGizi.docs) {
        final data = doc.data();
        activities.add({
          'type': 'cek_gizi',
          'title': 'Cek Gizi: ${data['nama'] ?? 'Anak'}',
          'subtitle': 'Status: ${data['statusGizi'] ?? 'Normal'}',
          'time': data['tanggalPengecekan'] as Timestamp,
          'icon': Icons.health_and_safety,
          'color': _getColorForStatus(data['statusGizi']),
        });
      }

      // Tambahkan aktivitas ambil makanan
      for (var doc in recentMakanan.docs) {
        final data = doc.data();
        activities.add({
          'type': 'ambil_makanan',
          'title': 'Ambil Makanan: Paket ${data['tipeMakanan'] ?? '?'}',
          'subtitle':
              'Deskripsi: ${data['deskripsi'] ?? 'Tidak ada deskripsi'}',
          'time':
              data['timestamp'] as Timestamp? ?? data['tanggal'] as Timestamp,
          'icon': Icons.restaurant_menu,
          'color': const Color(0xFF4CAF50),
        });
      }

      // Urutkan berdasarkan waktu
      activities.sort(
          (a, b) => (b['time'] as Timestamp).compareTo(a['time'] as Timestamp));

      if (mounted) {
        setState(() {
          _recentActivities = activities.take(10).toList();
        });
      }
    } catch (e) {
      print('Error loading recent activities: $e');
    }
  }

  Color _getColorForStatus(String? status) {
    switch (status) {
      case 'Normal':
        return const Color(0xFF4CAF50);
      case 'Kurang':
        return const Color(0xFFFF9800);
      case 'Berlebih':
        return const Color(0xFFFF5722);
      case 'Obesitas':
        return const Color(0xFFD32F2F);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/admin_dashboard_makanan');
        break;
      case 1:
        // Stay on Home screen
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/admin_kelola_edukasi');
        break;
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
              expandedHeight: isTablet ? 200 : 180,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                    });
                    _loadStatistikData();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
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
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Icon(
                                  Icons.admin_panel_settings,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Dashboard Admin',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Selamat datang, $_namaAdmin',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Kelola data gizi anak dengan mudah 📊',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Main Content
            SliverToBoxAdapter(
              child: _isLoading
                  ? _buildLoadingState()
                  : FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Statistik Cards (dihapus)
                            // const SizedBox(height: 24), // Dihapus jika tidak ada statistik card di atasnya

                            // Status Gizi Chart
                            _buildStatusGiziChart(),

                            const SizedBox(height: 24),

                            // Recent Activities
                            _buildRecentActivities(),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      drawer: _buildModernDrawer(),
      bottomNavigationBar: AdminBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 400,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF2E7D32)),
            SizedBox(height: 16),
            Text('Memuat data dashboard...'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusGiziChart() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Status Gizi Anak',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 20),
          if (_statusGiziData.isEmpty)
            const Center(
              child: Text(
                'Belum ada data status gizi',
                style: TextStyle(color: Color(0xFF718096)),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _statusGiziData.entries.map((entry) {
                return _buildBar(
                  entry.key,
                  entry.value,
                  _getColorForStatus(entry.key),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, int value, Color color) {
    final maxValue = _statusGiziData.values.isEmpty
        ? 1
        : _statusGiziData.values.reduce((a, b) => a > b ? a : b);
    final normalizedHeight = maxValue == 0 ? 0.0 : (value / maxValue) * 100;

    return Column(
      children: [
        Container(
          height: normalizedHeight + 20, // Minimum height 20
          width: 40.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF718096),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivities() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Aktivitas Terbaru',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          if (_recentActivities.isEmpty)
            const Center(
              child: Text(
                'Belum ada aktivitas',
                style: TextStyle(color: Color(0xFF718096)),
              ),
            )
          else
            Column(
              children: _recentActivities.take(5).map((activity) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: activity['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          activity['icon'],
                          color: activity['color'],
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              activity['subtitle'],
                              style: const TextStyle(
                                color: Color(0xFF718096),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM HH:mm').format(
                          (activity['time'] as Timestamp).toDate(),
                        ),
                        style: const TextStyle(
                          color: Color(0xFF718096),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildModernDrawer() {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF388E3C),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 36,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Admin GiziKu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Halo, $_namaAdmin',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.home, 'Dashboard', () {
              Navigator.pop(context);
            }, isActive: true),
            _buildDrawerItem(Icons.restaurant_menu, 'Dashboard Makanan', () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/admin_dashboard_makanan');
            }),
            _buildDrawerItem(Icons.school, 'Kelola Edukasi', () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/admin_kelola_edukasi');
            }),
            const Divider(color: Colors.white24),
            _buildDrawerItem(Icons.logout, 'Logout', () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap,
      {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
