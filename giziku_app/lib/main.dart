import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
//User screens
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/EdukasiScreen.dart';
import 'screens/forgetpassword_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/tambah_makanan_screen.dart';
import 'screens/makanan_ditambahkan_screen.dart';
import 'screens/pemantauan_gizi_screen.dart';
import 'screens/riwayat_ambil_makanan_screen.dart';
import 'screens/riwayat_cek_gizi_screen.dart';
import 'screens/dashboard_statistik_screen.dart';

// Admin screens
import 'screens/admin_home_screen.dart';
import 'screens/admin_dashboard_makanan_screen.dart';
import 'screens/admin_kelola_edukasi_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(
    'id_ID',
    null,
  ); // Penting untuk tanggal Bahasa Indonesia
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
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/forgetpassword': (context) => const ForgetPasswordScreen(),
        '/pemantauan_gizi': (context) => const PemantauanGiziScreen(),
        '/tambahmakanan': (context) => const TambahMakananScreen(),
        '/makanan_ditambahkan': (context) => const MakananDitambahkanScreen(),
        '/riwayat_ambil_makanan':
            (context) => const RiwayatAmbilMakananScreen(),
        '/riwayat_cek_gizi': (context) => const RiwayatCekGiziScreen(),
        '/edukasi': (context) => const EdukasiScreen(),
        '/dashboard': (context) => DashboardStatistikScreen(),

        // Admin routes
        '/admin_home': (context) => const AdminHomeScreen(),
        '/admin_dashboard_makanan':
            (context) => const AdminDashboardMakananScreen(),
        '/admin_kelola_edukasi': (context) => const AdminKelolaEdukasiScreen(),
      },
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
