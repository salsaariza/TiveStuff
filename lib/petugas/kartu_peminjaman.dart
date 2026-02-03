import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tivestuff1/widgets/back_petugas.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class KartuPeminjamanScreen extends StatefulWidget {
  final int idPeminjaman;
  const KartuPeminjamanScreen({super.key, required this.idPeminjaman});

  @override
  State<KartuPeminjamanScreen> createState() => _KartuPeminjamanScreenState();
}

class _KartuPeminjamanScreenState extends State<KartuPeminjamanScreen> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? peminjaman;
  bool isLoading = true;
  String namaAlat = "-"; 

  @override
  void initState() {
    super.initState();
    fetchPeminjaman();
  }

  // ================= FETCH HEADER + NAMA ALAT =================
  Future<void> fetchPeminjaman() async {
  try {
    final data = await supabase
        .from('peminjaman')
        .select(
          '''
          id_peminjaman,
          tanggal_pinjam,
          tanggal_kembali,
          users!peminjaman_id_user_fkey(
            username
          ),
          detail_peminjaman!detail_peminjaman_id_peminjaman_fkey(
            jumlah,
            alat(nama_alat)
          )
          '''
        )
        .eq('id_peminjaman', widget.idPeminjaman)
        .maybeSingle();
    try {
      final data = await supabase
          .from('peminjaman')
          .select('''
            id_peminjaman,
            tanggal_pinjam,
            tanggal_kembali,
            id_alat,
            users!peminjaman_id_user_fkey(username),
            alat!peminjaman_id_alat_fkey(nama_alat)
          ''')
          .eq('id_peminjaman', widget.idPeminjaman)
          .maybeSingle();

      if (!mounted) return;

    debugPrint('DETAIL: ${data?['detail_peminjaman']}');

    setState(() {
      peminjaman = data;
      isLoading = false;
    });
  } catch (e) {
    debugPrint('Error fetch peminjaman: $e');
    if (!mounted) return;
    setState(() => isLoading = false);
  }
}



  // ================= REALTIME =================
  void _initRealtime() {
    supabase
        .from('peminjaman')
        .stream(primaryKey: ['id_peminjaman'])
        .eq('id_peminjaman', widget.idPeminjaman)
        .listen((data) {
          if (data.isEmpty || !mounted) return;

          setState(() {
            peminjaman = {
              ...?peminjaman,
              ...data.first,
              // ⛔ jangan timpa relasi
              'detail_peminjaman':
                  peminjaman?['detail_peminjaman'] ?? [],
            };
          });
        });
      setState(() {
        peminjaman = data;
        namaAlat = data?['alat']?['nama_alat'] ?? "-";
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetch peminjaman: $e');
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const HeaderPetugas(),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : peminjaman == null
                      ? const Center(child: Text("Data tidak ditemukan"))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Text(
                                          "TiveStuff",
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Center(
                                        child: Text(
                                          "JURUSAN OTOMOTIF\nSMKS BRANTAS KARANGKATES",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _row("Kode Peminjaman", "PJ-${peminjaman!['id_peminjaman']}"),
                                      _row("Peminjam", peminjaman!['users']?['username'] ?? "-"),
                                      _row("Tanggal Peminjaman", peminjaman!['tanggal_pinjam'] ?? "-"),
                                      _row("Tanggal Pengembalian", peminjaman!['tanggal_kembali'] ?? "-"),
                                      const SizedBox(height: 16),
                                      Text(
                                        "Daftar Alat",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        namaAlat,
                                        style: GoogleFonts.poppins(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: width,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _cetakPdf,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6C6C87),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Text(
                                    "Cetak Struk",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
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

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12)),
          Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ================= CETAK PDF =================
  Future<void> _cetakPdf() async {
    try {
      final pdf = pw.Document();

      final helvetica = pw.Font.helvetica();
      final helveticaBold = pw.Font.helveticaBold();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(16),
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                ),
                padding: const pw.EdgeInsets.all(16),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Center(
                      child: pw.Text("TiveStuff", style: pw.TextStyle(font: helveticaBold, fontSize: 16)),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Center(
                      child: pw.Text(
                        "JURUSAN OTOMOTIF\nSMKS BRANTAS KARANGKATES",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(font: helvetica, fontSize: 12),
                      ),
                    ),
                    pw.SizedBox(height: 16),
                    _pdfRow("Kode Peminjaman", "PJ-${peminjaman!['id_peminjaman']}", helvetica),
                    _pdfRow("Peminjam", peminjaman!['users']?['username'] ?? "-", helvetica),
                    _pdfRow("Tanggal Peminjaman", peminjaman!['tanggal_pinjam'] ?? "-", helvetica),
                    _pdfRow("Tanggal Pengembalian", peminjaman!['tanggal_kembali'] ?? "-", helvetica),
                    pw.SizedBox(height: 16),
                    pw.Text("Daftar Alat", style: pw.TextStyle(font: helveticaBold, fontSize: 14)),
                    pw.SizedBox(height: 8),
                    pw.Text(namaAlat, style: pw.TextStyle(font: helvetica, fontSize: 12)),
                  ],
                ),
              ),
            );
          },
        ),
      );

      // Preview PDF (tanpa langsung print)
      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    } catch (e) {
      debugPrint("Error generate PDF: $e");
    }
  }

  pw.Widget _pdfRow(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: 12)),
          pw.Text(value, style: pw.TextStyle(font: font, fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}
