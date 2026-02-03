import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tivestuff1/widgets/back_petugas.dart';

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

  @override
  void initState() {
    super.initState();
    fetchPeminjaman();
    _initRealtime();
  }

  // ================= FETCH DATA =================
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
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // ===== NULL SAFE LIST =====
    final List detailList =
        (peminjaman?['detail_peminjaman'] as List?) ?? [];

    // ===== TOTAL JUMLAH =====
    final int totalAlat = detailList.fold<int>(
      0,
      (sum, e) => sum + (e['jumlah'] as int? ?? 1),
    );

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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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

                                      _row(
                                        "Kode Peminjaman",
                                        "PJ-${peminjaman!['id_peminjaman']}",
                                      ),
                                      _row(
                                        "Peminjam",
                                        peminjaman!['users']?['username'] ?? "-",
                                      ),
                                      _row(
                                        "Tanggal Peminjaman",
                                        peminjaman!['tanggal_pinjam'] ?? "-",
                                      ),
                                      _row(
                                        "Tanggal Pengembalian",
                                        peminjaman!['tanggal_kembali'] ?? "-",
                                      ),

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
                                        detailList.isEmpty
                                            ? "-"
                                            : detailList
                                                .map((e) =>
                                                    "${e['jumlah']}x ${e['alat']?['nama_alat'] ?? '-'}")
                                                .join("\n"),
                                        style: GoogleFonts.poppins(fontSize: 12),
                                      ),

                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Total: $totalAlat alat",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
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
                                    backgroundColor:
                                        const Color(0xFF6C6C87),
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

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12)),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
