import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/forgetpassword_screen.dart';
import 'screens/splash_screen.dart'; // import splash screen
import 'screens/admin_home_screen.dart'; // Import the admin home screen
import 'screens/admin_dashboard_makanan_screen.dart'; // Import the admin dashboard makanan screen
import 'screens/admin_kelola_edukasi_screen.dart'; // Import the admin kelola edukasi screen

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
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF018175), // warna tombol
            foregroundColor: Colors.white, // warna teks pada tombol
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
            textStyle: const TextStyle(fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white, // warna teks untuk TextButton
          ),
        ),
      ),
      initialRoute: '/splash',  // jadikan splash screen sebagai route awal
      routes: {
        '/splash': (context) => const SplashScreen(), // route splash screen
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/forgetpassword': (context) => const ForgetPasswordScreen(),
        '/admin_home': (context) => AdminHomeScreen(), // Add the admin home route
        '/admin_dashboard_makanan': (context) => AdminDashboardMakananScreen(), // Add the admin dashboard makanan route
        '/admin_kelola_edukasi': (context) => AdminKelolaEdukasiScreen(), // Add the admin kelola edukasi route
      },
    );
  }
}
