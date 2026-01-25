import 'package:flutter/material.dart';
import 'package:tivestuff1/widgets/back_peminjam.dart';
import 'package:tivestuff1/widgets/nav_peminjam.dart';
import 'package:google_fonts/google_fonts.dart';

class PengajuanScreen extends StatefulWidget {
  const PengajuanScreen({super.key});

  @override
  State<PengajuanScreen> createState() => _PengajuanScreenState();
}

class _PengajuanScreenState extends State<PengajuanScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),

      /// ================= NAVBAR =================
      bottomNavigationBar: NavPeminjam(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) return;

          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboardpeminjam');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/alatpeminjam');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/pengembalianpeminjam');
          }
        },
      ),

      /// ================= BODY =================
      body: SafeArea(
        child: Column(
          children: [
            /// ================= HEADER =================
            const BackPeminjam(),

            /// ================= CONTENT =================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Judul halaman
                    Text(
                      "Pengajuan",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    /// List pengajuan
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: const [PengajuanCard()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ================= CARD PENGAJUAN =================
class PengajuanCard extends StatelessWidget {
  const PengajuanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'PJ 1261',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9B9B9B),
                ),
              ),
              Text(
                '19-01-2026',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9B9B9B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// Nama
          const Text(
            'Ajeng Chalista',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D2D2D),
            ),
          ),

          const SizedBox(height: 4),

          /// Kelas
          const Text(
            'XI TKR 1',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF7B7B7B),
            ),
          ),

          const SizedBox(height: 6),

          /// Barang
          const Text(
            '1 Kompresor, 1 Obeng',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF7B7B7B),
            ),
          ),

          const SizedBox(height: 12),

          /// Status
          Row(
            children: [
              const Text(
                'Status :',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7B7B7B),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 26,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C6C7E),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Text(
                  'Menunggu persetujuan',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
