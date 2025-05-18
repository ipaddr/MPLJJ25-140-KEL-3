import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulasi loading selama 2 detik
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        // Admin Login Logic: Check if the entered credentials match admin credentials
        if (_usernameController.text == 'admin' &&
            _passwordController.text == 'admin') {
          Navigator.pushReplacementNamed(
            context,
            '/admin_home',
          ); // Navigate to admin home
        } else {
          Navigator.pushReplacementNamed(
            context,
            '/home',
          ); // Navigate to regular user home
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10b68d),
      appBar: AppBar(
        backgroundColor: const Color(0xFF018175),
        centerTitle: true,
        elevation: 0,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          label: const Text('Kembali', style: TextStyle(color: Colors.white)),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(left: 12),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        title: const Text('Login', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child:
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Image.asset('assets/Logo.png', height: 120),
                            const SizedBox(height: 30),
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: 'Username',
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              validator:
                                  (value) =>
                                      value!.isEmpty
                                          ? 'Username wajib diisi'
                                          : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              validator:
                                  (value) =>
                                      value!.isEmpty
                                          ? 'Password wajib diisi'
                                          : null,
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed:
                                    () => Navigator.pushNamed(
                                      context,
                                      '/forgetpassword',
                                    ),
                                child: const Text(
                                  'Lupa Password?',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF018175),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 100,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed:
                                  () =>
                                      Navigator.pushNamed(context, '/register'),
                              child: const Text(
                                'Belum punya akun? Daftar sekarang!',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
