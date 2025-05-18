import 'package:flutter/material.dart';
import 'package:giziku_app/screens/admin_bottom_navigation_bar.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 1; // Set Home as initially selected
  void _onItemTapped(int index) {
    setState(() {
 _selectedIndex = index;
    // Add navigation logic here based on the tapped index
      switch (index) {
 case 0:
        // Navigate to Dashboard Makanan
        Navigator.pushNamed(context, '/admin_dashboard_makanan');
        break;
      case 1:
        // Stay on Home screen (already here)
        break;
      case 2:
        // Navigate to Kelola Edukasi
        Navigator.pushNamed(context, '/admin_kelola_edukasi');
        break;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beranda Admin'),
 leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Open drawer
            },
          ),
        ),
      ),
      drawer: Drawer(
      ),
      body: Padding(
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
                  children: [
                    Text(
                      'Total Anak Terdaftar',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      '20', // Placeholder data
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Card(
              elevation: 2.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bantuan Didistribusikan Bulan ini',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      '15', // Placeholder data
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Card(
              elevation: 2.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Gizi Anak',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBar('Normal', 7, Colors.blue), // Placeholder data
                        _buildBar('Kurang', 5, Colors.blue), // Placeholder data
                        _buildBar('Berlebih', 3, Colors.blue), // Placeholder data
                      ],
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
  onTap: (index) {
    _onItemTapped(index);
  },
),
    );
  }

  Widget _buildBar(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          height: value * 15.0, // Simple scaling for bar height
          width: 40.0,
          color: color,
        ),
        SizedBox(height: 4.0),
        Text(value.toString()),
        SizedBox(height: 4.0),
        Text(label),
      ],
    );
  }
}