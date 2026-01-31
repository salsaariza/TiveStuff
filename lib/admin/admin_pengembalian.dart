import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/header_back.dart';

// Kapitalisasi huruf pertama
String capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

class AdminPengembalianScreen extends StatefulWidget {
  final Map<String, dynamic> peminjaman;

  const AdminPengembalianScreen({Key? key, required this.peminjaman})
      : super(key: key);

  @override
  State<AdminPengembalianScreen> createState() =>
      _AdminPengembalianScreenState();
}

class _AdminPengembalianScreenState extends State<AdminPengembalianScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> daftarAlat = [];
  Map<int, String> kondisiAlat = {}; // kondisi per alat
  int dendaTerlambat = 0;
  int dendaKerusakan = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadDetailPeminjaman();
  }

  // ====================== LOAD DETAIL PEMINJAMAN ======================
  Future<void> loadDetailPeminjaman() async {
    try {
      final idPeminjaman = widget.peminjaman['id'];

      final alatData = await supabase
          .from('detail_peminjaman')
          .select('id_alat, alat!detail_peminjaman_id_alat_fkey(nama_alat, stok)')
          .eq('id_peminjaman', idPeminjaman);

      setState(() {
        daftarAlat = List<Map<String, dynamic>>.from(alatData);
        for (var alat in daftarAlat) {
          // default 'baik' sesuai enum Supabase
          kondisiAlat[alat['id_alat']] = 'baik';
        }

        // hitung denda terlambat
        final tanggalKembaliRencana =
            DateTime.parse(widget.peminjaman['tanggal_kembali']);
        if (DateTime.now().isAfter(tanggalKembaliRencana)) {
          dendaTerlambat =
              DateTime.now().difference(tanggalKembaliRencana).inDays;
        }
      });
    } catch (e) {
      debugPrint('Error loadDetailPeminjaman: $e');
    }
  }

  // ====================== KONFIRMASI PENGEMBALIAN ======================
  Future<void> konfirmasiPengembalian() async {
    setState(() => isLoading = true);
    try {
      final idPeminjaman = widget.peminjaman['id'];
      dendaKerusakan = 0;

      for (var alat in daftarAlat) {
        final kerusakan =
            kondisiAlat[alat['id_alat']] != 'baik' ? 100000 : 0;
        dendaKerusakan += kerusakan;

        final tanggalKembaliRencana =
            DateTime.parse(widget.peminjaman['tanggal_kembali']);
        final hariTerlambat = DateTime.now().isAfter(tanggalKembaliRencana)
            ? DateTime.now().difference(tanggalKembaliRencana).inDays
            : 0;

        // insert pengembalian
        await supabase.from('pengembalian').insert({
          'id_peminjaman': idPeminjaman,
          'tanggal_kembali': DateTime.now().toIso8601String(),
          'hari_terlambat': hariTerlambat,
          'kondisi_alat': kondisiAlat[alat['id_alat']] ?? 'baik',
          'denda_terlambat': hariTerlambat * 10000,
          'denda_rusak': kerusakan,
          'update_at': DateTime.now().toIso8601String(),
        });

        // update stok alat
        await supabase.from('alat').update({
          'stok': (alat['alat']['stok'] ?? 0) + 1,
        }).eq('id_alat', alat['id_alat']);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengembalian berhasil')));
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error konfirmasiPengembalian: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Gagal pengembalian')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ====================== BUILD UI ======================
  @override
  Widget build(BuildContext context) {
    final pem = widget.peminjaman;

    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: SafeArea(
        child: Column(
          children: [
            const Header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Info Peminjaman ---
                    Text(
                      "Pengembalian",
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Nama : ${pem['nama']}",
                                style: GoogleFonts.poppins(fontSize: 12)),
                            Text("Email : ${pem['email']}",
                                style: GoogleFonts.poppins(fontSize: 12)),
                            Text("Kelas : ${pem['kelas'] ?? '-'}",
                                style: GoogleFonts.poppins(fontSize: 12)),
                            const SizedBox(height: 6),
                            Text(
                                "Rencana Pengembalian : ${pem['tanggal_kembali'] ?? '-'}",
                                style: GoogleFonts.poppins(fontSize: 12)),
                            Text(
                                "Tanggal Pinjam : ${pem['tanggal_pinjam'] ?? '-'}",
                                style: GoogleFonts.poppins(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Daftar Alat ---
                    Text(
                      "Daftar Alat",
                      style: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    if (daftarAlat.isEmpty)
                      Center(
                        child: Text(
                          "Data alat kosong",
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ),
                    ...daftarAlat.map((alat) {
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(alat['alat']['nama_alat'] ?? '-',
                                  style: GoogleFonts.poppins(fontSize: 13)),
                              const SizedBox(height: 6),
                              Text("Kondisi Alat :",
                                  style: GoogleFonts.poppins(fontSize: 12)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                value: capitalize(
                                    kondisiAlat[alat['id_alat']] ?? 'baik'),
                                items: ['Baik', 'Pemeliharaan', 'Rusak']
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(
                                          e,
                                          style:
                                              GoogleFonts.poppins(fontSize: 12),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    // simpan lowercase sesuai Supabase
                                    kondisiAlat[alat['id_alat']] =
                                        val!.toLowerCase();
                                  });
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 16),

                    // --- Denda ---
                    Text(
                      "Denda",
                      style: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Status : ${dendaTerlambat > 0 ? 'Terlambat' : 'Tepat Waktu'}",
                                style: GoogleFonts.poppins(fontSize: 12)),
                            Text("Terlambat (hari) : $dendaTerlambat",
                                style: GoogleFonts.poppins(fontSize: 12)),
                            Text("Denda Kerusakan : $dendaKerusakan",
                                style: GoogleFonts.poppins(fontSize: 12)),
                            Text("Denda Terlambat : ${dendaTerlambat * 10000}",
                                style: GoogleFonts.poppins(fontSize: 12)),
                            Text(
                                "Total Denda : ${(dendaTerlambat * 10000) + dendaKerusakan}",
                                style: GoogleFonts.poppins(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- Button Konfirmasi ---
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed:
                            isLoading ? null : konfirmasiPengembalian,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                "Konfirmasi Pengembalian",
                                style: GoogleFonts.poppins(
                                    fontSize: 13, color: Colors.white),
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
