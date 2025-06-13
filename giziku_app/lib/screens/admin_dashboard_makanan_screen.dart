import 'package:flutter/material.dart';
import 'package:giziku_app/screens/admin_bottom_navigation_bar.dart';

class AdminDashboardMakananScreen extends StatefulWidget {
  const AdminDashboardMakananScreen({super.key});

  @override
  State<AdminDashboardMakananScreen> createState() =>
      _AdminDashboardMakananScreenState();
}

class _AdminDashboardMakananScreenState
    extends State<AdminDashboardMakananScreen> {
  int _selectedIndex = 0; // Set Dashboard Makanan as initially selected

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        // Stay on Dashboard Makanan screen
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/admin_home');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/admin_kelola_edukasi');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Makanan'),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer(); // Open drawer
                },
              ),
        ),
      ),
      drawer: const Drawer(
        // Your Drawer content here
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Stock Total Makanan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      '150', // Placeholder data
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Card(
              elevation: 2.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Jumlah Paket Tersedia',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      '50', // Placeholder data
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Tabel Makanan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Card(
              elevation: 2.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Table Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Stock',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Foto',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Tipe Paket',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Detail',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    // Table Rows (Placeholder Data)
                    _buildMakananRow(
                      '20',
                      'image1.png',
                      'Paket A',
                      'Details A',
                    ),
                    _buildMakananRow(
                      '30',
                      'image2.png',
                      'Paket B',
                      'Details B',
                    ),
                    _buildMakananRow(
                      '50',
                      'image3.png',
                      'Paket C',
                      'Details C',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AdminBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildMakananRow(
    String stock,
    String foto,
    String tipePaket,
    String detail,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 1, child: Text(stock)),
          Expanded(
            flex: 1,
            child: Text(foto),
          ), // Replace with Image.asset or similar
          Expanded(flex: 2, child: Text(tipePaket)),
          Expanded(flex: 1, child: Text(detail)),
        ],
      ),
    );
  }
}
