import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tivestuff1/widgets/back_petugas.dart';
import 'package:tivestuff1/widgets/nav_petugas.dart';

class DetailPengembalianScreen extends StatefulWidget {
  const DetailPengembalianScreen({super.key});

  @override
  State<DetailPengembalianScreen> createState() =>
      _DetailPengembalianPageState();
}

class _DetailPengembalianPageState extends State<DetailPengembalianScreen> {
  String? kondisiKompresor;
  String? kondisiObeng;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),

      // ================= BODY =================
      body: SafeArea(
        child: Column(
          children: const [
            HeaderPetugas(),
            Expanded(child: _DetailContent()),
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
class _DetailContent extends StatefulWidget {
  const _DetailContent();

  @override
  State<_DetailContent> createState() => _DetailContentState();
}

class _DetailContentState extends State<_DetailContent> {
  String? kondisi1;
  String? kondisi2;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            'Detail Pengembalian',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // ================= DETAIL CARD =================
          _CardDetail(),

          const SizedBox(height: 16),
          Text(
            'Daftar Alat',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView(
              children: [
                _CardAlat(
                  namaAlat: 'Kompresor 1',
                  value: kondisi1,
                  onChanged: (value) {
                    setState(() => kondisi1 = value);
                  },
                ),
                _CardAlat(
                  namaAlat: 'Obeng 1',
                  value: kondisi2,
                  onChanged: (value) {
                    setState(() => kondisi2 = value);
                  },
                ),
              ],
            ),
          ),

          // ================= BUTTON =================
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B8F2E),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  'Konfirmasi Pengembalian',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  )
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
// ================= CARD DETAIL ========================
// =====================================================
class _CardDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailText('Nama', 'Ajeng Chalista'),
          _detailText('Email', 'ajengrenta@gmail.com'),
          _detailText('Kelas', 'XI TKR 1'),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_month, size: 16),
              const SizedBox(width: 6),
              Text(
                'Rencana Pengembalian : 20-01-2026',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tanggal Pinjam : 19-01-2026',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
          Text(
            'Tanggal Pengembalian : 20-01-2026',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _detailText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '$label : $value',
        style: GoogleFonts.poppins(fontSize: 12),
      ),
    );
  }
}

// =====================================================
// ================= CARD ALAT ==========================
// =====================================================
class _CardAlat extends StatelessWidget {
  final String namaAlat;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _CardAlat({
    required this.namaAlat,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                namaAlat,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Kondisi Alat :',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: value,
            items: const [
              DropdownMenuItem(value: 'Baik', child: Text('Baik')),
              DropdownMenuItem(value: 'Rusak', child: Text('Rusak')),
            ],
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
