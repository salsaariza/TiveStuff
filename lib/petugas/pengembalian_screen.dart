import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tivestuff1/widgets/back_petugas.dart';
import 'package:tivestuff1/widgets/nav_petugas.dart';
import 'package:tivestuff1/petugas/detail_pengembalian.dart';

class PengembalianScreen extends StatefulWidget {
  const PengembalianScreen({super.key});

  @override
  State<PengembalianScreen> createState() => _PengembalianPageState();
}

class _PengembalianPageState extends State<PengembalianScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),

      // ================= BODY =================
      body: SafeArea(
        child: Column(
          children: const [
            HeaderPetugas(),
            Expanded(child: _PengembalianContent()),
          ],
        ),
      ),

      // ================= NAVBAR =================
      bottomNavigationBar: NavPetugas(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) return;
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboardpetugas');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/peminjaman');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/pengembalian');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/laporan');
          }
        },
      ),
    );
  }
}

// =====================================================
// ================= CONTENT ============================
// =====================================================
class _PengembalianContent extends StatefulWidget {
  const _PengembalianContent();

  @override
  State<_PengembalianContent> createState() => _PengembalianContentState();
}

class _PengembalianContentState extends State<_PengembalianContent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            "Pengembalian",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // ================= SEARCH =================
          TextField(
            decoration: InputDecoration(
              hintText: "Cari",
              hintStyle: GoogleFonts.poppins(fontSize: 13),
              suffixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF6C6D7A),
                  width: 2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ================= LIST =================
          Expanded(
            child: ListView(
              children: const [
                _CardPengembalianNormal(),
                _CardPengembalianTerlambat(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// ================= CARD NORMAL ========================
// =====================================================
class _CardPengembalianNormal extends StatelessWidget {
  const _CardPengembalianNormal();

  @override
  Widget build(BuildContext context) {
    return _BaseCardPengembalian(
      id: 'PJ 1261',
      nama: 'Ajeng Chalista',
      kelas: 'XI TKR 1',
      tanggalPinjam: '19-01-2026',
      alat: '1 Kompresor, 1 Obeng',
      tanggalKembali: '20-01-2026',
      button: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B8F2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DetailPengembalianScreen(),
            ),
          );
        },
        child: Text(
          'Konfirmasi Pengembalian',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// =====================================================
// ================= CARD TERLAMBAT =====================
// =====================================================
class _CardPengembalianTerlambat extends StatelessWidget {
  const _CardPengembalianTerlambat();

  @override
  Widget build(BuildContext context) {
    return _BaseCardPengembalian(
      id: 'PJ 1265',
      nama: 'Intan Dwi',
      kelas: 'XI TKR 1',
      tanggalPinjam: '19-01-2026',
      alat: '1 Obeng',
      tanggalKembali: '17-01-2026',
      button: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DetailPengembalianScreen(),
            ),
          );
        },
        child: Text(
          'Konfirmasi Pengembalian Terlambat',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// =====================================================
// ================= BASE CARD ==========================
// =====================================================
class _BaseCardPengembalian extends StatelessWidget {
  final String id;
  final String nama;
  final String kelas;
  final String tanggalPinjam;
  final String alat;
  final String tanggalKembali;
  final Widget button;

  const _BaseCardPengembalian({
    required this.id,
    required this.nama,
    required this.kelas,
    required this.tanggalPinjam,
    required this.alat,
    required this.tanggalKembali,
    required this.button,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(id, style: GoogleFonts.poppins(fontSize: 12)),
              Text(tanggalPinjam, style: GoogleFonts.poppins(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            nama,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(kelas, style: GoogleFonts.poppins(fontSize: 12)),
          const SizedBox(height: 4),
          Text(alat, style: GoogleFonts.poppins(fontSize: 12)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_month, size: 16),
              const SizedBox(width: 6),
              Text(
                'Pengembalian : $tanggalKembali',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: button),
        ],
      ),
    );
  }
}
