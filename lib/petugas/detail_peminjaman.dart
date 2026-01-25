import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tivestuff1/petugas/kartu_peminjaman.dart';
import 'package:tivestuff1/widgets/back_petugas.dart';
import 'package:tivestuff1/widgets/nav_petugas.dart';

class PeminjamanScreen extends StatefulWidget {
  const PeminjamanScreen({super.key});

  @override
  State<PeminjamanScreen> createState() =>
      _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),

      // ================= BODY =================
      body: SafeArea(
        child: Column(
          children: const [
            HeaderPetugas(),
            Expanded(child: _PengajuanContent()),
          ],
        ),
      ),

      // ================= NAVBAR =================
      bottomNavigationBar: NavPetugas(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;
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
class _PengajuanContent extends StatefulWidget {
  const _PengajuanContent();

  @override
  State<_PengajuanContent> createState() => _PengajuanContentState();
}

class _PengajuanContentState extends State<_PengajuanContent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Pengajuan Peminjaman',
            style: GoogleFonts.poppins(
              fontSize: 16,
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
                _CardDisetujui(),
                _CardDitolak(),
                _CardMenunggu(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// ================= CARD STATUS ========================
// =====================================================
class _CardDisetujui extends StatelessWidget {
  const _CardDisetujui();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailStrukScreen(),
          ),
        );
      },
      child: _BaseCard(
        id: 'PJ 1261',
        nama: 'Ajeng Chalista',
        kelas: 'XI TKR 1',
        tanggal: '19-01-2026',
        alat: '1 Kompresor, 1 Obeng',
        status: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFDFF0D8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                'Peminjaman Disetujui',
                style: GoogleFonts.poppins(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class _CardDitolak extends StatelessWidget {
  const _CardDitolak();

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      id: 'PJ 1262',
      nama: 'Richo Ferdinand',
      kelas: 'XI TKR 5',
      tanggal: '19-01-2026',
      alat: '1 Kunci Inggris, 1 Jangka Sorong',
      status: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8D7DA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cancel, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'Peminjaman Ditolak',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardMenunggu extends StatelessWidget {
  const _CardMenunggu();

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      id: 'PJ 1263',
      nama: 'Azura Selly',
      kelas: 'XII TKR 1',
      tanggal: '19-01-2026',
      alat: '1 Mikrometer',
      status: Row(
        children: [
          Expanded(
            child: OutlinedButton(onPressed: () {}, child: const Text('Tolak')),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B6E7C),
              ),
              onPressed: () {},
              child:
              Text(
              'Setuju',
              style: GoogleFonts.poppins(
                color: Colors.white,
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// ================= BASE CARD ==========================
// =====================================================
class _BaseCard extends StatelessWidget {
  final String id, nama, kelas, tanggal, alat;
  final Widget status;

  const _BaseCard({
    required this.id,
    required this.nama,
    required this.kelas,
    required this.tanggal,
    required this.alat,
    required this.status,
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
              Text(tanggal, style: GoogleFonts.poppins(fontSize: 12)),
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
          const SizedBox(height: 12),
          status,
        ],
      ),
    );
  }
}
