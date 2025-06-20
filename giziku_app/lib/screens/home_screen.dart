import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giziku_app/utils/gizi_helpers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  String _namaPengguna = "Pengguna";
  Map<String, dynamic>? _dataGiziTerakhir;
  bool _isLoadingGizi = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDataPengguna();
    _loadDataGiziTerakhir();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _loadDataGiziTerakhir();
    }
  }

  Future<void> _loadDataPengguna() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (mounted) {
        setState(() {
          _namaPengguna = user.displayName ?? user.email ?? "Pengguna";
        });
      }
    }
  }

  Future<void> _loadDataGiziTerakhir() async {
    if (!mounted) return;
    setState(() {
      _isLoadingGizi = true;
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoadingGizi = false);
      return;
    }

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('riwayatCekGizi')
          .where('userId', isEqualTo: user.uid)
          .orderBy('tanggalPengecekan', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _dataGiziTerakhir = data;
            _isLoadingGizi = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _dataGiziTerakhir = null;
            _isLoadingGizi = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dataGiziTerakhir = null;
          _isLoadingGizi = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isLargeScreen = screenHeight > 700;

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
            // Custom App Bar with gradient
            SliverAppBar(
              expandedHeight: isLargeScreen ? 200 : 160,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF018175),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
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
                                  Icons.waving_hand,
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
                                      'Selamat Datang!',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      _namaPengguna,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
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
                              'Pantau status gizimu untuk hidup lebih sehat 💪',
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
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Gizi Card dengan design yang lebih menarik
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Colors.grey[50]!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: _isLoadingGizi
                            ? Column(
                                children: const [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF018175)),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Memuat data gizi...',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              )
                            : _dataGiziTerakhir != null
                                ? _buildStatusGiziContent()
                                : _buildEmptyGiziContent(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions dengan design modern
                    const Text(
                      'Aksi Cepat',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildModernQuickAction(
                            context,
                            icon: Icons.monitor_heart,
                            label: 'Cek Gizi',
                            subtitle: 'Periksa status gizi',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, '/pemantauan_gizi')
                                  .then((_) {
                                _loadDataGiziTerakhir();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildModernQuickAction(
                            context,
                            icon: Icons.history,
                            label: 'Riwayat',
                            subtitle: 'Lihat riwayat gizi',
                            gradient: const LinearGradient(
                              colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                            ),
                            onTap: () => Navigator.pushNamed(
                                context, '/riwayat_cek_gizi'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildModernQuickAction(
                            context,
                            icon: Icons.bar_chart,
                            label: 'Statistik',
                            subtitle: 'Dashboard data',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                            ),
                            onTap: () =>
                                Navigator.pushNamed(context, '/dashboard'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildModernQuickAction(
                            context,
                            icon: Icons.restaurant_menu,
                            label: 'Makanan',
                            subtitle: 'Riwayat makanan',
                            gradient: const LinearGradient(
                              colors: [Color(0xFFa8edea), Color(0xFFfed6e3)],
                            ),
                            onTap: () => Navigator.pushNamed(
                                context, '/riwayat_ambil_makanan'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Rekomendasi Makanan dengan design yang lebih menarik
                    const Text(
                      'Rekomendasi Hari Ini 🍽️',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4facfe),
                                    Color(0xFF00f2fe)
                                  ],
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  'assets/images/makanan1.jpg',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.fastfood,
                                          size: 40, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Menu Sehat Hari Ini',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF018175),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Nasi, sayur bayam, dan tahu goreng – bergizi dan seimbang untuk kebutuhan harian anak.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Edukasi Gizi dengan design yang lebih menarik
                    const Text(
                      'Edukasi Gizi 📚',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/edukasi'),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF667eea),
                              Color(0xFF764ba2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Icon(
                                  Icons.play_circle_fill,
                                  size: 32,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pentingnya Makanan Bergizi',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Pelajari tips nutrisi untuk anak',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white70,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke layar chatbot
          Navigator.pushNamed(context, '/chatbot');
        },
        tooltip: 'Chat dengan Bot', // Opsional: tooltip untuk aksesibilitas
        child: const Icon(Icons.chat), // Ikon untuk tombol
      ),
      drawer: _buildModernDrawer(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(
                  icon: Icons.arrow_back_ios_new_rounded,
                  label: 'Back',
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                ),
                _buildBottomNavItem(
                  icon: Icons.home,
                  label: 'Home',
                  isActive: true,
                  onPressed: () {},
                ),
                _buildBottomNavItem(
                  icon: Icons.add_circle_outline,
                  label: 'Tambah',
                  onPressed: () {
                    Navigator.of(context).pushNamed('/tambahmakanan');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusGiziContent() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    getColorForStatus(_dataGiziTerakhir!['statusGizi'], context)
                        .withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                getEmoticonForStatus(_dataGiziTerakhir!['statusGizi']),
                size: 40,
                color: getColorForStatus(
                    _dataGiziTerakhir!['statusGizi'], context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status Gizi Terakhir',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _dataGiziTerakhir!['statusGizi'] ?? 'Belum Ada Data',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: getColorForStatus(
                          _dataGiziTerakhir!['statusGizi'], context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'IMT: ${_dataGiziTerakhir!['imt']?.toStringAsFixed(1) ?? '-'} kg/m²',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.person, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Nama: ${_dataGiziTerakhir!['nama'] ?? '-'}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyGiziContent() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF018175).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.health_and_safety,
            size: 48,
            color: Color(0xFF018175),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Belum Ada Data Gizi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF018175),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Yuk, mulai cek status gizi untuk memantau kesehatan!',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, '/pemantauan_gizi').then((_) {
              _loadDataGiziTerakhir();
            });
          },
          icon: const Icon(Icons.monitor_heart, color: Colors.white),
          label: const Text('Cek Gizi Sekarang',
              style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF018175),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF018175) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : const Color(0xFF018175),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.white : const Color(0xFF018175),
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
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
              Color(0xFF016BB8),
              Color(0xFF018175),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 36,
                      color: Color(0xFF018175),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Giziku App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Halo, $_namaPengguna',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.person_outline, 'Profil', () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            }),
            const Divider(color: Colors.white24),
            _buildDrawerItem(Icons.monitor_heart, 'Pemantauan Gizi', () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/pemantauan_gizi').then((_) {
                _loadDataGiziTerakhir();
              });
            }),
            _buildDrawerItem(Icons.volunteer_activism, 'Riwayat Ambil Makanan',
                () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/riwayat_ambil_makanan');
            }),
            _buildDrawerItem(Icons.school, 'Edukasi', () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/edukasi');
            }),
            _buildDrawerItem(Icons.bar_chart, 'Dashboard Statistik', () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/dashboard');
            }),
            _buildDrawerItem(Icons.history, 'Riwayat Cek Gizi', () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/riwayat_cek_gizi');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: onTap,
    );
  }
}
