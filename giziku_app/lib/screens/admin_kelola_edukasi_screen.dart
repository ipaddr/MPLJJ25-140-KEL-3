import 'package:flutter/material.dart';
import 'package:giziku_app/screens/admin_bottom_navigation_bar.dart';


class AdminKelolaEdukasiScreen extends StatefulWidget {
  const AdminKelolaEdukasiScreen({super.key});

  @override
  _AdminKelolaEdukasiScreenState createState() =>
      _AdminKelolaEdukasiScreenState();
}

class _AdminKelolaEdukasiScreenState extends State<AdminKelolaEdukasiScreen> {
  int _selectedIndex = 2; // Set Kelola Edukasi as initially selected

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/admin_dashboard_makanan');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/admin_home');
        break;
      case 2:
        // Stay on Kelola Edukasi screen
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Edukasi'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: const Drawer(
        // Drawer content goes here
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement Tambah Konten Edukasi action
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Konten Edukasi'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Daftar Konten Edukasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),

            // Table Header + Rows
            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                  ),
                  children: [
                    _buildTableHeaderCell('Judul'),
                    _buildTableHeaderCell('Jenis'),
                    _buildTableHeaderCell('Dilihat'),
                    _buildTableHeaderCell('Aksi'),
                  ],
                ),
                _buildEdukasiTableRow('Pentingnya Gizi Balita', 'Artikel', 150),
                _buildEdukasiTableRow('Resep Makanan Sehat', 'Video', 220),
                _buildEdukasiTableRow('Tips Merawat Anak', 'Artikel', 180),
                _buildEdukasiTableRow('Makanan Bergizi', 'Artikel', 150),
                _buildEdukasiTableRow('Pentingnya Vitamin', 'Video', 220),
                _buildEdukasiTableRow('Tips Mencegah Stunting', 'Artikel', 180),
              ],
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

  Widget _buildTableHeaderCell(String label) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  TableRow _buildEdukasiTableRow(String judul, String jenis, int dilihat) {
    return TableRow(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
        ),
      ),
      children: [
        _buildTableCell(judul),
        _buildTableCell(jenis),
        _buildTableCell(dilihat.toString()),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    // TODO: Implement Edit action
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // TODO: Implement Delete action
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableCell(String content) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.grey.shade300, width: 0.5),
            ),
          ),
          child: Text(content),
        ),
      ),
    );
  }
}
