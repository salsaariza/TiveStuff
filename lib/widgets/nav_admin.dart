import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.grey.shade700,
      unselectedItemColor: Colors.grey.shade400,
      selectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Beranda",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.build),
          label: "Alat",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: "Pengguna",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: "Riwayat",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt),
          label: "Aktivitas",
        ),
      ],
    );
  }
}
