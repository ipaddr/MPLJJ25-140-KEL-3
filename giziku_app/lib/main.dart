import 'package:flutter/material.dart';

// Import semua screen
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/forgetpassword_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/tambah_makanan_screen.dart';
import 'screens/makanan_ditambahkan_screen.dart'; // import screen baru

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Giziku App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF10b68d),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF016BB8),
          primary: const Color(0xFF016BB8),
          secondary: const Color(0xFF319FE8),
          tertiary: const Color(0xFF018175),
          surface: const Color(0xFF10b68d),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF018175),
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF018175),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
            textStyle: const TextStyle(fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.white),
        ),
      ),

      // Splash screen sebagai halaman pertama
      initialRoute: '/splash',

      // Daftar semua rute aplikasi
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/menu': (context) => const MenuScreen(),
        '/forgetpassword': (context) => const ForgetPasswordScreen(),
        '/tambahmakanan': (context) => const TambahMakananScreen(),
        '/makanan_ditambahkan':
            (context) => const MakananDitambahkanScreen(), // route baru
      },

      // Jika route tidak ditemukan
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder:
              (context) => Scaffold(
                appBar: AppBar(title: const Text('404')),
                body: const Center(child: Text('Halaman tidak ditemukan')),
              ),
        );
      },
    );
  }
}
