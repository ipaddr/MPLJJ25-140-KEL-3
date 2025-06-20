import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TambahMakananScreen extends StatefulWidget {
  const TambahMakananScreen({super.key});

  @override
  State<TambahMakananScreen> createState() => _TambahMakananScreenState();
}

class _TambahMakananScreenState extends State<TambahMakananScreen>
    with TickerProviderStateMixin {
  final Map<int, String> deskripsiMakanan = {
    1: 'Nasi, Ayam, Telor, Sayur, Buah',
    2: 'Nasi, Ayam, Tahu, Sayur, Buah',
    3: 'Nasi, Ikan, Telor, Sayur, Buah',
    4: 'Nasi, Ikan, Tempe, Sayur, Buah',
    5: 'Nasi, Daging, Telor, Sayur, Buah',
  };

  final Map<int, String> gambarMakanan = {
    1: 'assets/images/makanan1.png',
    2: 'assets/images/makanan2.png',
    3: 'assets/images/makanan3.png',
    4: 'assets/images/makanan4.png',
    5: 'assets/images/makanan5.png',
  };

  int selectedTipe = 1;
  late TextEditingController deskripsiController;
  final TextEditingController tanggalController = TextEditingController();
  DateTime? _selectedDate;
  bool _isSaving = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    deskripsiController = TextEditingController(
      text: deskripsiMakanan[selectedTipe] ?? '',
    );

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
    deskripsiController.dispose();
    tanggalController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF018175),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        tanggalController.text = DateFormat(
          'dd MMMM yyyy',
          'id_ID',
        ).format(picked);
      });
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
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Tambah Makanan',
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
                        padding: EdgeInsets.all(isTablet ? 32 : 24),
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: isTablet ? 600 : double.infinity,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Image Container dengan animasi
                              Container(
                                width: isTablet ? 180 : 150,
                                height: isTablet ? 180 : 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    gambarMakanan[selectedTipe]!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.restaurant,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 32),

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
                                child: Column(
                                  children: [
                                    // Dropdown Tipe Paket
                                    DropdownButtonFormField<int>(
                                      value: selectedTipe,
                                      decoration: InputDecoration(
                                        labelText: 'Tipe Paket',
                                        prefixIcon: const Icon(
                                          Icons.fastfood,
                                          color: Color(0xFF018175),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF018175),
                                            width: 2,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                      ),
                                      items: deskripsiMakanan.entries.map((e) {
                                        return DropdownMenuItem(
                                          value: e.key,
                                          child: Text('Paket ${e.key}'),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() {
                                            selectedTipe = val;
                                            deskripsiController.text =
                                                deskripsiMakanan[
                                                        selectedTipe] ??
                                                    '';
                                          });
                                        }
                                      },
                                    ),

                                    const SizedBox(height: 20),

                                    // Detail Paket Field
                                    TextFormField(
                                      readOnly: true,
                                      controller: deskripsiController,
                                      maxLines: 2,
                                      decoration: InputDecoration(
                                        labelText: 'Detail Paket',
                                        prefixIcon: const Icon(
                                          Icons.description,
                                          color: Color(0xFF018175),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF018175),
                                            width: 2,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // Tanggal Field
                                    TextFormField(
                                      readOnly: true,
                                      controller: tanggalController,
                                      onTap: () => _pilihTanggal(context),
                                      decoration: InputDecoration(
                                        labelText: 'Tanggal Pengambilan',
                                        hintText: 'Pilih tanggal',
                                        prefixIcon: const Icon(
                                          Icons.calendar_today,
                                          color: Color(0xFF018175),
                                        ),
                                        suffixIcon: const Icon(
                                          Icons.arrow_drop_down,
                                          color: Color(0xFF018175),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF018175),
                                            width: 2,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                      ),
                                    ),

                                    const SizedBox(height: 32),

                                    // Save Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed:
                                            _isSaving ? null : _simpanData,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF018175),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          elevation: 3,
                                        ),
                                        child: _isSaving
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(
                                                'Simpan Makanan',
                                                style: TextStyle(
                                                  fontSize: isTablet ? 18 : 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: screenSize.height * 0.02),
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

  Future<void> _simpanData() async {
    // Validasi
    if (_selectedDate == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal harus diisi'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus login untuk menyimpan data'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (mounted) {
      setState(() {
        _isSaving = true;
      });
    }

    // Simpan ke Firestore
    try {
      await FirebaseFirestore.instance.collection('riwayatAmbilMakanan').add({
        'userId': user.uid,
        'tipeMakanan': selectedTipe,
        'deskripsi': deskripsiMakanan[selectedTipe],
        'tanggal': _selectedDate,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // Navigasi ke halaman sukses
      Navigator.pushNamed(
        context,
        '/makanan_ditambahkan',
        arguments: {
          'deskripsi': deskripsiMakanan[selectedTipe],
          'tanggal': tanggalController.text,
        },
      );
    } catch (e) {
      print('Error saving to Firestore: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan data: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
