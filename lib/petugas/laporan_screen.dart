import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tivestuff1/widgets/back_petugas.dart';
import 'package:tivestuff1/widgets/nav_petugas.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// PDF & PRINTING
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),

      body: SafeArea(
        child: Column(
          children: const [
            HeaderPetugas(),
            Expanded(child: _LaporanContent()),
          ],
        ),
      ),

      bottomNavigationBar: NavPetugas(
        currentIndex: 3,
        onTap: (index) {
          if (index == 3) return;
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
class _LaporanContent extends StatefulWidget {
  const _LaporanContent();

  @override
  State<_LaporanContent> createState() => _LaporanContentState();
}

class _LaporanContentState extends State<_LaporanContent> {
  final SupabaseClient supabase = Supabase.instance.client;

  bool isLoading = true;

  List peminjamanList = [];
  List pengembalianList = [];

  @override
  void initState() {
    super.initState();
    fetchLaporan();
  }

  // ================= FETCH DATA =================
  Future<void> fetchLaporan() async {
    try {
      // ================= PEMINJAMAN JOIN USERS + ALAT =================
      final peminjamanData = await supabase
          .from('peminjaman')
          .select('''
      id_peminjaman,
      tanggal_pinjam,
      tanggal_kembali,
      status_peminjaman,
      users: id_user (
        username
      ),
      alat: id_alat (
        nama_alat
      )
    ''')
          .order('tanggal_pinjam', ascending: false);

      // ================= PENGEMBALIAN JOIN PEMINJAMAN + ALAT =================
      final pengembalianData = await supabase
          .from('pengembalian')
          .select('''
      id_pengembalian,
      tanggal_kembali,
      hari_terlambat,
      kondisi_alat,
      total_denda,
      peminjaman: id_peminjaman (
        alat: id_alat (
          nama_alat
        )
      )
    ''')
          .order('tanggal_kembali', ascending: false);

      setState(() {
        peminjamanList = peminjamanData;
        pengembalianList = pengembalianData;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR FETCH LAPORAN: $e");
      setState(() => isLoading = false);
    }
  }

  // ================= GENERATE PDF =================
  Future<void> cetakLaporanPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            "LAPORAN AKTIVITAS PEMINJAMAN & PENGEMBALIAN",
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 20),

          // ================= PEMINJAMAN =================
          pw.Text(
            "Data Peminjaman",
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),

          pw.Table.fromTextArray(
            headers: ["ID", "Nama", "Alat", "Tanggal Peminjaman", "Status"],
            data: peminjamanList.map((item) {
              return [
                item['id_peminjaman'].toString(),
                item['users']?['username'] ?? "-",
                item['alat']?['nama_alat'] ?? "-",

                item['tanggal_pinjam'].toString().substring(0, 10),
                item['status_peminjaman'].toString(),
              ];
            }).toList(),
          ),

          pw.SizedBox(height: 25),

          // ================= PENGEMBALIAN =================
          pw.Text(
            "Data Pengembalian",
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),

          pw.Table.fromTextArray(
            headers: ["ID", "Alat", "Terlambat", "Kondisi", "Total Denda"],
            data: pengembalianList.map((item) {
              return [
                item['id_pengembalian'].toString(),
                item['peminjaman']?['alat']?['nama_alat'] ?? "-",
                item['hari_terlambat'].toString(),
                item['kondisi_alat'].toString(),
                item['total_denda'].toString(),
              ];
            }).toList(),
          ),
        ],
      ),
    );

    // ================= PRINT / SHARE =================
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Laporan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Laporan Aktivitas',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                Icon(
                  Icons.description_outlined,
                  size: 56,
                  color: Colors.grey.shade600,
                ),

                const SizedBox(height: 12),

                Text(
                  'Dokumen rekapan aktivitas peminjaman\n'
                  'dan pengembalian alat jurusan otomotif.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C6D7A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: isLoading ? null : cetakLaporanPDF,
                    child: Text(
                      isLoading ? "Memuat..." : "Cetak Laporan",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
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
