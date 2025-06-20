import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giziku_app/utils/gizi_helpers.dart';

class PemantauanGiziScreen extends StatefulWidget {
  const PemantauanGiziScreen({super.key});

  @override
  State<PemantauanGiziScreen> createState() => _PemantauanGiziScreenState();
}

class _PemantauanGiziScreenState extends State<PemantauanGiziScreen>
    with TickerProviderStateMixin {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController usiaController = TextEditingController();
  final TextEditingController beratController = TextEditingController();
  final TextEditingController tinggiController = TextEditingController();

  bool _isLoading = false;
  bool _showResult = false;
  double? _calculatedIMT;

  String statusGizi = 'Normal';
  String rekomendasi = 'Makanan 4 Sehat 5 Sempurna';
  String _namaPengguna = "Pengguna";

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadDataPengguna();

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
  }

  @override
  void dispose() {
    namaController.dispose();
    usiaController.dispose();
    beratController.dispose();
    tinggiController.dispose();
    _animationController.dispose();
    super.dispose();
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

  Future<void> hitungStatusGizi() async {
    if (_isLoading) return;

    if (namaController.text.isEmpty ||
        usiaController.text.isEmpty ||
        beratController.text.isEmpty ||
        tinggiController.text.isEmpty) {
      _showSnackBar('Semua field harus diisi.', Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
      _showResult = false;
    });

    try {
      double berat = double.tryParse(beratController.text) ?? 0;
      double tinggiCm = double.tryParse(tinggiController.text) ?? 0;
      int usia = int.tryParse(usiaController.text) ?? 0;

      if (berat <= 0) {
        _showSnackBar('Berat badan harus lebih dari 0 kg.', Colors.red);
        setState(() => _isLoading = false);
        return;
      }

      if (tinggiCm <= 0) {
        _showSnackBar('Tinggi badan harus lebih dari 0 cm.', Colors.red);
        setState(() => _isLoading = false);
        return;
      }

      if (usia <= 0) {
        _showSnackBar('Usia harus lebih dari 0 tahun.', Colors.red);
        setState(() => _isLoading = false);
        return;
      }

      double tinggiM = tinggiCm / 100;
      double imt = berat / (tinggiM * tinggiM);
      _calculatedIMT = imt;

      String newStatusGizi;
      String newRekomendasi;

      if (imt < 18.5) {
        newStatusGizi = 'Kurang';
        newRekomendasi = '''
📈 Rekomendasi untuk Gizi Kurang:

🥛 Tingkatkan Asupan Kalori:
• Susu full cream, keju, yogurt
• Alpukat, kacang-kacangan, biji-bijian
• Minyak zaitun untuk memasak

🍗 Protein Berkualitas:
• Daging sapi, ayam, ikan
• Telur (2-3 butir per hari)
• Tahu, tempe, kacang merah

🍌 Camilan Sehat:
• Pisang dengan selai kacang
• Smoothie buah dengan susu
• Roti gandum dengan keju

⚡ Tips Tambahan:
• Makan 5-6 kali sehari porsi kecil
• Minum jus buah antar waktu makan
• Konsultasi dengan ahli gizi
        ''';
      } else if (imt >= 18.5 && imt <= 24.9) {
        newStatusGizi = 'Normal';
        newRekomendasi = '''
✅ Rekomendasi untuk Gizi Normal:

🍽️ Pertahankan Pola Seimbang:
• Nasi/roti gandum sebagai karbohidrat
• Lauk protein (ikan, ayam, telur)
• Sayuran hijau dan berwarna

🥗 Menu Harian Seimbang:
• Sarapan: Oatmeal + buah + susu
• Makan siang: Nasi + sayur + protein
• Makan malam: Porsi sedang seimbang

🍎 Camilan Sehat:
• Buah-buahan segar
• Yogurt tanpa gula berlebih
• Kacang-kacangan alami

💧 Hidrasi & Aktivitas:
• Minum air 8 gelas per hari
• Olahraga ringan 30 menit/hari
• Tidur cukup 7-8 jam
        ''';
      } else if (imt >= 25 && imt <= 29.9) {
        newStatusGizi = 'Berlebih';
        newRekomendasi = '''
⚖️ Rekomendasi untuk Gizi Berlebih:

🥬 Kurangi Kalori Secara Sehat:
• Perbanyak sayuran hijau dan serat
• Protein rendah lemak (ikan, ayam tanpa kulit)
• Karbohidrat kompleks (nasi merah, oat)

🚫 Batasi Konsumsi:
• Makanan tinggi gula dan lemak jenuh
• Minuman manis dan bersoda
• Gorengan dan makanan olahan

🍽️ Pola Makan Teratur:
• Makan 3x sehari porsi terkontrol
• Camilan buah di antara jam makan
• Hindari makan malam terlalu larut

🏃 Tingkatkan Aktivitas:
• Olahraga aerobik 45 menit, 4x seminggu
• Jalan kaki setelah makan
• Naik tangga daripada lift
        ''';
      } else {
        newStatusGizi = 'Obesitas';
        newRekomendasi = '''
🚨 Rekomendasi untuk Obesitas:

⚠️ Perlu Perhatian Khusus:
• Konsultasi segera dengan dokter/ahli gizi
• Program penurunan berat badan terstruktur
• Pemantauan kesehatan rutin

🥗 Diet Rendah Kalori Ketat:
• Sayuran hijau sebagai makanan utama
• Protein tanpa lemak (ikan putih, ayam rebus)
• Hindari karbohidrat sederhana

🚫 Pantangan Mutlak:
• Fast food dan makanan olahan
• Minuman manis dan beralkohol
• Makanan tinggi lemak trans

🏋️ Program Olahraga Intensif:
• Cardio 60 menit, 5x seminggu
• Latihan kekuatan 2x seminggu
• Aktivitas harian yang aktif

💊 Dukungan Medis:
• Cek kesehatan berkala
• Monitoring tekanan darah & gula darah
• Pertimbangkan konsultasi psikolog
        ''';
      }

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnackBar('Anda harus login untuk menyimpan data.', Colors.red);
        setState(() => _isLoading = false);
        return;
      }

      final dataToSave = {
        'userId': user.uid,
        'nama': namaController.text,
        'usia': int.tryParse(usiaController.text),
        'beratBadan': berat,
        'tinggiBadan': tinggiCm,
        'imt': imt.isNaN || imt.isInfinite
            ? null
            : double.parse(imt.toStringAsFixed(1)),
        'statusGizi': newStatusGizi,
        'rekomendasi': newRekomendasi,
        'tanggalPengecekan': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('riwayatCekGizi')
          .add(dataToSave);

      if (mounted) {
        setState(() {
          statusGizi = newStatusGizi;
          rekomendasi = newRekomendasi;
          _showResult = true;
        });

        _animationController.forward();
        _showSnackBar(
            'Status gizi berhasil dihitung dan disimpan.', Colors.green);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Terjadi kesalahan: ${e.toString()}', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _resetForm() {
    setState(() {
      _showResult = false;
      _calculatedIMT = null;
    });
    _animationController.reset();
    namaController.clear();
    usiaController.clear();
    beratController.clear();
    tinggiController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10b68d),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF018175),
        title: const Text(
          'Pemantauan Gizi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          if (_showResult)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _resetForm,
              tooltip: 'Reset Form',
            ),
        ],
      ),
      drawer: _buildModernDrawer(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Header Section with gradient
            Container(
              width: double.infinity,
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
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.health_and_safety,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Cek Status Gizi Anak',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Halo $_namaPengguna, mari pantau kesehatan si kecil',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Form Section
            Container(
              margin: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data Anak',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF018175),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildModernTextField(
                      controller: namaController,
                      label: 'Nama Lengkap Anak',
                      icon: Icons.person_outline,
                    ),

                    _buildModernTextField(
                      controller: usiaController,
                      label: 'Usia (Tahun)',
                      icon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _buildModernTextField(
                            controller: beratController,
                            label: 'Berat (Kg)',
                            icon: Icons.monitor_weight_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildModernTextField(
                            controller: tinggiController,
                            label: 'Tinggi (Cm)',
                            icon: Icons.height_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Calculate Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : hitungStatusGizi,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF018175),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calculate, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Hitung & Simpan Status Gizi',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Result Section
            if (_showResult) ...[
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          getColorForStatus(statusGizi, context)
                              .withOpacity(0.1),
                          getColorForStatus(statusGizi, context)
                              .withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: getColorForStatus(statusGizi, context)
                            .withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          // Status Result
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: getColorForStatus(statusGizi, context)
                                      .withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Hasil Status Gizi',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF018175),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Status Icon and Text
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color:
                                        getColorForStatus(statusGizi, context)
                                            .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Icon(
                                    getEmoticonForStatus(statusGizi),
                                    size: 64,
                                    color:
                                        getColorForStatus(statusGizi, context),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                Text(
                                  statusGizi,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        getColorForStatus(statusGizi, context),
                                  ),
                                ),

                                if (_calculatedIMT != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'IMT: ${_calculatedIMT!.toStringAsFixed(1)} kg/m²',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Status Legend
                          _buildStatusLegend(),

                          const SizedBox(height: 20),

                          // Recommendation
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.lightbulb_outline,
                                      color: Color(0xFF018175),
                                      size: 24,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Rekomendasi Makanan',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF018175),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  rekomendasi,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.5,
                                    color: Colors.black87,
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
              ),
              const SizedBox(height: 20),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF018175)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF018175), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildStatusLegend() {
    final statusItems = [
      {'text': 'Kurang', 'color': const Color.fromARGB(255, 235, 220, 52)},
      {'text': 'Normal', 'color': const Color.fromARGB(255, 76, 175, 80)},
      {'text': 'Berlebih', 'color': const Color.fromARGB(255, 255, 82, 82)},
      {'text': 'Obesitas', 'color': const Color.fromARGB(255, 180, 50, 50)},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kategori Status Gizi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF018175),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: statusItems
                .map((item) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (item['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (item['color'] as Color).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: item['color'] as Color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item['text'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
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
                  Navigator.pushReplacementNamed(context, '/home');
                },
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
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isCentral = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isCentral ? const Color(0xFF018175) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isCentral ? Colors.white : const Color(0xFF018175),
              size: isCentral ? 28 : 24,
            ),
            if (!isCentral) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF018175),
                ),
              ),
            ],
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
              decoration: const BoxDecoration(color: Colors.transparent),
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
            _buildDrawerItem(
              Icons.monitor_heart,
              'Pemantauan Gizi',
              () => Navigator.pop(context),
              isActive: true,
            ),
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
