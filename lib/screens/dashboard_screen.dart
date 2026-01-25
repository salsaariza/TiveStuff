import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tivestuff1/widgets/nav_admin.dart';
import 'package:tivestuff1/widgets/header.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // RESPONSIVE FONT
  double rf(BuildContext context, double base) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1024) return base + 4;
    if (width >= 600) return base + 2;
    return base;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),

      // ================= NAVBAR =================
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;

          switch (index) {
            case 1:
              Navigator.pushReplacementNamed(context, '/alat');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/pengguna');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/riwayat');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/aktivitas');
            case 5:
              Navigator.pushReplacementNamed(context, '/profil');
              break;
          }
        },
      ),

      // ================= BODY =================
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardHeader(),
              const SizedBox(height: 20),
              _dashboardTitle(context),
              const SizedBox(height: 12),
              _statsGrid(context),
              const SizedBox(height: 24),
              _riwayatTitle(context),
              const SizedBox(height: 12),
              _riwayatList(context),
            ],
          ),
        ),
      ),
    );
  }

  // ================= TITLE =================
  Widget _dashboardTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        "Dashboard",
        style: GoogleFonts.poppins(
          fontSize: rf(context, 18),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ================= GRID =================
  Widget _statsGrid(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 600 ? 4 : 2;
    final aspectRatio = width < 360 ? 1.2 : 1.4;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: aspectRatio,
        children: [
          _statCard(context, "15", "PENGGUNA AKTIF"),
          _statCard(context, "10", "JUMLAH ALAT"),
          _statCard(context, "15", "ALAT TERSEDIA"),
          _statCard(context, "15", "ALAT DIPINJAM"),
        ],
      ),
    );
  }

  // ================= CARD =================
  Widget _statCard(BuildContext context, String value, String title) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade400,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: rf(context, 20),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: rf(context, 14),
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ================= RIWAYAT =================
  Widget _riwayatTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        "Daftar Riwayat Peminjaman",
        style: GoogleFonts.poppins(
          fontSize: rf(context, 16),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _riwayatList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _riwayatItem(context, "Peminjaman 03"),
          _riwayatItem(context, "Peminjaman 02"),
          _riwayatItem(context, "Peminjaman 01"),
        ],
      ),
    );
  }

  Widget _riwayatItem(BuildContext context, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: rf(context, 14),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "07.15 | 15 Oktober 2025",
                  style: GoogleFonts.poppins(
                    fontSize: rf(context, 12),
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
