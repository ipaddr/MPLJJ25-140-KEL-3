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

  // Data Status Gizi dari admin dashboard makanan
  int _totalCekGizi = 0;
  int _cekGiziBulanIni = 0;
  Map<String, int> _statusGiziDistribution = {};
  List<Map<String, dynamic>> _recentCekGizi = [];

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
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      // Load data Status Gizi dari riwayatCekGizi
      await _loadStatusGiziData();

      // Load aktivitas terbaru
      await _loadRecentActivities();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadStatusGiziData() async {
    try {
      // Load semua data riwayat cek gizi
      final riwayatGiziSnapshot = await FirebaseFirestore.instance
          .collection('riwayatCekGizi')
          .orderBy('tanggalPengecekan', descending: true)
          .get();

      Map<String, int> statusCount = {};
      List<Map<String, dynamic>> recentData = [];
      int bulanIniCount = 0;

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfNextMonth = (now.month == 12)
          ? DateTime(now.year + 1, 1, 1)
          : DateTime(now.year, now.month + 1, 1);

      for (var doc in riwayatGiziSnapshot.docs) {
        final data = doc.data();
        final statusGizi = data['statusGizi'] as String? ?? 'Tidak Diketahui';
        final tanggalPengecekan = data['tanggalPengecekan'] as Timestamp?;

        // Hitung distribusi status gizi
        statusCount[statusGizi] = (statusCount[statusGizi] ?? 0) + 1;

        // Hitung cek gizi bulan ini
        if (tanggalPengecekan != null) {
          final tanggal = tanggalPengecekan.toDate();
          if (tanggal.isAfter(startOfMonth) &&
              tanggal.isBefore(startOfNextMonth)) {
            bulanIniCount++;
          }
        }

        // Simpan data terbaru (maksimal 10)
        if (recentData.length < 10) {
          recentData.add({
            'nama': data['nama'] ?? 'Tidak diketahui',
            'statusGizi': statusGizi,
            'usia': data['usia'] ?? 0,
            'beratBadan': data['beratBadan'] ?? 0.0,
            'tinggiBadan': data['tinggiBadan'] ?? 0.0,
            'imt': data['imt'] ?? 0.0,
            'tanggalPengecekan': tanggalPengecekan,
          });
        }
      }

      if (mounted) {
        setState(() {
          _totalCekGizi = riwayatGiziSnapshot.docs.length;
          _cekGiziBulanIni = bulanIniCount;
          _statusGiziDistribution = statusCount;
          _recentCekGizi = recentData;
        });
      }
    } catch (e) {
      print('Error loading status gizi data: $e');
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
          'color': _getStatusGiziColor(data['statusGizi']),
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

  Color _getStatusGiziColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toLowerCase()) {
      case 'gizi baik':
      case 'normal':
        return Colors.green;
      case 'gizi kurang':
      case 'underweight':
        return Colors.orange;
      case 'gizi buruk':
      case 'severely underweight':
        return Colors.red;
      case 'gizi lebih':
      case 'overweight':
        return Colors.blue;
      case 'obesitas':
      case 'obese':
        return Colors.purple;
      default:
        return Colors.grey;
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
                            // Status Gizi Summary Cards
                            _buildStatusGiziSummary(),

                            const SizedBox(height: 24),

                            // Distribusi Status Gizi
                            _buildStatusGiziDistribution(),

                            const SizedBox(height: 24),

                            // Recent Cek Gizi
                            _buildRecentCekGizi(),

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

  Widget _buildStatusGiziSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📊 Status Gizi Anak',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Cek Gizi',
                _totalCekGizi.toString(),
                Icons.assessment,
                const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                'Cek Bulan Ini',
                _cekGiziBulanIni.toString(),
                Icons.calendar_today,
                const Color(0xFF2196F3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusGiziDistribution() {
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
            'Total Status Gizi Anak',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          if (_statusGiziDistribution.isEmpty)
            const Center(
              child: Text(
                'Belum ada data status gizi',
                style: TextStyle(color: Color(0xFF718096)),
              ),
            )
          else
            Column(
              children: _statusGiziDistribution.entries.map((entry) {
                final total =
                    _statusGiziDistribution.values.reduce((a, b) => a + b);
                final percentage = (entry.value / total) * 100;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getStatusGiziColor(entry.key),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getStatusGiziColor(entry.key),
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

  Widget _buildRecentCekGizi() {
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
            'Cek Gizi Terbaru',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          if (_recentCekGizi.isEmpty)
            const Center(
              child: Text(
                'Belum ada data cek gizi',
                style: TextStyle(color: Color(0xFF718096)),
              ),
            )
          else
            Column(
              children: _recentCekGizi.map((data) {
                final tanggal = data['tanggalPengecekan'] as Timestamp?;
                final tanggalStr = tanggal != null
                    ? DateFormat('dd/MM/yyyy').format(tanggal.toDate())
                    : 'Tidak diketahui';

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
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
                          color: _getStatusGiziColor(data['statusGizi'])
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.person,
                          color: _getStatusGiziColor(data['statusGizi']),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['nama'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${data['statusGizi']} | ${data['usia']} th | IMT: ${data['imt'].toStringAsFixed(1)}',
                              style: const TextStyle(
                                color: Color(0xFF718096),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        tanggalStr,
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
