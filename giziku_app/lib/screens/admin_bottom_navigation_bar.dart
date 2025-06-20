import 'package:flutter/material.dart';

class AdminBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AdminBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            activeIcon: Icon(Icons.restaurant_menu),
            label: 'Makanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            activeIcon: Icon(Icons.school),
            label: 'Edukasi',
          ),
        ],
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,

        // 🎨 Selaraskan dengan tema admin (hijau)
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2E7D32), // Hijau admin
        unselectedItemColor: const Color(0xFF9E9E9E), // Abu-abu

        // Style untuk selected item
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.normal,
        ),

        // Icon size
        iconSize: 24,

        // Enable splash
        enableFeedback: true,

        onTap: onTap,
      ),
    );
  }
}
