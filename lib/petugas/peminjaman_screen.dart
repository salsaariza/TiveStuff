import 'package:flutter/material.dart';
import 'package:tivestuff1/widgets/back_petugas.dart';
import 'package:tivestuff1/widgets/nav_petugas.dart';
import 'package:google_fonts/google_fonts.dart';

class PengajuanPeminjamanScreen extends StatefulWidget {
  const PengajuanPeminjamanScreen({super.key});

  @override
  State<PengajuanPeminjamanScreen> createState() =>
      _PengajuanPeminjamanScreenState();
}

class _PengajuanPeminjamanScreenState extends State<PengajuanPeminjamanScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFE6E6E6),
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

      body: SafeArea(
        child: Column(
          children: [
            const HeaderPetugas(),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? size.width * 0.15 : 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      "Pengajuan Peminjaman",
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
                          borderSide: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1.5,
                          ),
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
                          PengajuanCard(
                            kode: "PJ 1261",
                            nama: "Ajeng Chalista",
                            kelas: "XI TKR 1",
                            tanggal: "19-01-2026",
                            barang: "1 Kompresor, 1 Obeng",
                          ),
                          PengajuanCard(
                            kode: "PJ 1262",
                            nama: "Richo Ferdinand",
                            kelas: "XI TKR 5",
                            tanggal: "19-01-2026",
                            barang: "1 Kunci Inggris, 1 Jangka Sorong",
                          ),
                          PengajuanCard(
                            kode: "PJ 1263",
                            nama: "Azura Selly",
                            kelas: "XII TKR 1",
                            tanggal: "19-01-2026",
                            barang: "1 Mikrometer",
                          ),
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

// ================= CARD =================
class PengajuanCard extends StatelessWidget {
  final String kode;
  final String nama;
  final String kelas;
  final String tanggal;
  final String barang;

  const PengajuanCard({
    super.key,
    required this.kode,
    required this.nama,
    required this.kelas,
    required this.tanggal,
    required this.barang,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          Row(
            children: [
              Text(
                kode,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              Text(
                tanggal,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            nama,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Text(kelas, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(barang, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF6B6D7A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Tolak", style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/detailpeminjaman',
                      arguments: {
                        'kode': kode,
                        'nama': nama,
                        'kelas': kelas,
                        'tanggal': tanggal,
                        'barang': barang,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B6D7A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Setuju",
                    style: TextStyle(fontSize: 12, color: Colors.white),
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
