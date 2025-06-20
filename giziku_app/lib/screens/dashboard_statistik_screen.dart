import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StatistikBadanChart extends StatefulWidget {
  const StatistikBadanChart({super.key});

  @override
  State<StatistikBadanChart> createState() => _StatistikBadanChartState();
}

class _StatistikBadanChartState extends State<StatistikBadanChart> {
  String _namaPengguna = "Pengguna";
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadDataPengguna();
  }

  Future<void> _loadDataPengguna() async {
    if (_currentUser != null) {
      if (mounted) {
        setState(() {
          _namaPengguna =
              _currentUser!.displayName ?? _currentUser!.email ?? "Pengguna";
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
              expandedHeight: 180,
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
                    setState(() {}); // Refresh data
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
                        Color(0xFF018175),
                        Color(0xFF10b68d),
                        Color(0xFF4fd1c7),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.05),
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
                                  Icons.bar_chart,
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
                                      'Dashboard Statistik',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Halo, $_namaPengguna!',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w400,
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
                              'Analisis perkembangan tubuh anak 📊',
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
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: _isLoading
                    ? _buildLoadingState()
                    : StreamBuilder<QuerySnapshot>(
                        stream: _currentUser != null
                            ? FirebaseFirestore.instance
                                .collection('riwayatCekGizi')
                                .where('userId', isEqualTo: _currentUser!.uid)
                                .snapshots()
                            : const Stream.empty(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return _buildLoadingState();
                          }

                          if (snapshot.hasError) {
                            return _buildErrorState(snapshot.error.toString());
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return _buildEmptyState();
                          }

                          final docs = snapshot.data!.docs;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Charts Title
                              const Text(
                                'Grafik Perkembangan 📈',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Chart Cards
                              _buildChartCard(
                                title: 'IMT (Indeks Massa Tubuh)',
                                icon: Icons.calculate,
                                child: StatistikIMTChart(docs: docs),
                              ),
                              const SizedBox(height: 16),

                              _buildChartCard(
                                title: 'Perkembangan Berat Badan',
                                icon: Icons.monitor_weight,
                                child: StatistikBeratBadanChart(docs: docs),
                              ),
                              const SizedBox(height: 16),

                              _buildChartCard(
                                title: 'Perkembangan Tinggi Badan',
                                icon: Icons.height,
                                child: StatistikTinggiBadanChart(docs: docs),
                              ),
                              const SizedBox(height: 16),

                              // Summary Statistics
                              _buildStatusGiziSummary(docs),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      drawer: _buildModernDrawer(),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildChartCard(
      {required String title, required IconData icon, required Widget child}) {
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF018175).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF018175),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250, // Tinggi chart diperkecil
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusGiziSummary(List<QueryDocumentSnapshot> docs) {
    Map<String, int> statusCount = {};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['statusGizi'] as String? ?? 'Tidak Diketahui';
      statusCount[status] = (statusCount[status] ?? 0) + 1;
    }

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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF018175).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Color(0xFF018175),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Ringkasan Status Gizi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (statusCount.isEmpty)
            const Text(
              'Belum ada data status gizi',
              style: TextStyle(color: Colors.grey),
            )
          else
            ...statusCount.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF018175),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${entry.value}x',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF018175)),
            SizedBox(height: 16),
            Text(
              'Memuat data statistik...',
              style: TextStyle(color: Color(0xFF718096)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Terjadi Kesalahan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF018175).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.bar_chart,
              size: 48,
              color: Color(0xFF018175),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum Ada Data Statistik',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yuk, lakukan cek gizi terlebih dahulu untuk melihat statistik!',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/pemantauan_gizi');
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Cek Gizi Sekarang',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF018175),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
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
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  );
                },
              ),
              _buildBottomNavItem(
                icon: Icons.add_circle_outline,
                label: 'Tambah',
                onPressed: () {
                  Navigator.pushNamed(context, '/tambahmakanan');
                },
              ),
            ],
          ),
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
              Navigator.pushNamed(context, '/pemantauan_gizi');
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
            }, isActive: true),
            _buildDrawerItem(Icons.history, 'Riwayat Cek Gizi', () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/riwayat_cek_gizi');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap,
      {bool isActive = false}) {
    return Container(
      color: isActive ? Colors.white.withOpacity(0.1) : Colors.transparent,
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

// Widget untuk grafik IMT (sama seperti sebelumnya, hanya perlu disesuaikan tingginya)
class StatistikIMTChart extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;

  const StatistikIMTChart({super.key, required this.docs});

  @override
  Widget build(BuildContext context) {
    if (docs.isEmpty) {
      return const Center(
        child: Text('Tidak ada data untuk ditampilkan'),
      );
    }

    // Sort docs by date
    final sortedDocs = [...docs];
    sortedDocs.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;
      final aDate = (aData['tanggalPengecekan'] as Timestamp).toDate();
      final bDate = (bData['tanggalPengecekan'] as Timestamp).toDate();
      return aDate.compareTo(bDate);
    });

    final List<FlSpot> spots = [];
    for (int i = 0; i < sortedDocs.length; i++) {
      final data = sortedDocs[i].data() as Map<String, dynamic>;
      final imt = (data['imt'] as num?)?.toDouble() ?? 0.0;
      spots.add(FlSpot(i.toDouble(), imt));
    }

    final maxY = spots.isEmpty
        ? 30.0
        : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 5;
    final minY = spots.isEmpty
        ? 0.0
        : (spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 2)
            .clamp(0.0, double.infinity);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (spots.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < sortedDocs.length) {
                  final data =
                      sortedDocs[value.toInt()].data() as Map<String, dynamic>;
                  final date =
                      (data['tanggalPengecekan'] as Timestamp).toDate();
                  return Text(
                    DateFormat('dd/MM').format(date),
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF018175),
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF018175).withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget untuk grafik Berat Badan
class StatistikBeratBadanChart extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;

  const StatistikBeratBadanChart({super.key, required this.docs});

  @override
  Widget build(BuildContext context) {
    if (docs.isEmpty) {
      return const Center(
        child: Text('Tidak ada data untuk ditampilkan'),
      );
    }

    final sortedDocs = [...docs];
    sortedDocs.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;
      final aDate = (aData['tanggalPengecekan'] as Timestamp).toDate();
      final bDate = (bData['tanggalPengecekan'] as Timestamp).toDate();
      return aDate.compareTo(bDate);
    });

    final List<FlSpot> spots = [];
    for (int i = 0; i < sortedDocs.length; i++) {
      final data = sortedDocs[i].data() as Map<String, dynamic>;
      final berat = (data['beratBadan'] as num?)?.toDouble() ?? 0.0;
      spots.add(FlSpot(i.toDouble(), berat));
    }

    final maxY = spots.isEmpty
        ? 50.0
        : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 5;
    final minY = spots.isEmpty
        ? 0.0
        : (spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 2)
            .clamp(0.0, double.infinity);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (spots.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < sortedDocs.length) {
                  final data =
                      sortedDocs[value.toInt()].data() as Map<String, dynamic>;
                  final date =
                      (data['tanggalPengecekan'] as Timestamp).toDate();
                  return Text(
                    DateFormat('dd/MM').format(date),
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()} kg',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget untuk grafik Tinggi Badan
class StatistikTinggiBadanChart extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;

  const StatistikTinggiBadanChart({super.key, required this.docs});

  @override
  Widget build(BuildContext context) {
    if (docs.isEmpty) {
      return const Center(
        child: Text('Tidak ada data untuk ditampilkan'),
      );
    }

    final sortedDocs = [...docs];
    sortedDocs.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;
      final aDate = (aData['tanggalPengecekan'] as Timestamp).toDate();
      final bDate = (bData['tanggalPengecekan'] as Timestamp).toDate();
      return aDate.compareTo(bDate);
    });

    final List<FlSpot> spots = [];
    for (int i = 0; i < sortedDocs.length; i++) {
      final data = sortedDocs[i].data() as Map<String, dynamic>;
      final tinggi = (data['tinggiBadan'] as num?)?.toDouble() ?? 0.0;
      spots.add(FlSpot(i.toDouble(), tinggi));
    }

    final maxY = spots.isEmpty
        ? 200.0
        : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 10;
    final minY = spots.isEmpty
        ? 0.0
        : (spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 5)
            .clamp(0.0, double.infinity);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (spots.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < sortedDocs.length) {
                  final data =
                      sortedDocs[value.toInt()].data() as Map<String, dynamic>;
                  final date =
                      (data['tanggalPengecekan'] as Timestamp).toDate();
                  return Text(
                    DateFormat('dd/MM').format(date),
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()} cm',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}
