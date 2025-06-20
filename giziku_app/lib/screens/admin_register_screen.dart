import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRegisterScreen extends StatefulWidget {
  const AdminRegisterScreen({super.key});

  @override
  State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen>
    with TickerProviderStateMixin {
  // Controllers untuk input form
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? errorMessage;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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

  Future<void> _registerAdmin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      errorMessage = null;
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text);

      User? user = userCredential.user;

      if (user != null) {
        // Update display name
        if (namaController.text.trim().isNotEmpty) {
          await user.updateDisplayName(namaController.text.trim());
        }

        try {
          // Simpan data admin ke Firestore collection 'admins'
          await FirebaseFirestore.instance
              .collection('admins')
              .doc(user.uid)
              .set({
            'nama': namaController.text.trim(),
            'telepon': teleponController.text.trim(),
            'email': user.email,
            'role': 'admin',
            'createdAt': FieldValue.serverTimestamp(),
            'isActive': true,
          });

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Registrasi admin berhasil! Anda sekarang dapat login sebagai admin.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context);
        } catch (e) {
          if (!mounted) return;
          setState(() {
            errorMessage =
                'Registrasi akun berhasil, namun gagal menyimpan data admin. Silakan hubungi super admin.';
          });
          print('Firestore error: $e');
        }
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Password yang diberikan terlalu lemah.';
          break;
        case 'email-already-in-use':
          message = 'Email sudah terdaftar.';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid.';
          break;
        default:
          message = 'Terjadi kesalahan registrasi: ${e.message}';
      }
      setState(() {
        errorMessage = message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage =
            'Terjadi kesalahan yang tidak diketahui: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    namaController.dispose();
    emailController.dispose();
    teleponController.dispose();
    passwordController.dispose();
    super.dispose();
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
              Color(0xFF2E7D32), // Dark Green for Admin
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
                icon:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Daftar Admin',
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
                        padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
                        child: Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: isTablet ? 500 : double.infinity,
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 20),

                                // Admin Icon Container
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.admin_panel_settings,
                                    size: isTablet ? 80 : 60,
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Welcome Text
                                Text(
                                  'Daftar sebagai Admin',
                                  style: TextStyle(
                                    fontSize: isTablet ? 26 : 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        offset: const Offset(1, 1),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Buat akun admin untuk mengelola sistem',
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w400,
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
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        // Nama Field
                                        TextFormField(
                                          controller: namaController,
                                          decoration: InputDecoration(
                                            labelText: 'Nama Lengkap',
                                            hintText:
                                                'Masukkan nama lengkap admin',
                                            prefixIcon: const Icon(
                                              Icons.person_outlined,
                                              color: Color(0xFF2E7D32),
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
                                                color: Color(0xFF2E7D32),
                                                width: 2,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey.shade50,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Nama lengkap wajib diisi';
                                            }
                                            return null;
                                          },
                                        ),

                                        const SizedBox(height: 16),

                                        // Email Field
                                        TextFormField(
                                          controller: emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                            labelText: 'Email Admin',
                                            hintText: 'Masukkan email admin',
                                            prefixIcon: const Icon(
                                              Icons.email_outlined,
                                              color: Color(0xFF2E7D32),
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
                                                color: Color(0xFF2E7D32),
                                                width: 2,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey.shade50,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Email admin wajib diisi';
                                            }
                                            if (!value.contains('@')) {
                                              return 'Format email tidak valid';
                                            }
                                            return null;
                                          },
                                        ),

                                        const SizedBox(height: 16),

                                        // Telepon Field
                                        TextFormField(
                                          controller: teleponController,
                                          keyboardType: TextInputType.phone,
                                          decoration: InputDecoration(
                                            labelText: 'No Telepon',
                                            hintText: 'Masukkan nomor telepon',
                                            prefixIcon: const Icon(
                                              Icons.phone_outlined,
                                              color: Color(0xFF2E7D32),
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
                                                color: Color(0xFF2E7D32),
                                                width: 2,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey.shade50,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Nomor telepon wajib diisi';
                                            }
                                            return null;
                                          },
                                        ),

                                        const SizedBox(height: 16),

                                        // Password Field
                                        TextFormField(
                                          controller: passwordController,
                                          obscureText: _obscurePassword,
                                          decoration: InputDecoration(
                                            labelText: 'Password',
                                            hintText: 'Masukkan password',
                                            prefixIcon: const Icon(
                                              Icons.lock_outlined,
                                              color: Color(0xFF2E7D32),
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color: const Color(0xFF2E7D32),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _obscurePassword =
                                                      !_obscurePassword;
                                                });
                                              },
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
                                                color: Color(0xFF2E7D32),
                                                width: 2,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey.shade50,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Password wajib diisi';
                                            }
                                            if (value.length < 6) {
                                              return 'Password minimal 6 karakter';
                                            }
                                            return null;
                                          },
                                        ),

                                        const SizedBox(height: 24),

                                        // Error Message
                                        if (errorMessage != null) ...[
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.red.shade200),
                                            ),
                                            child: Text(
                                              errorMessage!,
                                              style: TextStyle(
                                                color: Colors.red.shade700,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                        ],

                                        // Register Button
                                        SizedBox(
                                          width: double.infinity,
                                          height: 50,
                                          child: ElevatedButton(
                                            onPressed: _isLoading
                                                ? null
                                                : _registerAdmin,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF2E7D32),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              elevation: 3,
                                            ),
                                            child: _isLoading
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
                                                    'Daftar Admin',
                                                    style: TextStyle(
                                                      fontSize:
                                                          isTablet ? 18 : 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Login Link
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: isTablet ? 16 : 14,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                      children: const [
                                        TextSpan(
                                            text: 'Sudah punya akun admin? '),
                                        TextSpan(
                                          text: 'Login sekarang!',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: screenSize.height * 0.02),
                              ],
                            ),
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
