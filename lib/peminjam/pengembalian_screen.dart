import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tivestuff1/widgets/back_peminjam.dart';
import 'package:tivestuff1/widgets/nav_peminjam.dart';

class PengembalianPeminjamScreen extends StatefulWidget {
  const PengembalianPeminjamScreen({super.key});

  @override
  State<PengembalianPeminjamScreen> createState() => _PengembalianScreenState();
}

class _PengembalianScreenState extends State<PengembalianPeminjamScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),

      /// ================= NAVBAR =================
      bottomNavigationBar: NavPeminjam(
        currentIndex: 3,
        onTap: (index) {
          if (index == 3) return;

          if (index == 0) {
            Navigator.pushReplacementNamed(
                context, '/dashboardpeminjam');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/keranjangpeminjaman');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/pengajuanpeminjam');
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Judul halaman
                    Text(
                      "Pengembalian",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// List pengembalian
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: const [
                          PengembalianCard(),
                        ],
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

/// ================= CARD PENGEMBALIAN =================
class PengembalianCard extends StatelessWidget {
  const PengembalianCard({super.key});

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
            children: [
              Text(
                'PG 2103',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9B9B9B),
                ),
              ),
              Text(
                '25-01-2026',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9B9B9B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// Nama
          Text(
            'Ajeng Chalista',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D2D2D),
            ),
          ),

          const SizedBox(height: 4),

          /// Kelas
          Text(
            'XI TKR 1',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF7B7B7B),
            ),
          ),

          const SizedBox(height: 6),

          /// Barang
          Text(
            '1 Kompresor, 1 Obeng',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF7B7B7B),
            ),
          ),

          const SizedBox(height: 12),

          /// Status
          Row(
            children: [
              Text(
                'Status :',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF7B7B7B),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 26,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  'Sudah dikembalikan',
                  style: GoogleFonts.poppins(
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
