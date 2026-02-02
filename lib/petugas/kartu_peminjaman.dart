import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tivestuff1/widgets/back_petugas.dart';

class KartuPeminjamanScreen extends StatefulWidget {
  final int idPeminjaman; // wajib
  const KartuPeminjamanScreen({super.key, required this.idPeminjaman});

  @override
  State<KartuPeminjamanScreen> createState() => _KartuPeminjamanScreenState();
}

class _KartuPeminjamanScreenState extends State<KartuPeminjamanScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? peminjaman;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPeminjaman();
  }

  Future<void> fetchPeminjaman() async {
    setState(() => isLoading = true);
    try {
      final data = await supabase
          .from('peminjaman')
          .select('*, users(username), detail_peminjaman(id_alat, alat(nama_alat))')
          .eq('id_peminjaman', widget.idPeminjaman)
          .single();

      setState(() => peminjaman = data);
    } catch (e) {
      debugPrint("Error fetch kartu peminjaman: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      body: SafeArea(
        child: Column(
          children: [
            const HeaderPetugas(),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
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
                              padding: const EdgeInsets.all(16.0),
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
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Kode Peminjaman", style: GoogleFonts.poppins(fontSize: 12)),
                                      Text(
                                        "PJ-${peminjaman!['id_peminjaman']}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Peminjam", style: GoogleFonts.poppins(fontSize: 12)),
                                      Text(
                                        peminjaman!['users']?['username'] ?? '-',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Tanggal Peminjaman", style: GoogleFonts.poppins(fontSize: 12)),
                                      Text(
                                        peminjaman!['tanggal_pinjam'] ?? '-',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Tanggal Pengembalian", style: GoogleFonts.poppins(fontSize: 12)),
                                      Text(
                                        peminjaman!['tanggal_kembali'] ?? '-',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text("Daftar Alat", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 8),
                                  Text(
                                    (peminjaman!['detail_peminjaman'] as List)
                                        .map((e) => "1x ${e['alat']?['nama_alat'] ?? '-'}")
                                        .join("\n"),
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Total: ${(peminjaman!['detail_peminjaman'] as List).length} alat",
                                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
                                      ),
                                    ],
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
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C6C87),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
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
}
