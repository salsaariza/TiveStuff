import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tivestuff1/widgets/back_peminjam.dart';
import 'package:tivestuff1/widgets/nav_peminjam.dart';

class PengembalianPeminjamScreen extends StatefulWidget {
  const PengembalianPeminjamScreen({super.key});

  @override
  State<PengembalianPeminjamScreen> createState() => _PengembalianScreenState();
}

class _PengembalianScreenState extends State<PengembalianPeminjamScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> pengembalianList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPengembalian();
  }

  /// ================= FETCH DATA DARI SUPABASE =================
  Future<void> fetchPengembalian() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final data = await supabase
          .from('pengembalian')
          .select('''
            id_pengembalian,
            tanggal_kembali,
            kondisi_alat,
            total_denda,
            peminjaman: peminjaman!pengembalian_id_peminjaman_fkey (
              id_peminjaman,
              tanggal_pinjam,
              status_peminjaman,
              users!peminjaman_id_user_fkey (
                username,
                email
              ),
              detail_peminjaman (
                id_alat,
                alat: alat!detail_peminjaman_id_alat_fkey (
                  nama_alat
                )
              )
            )
          ''')
          .eq('peminjaman.id_user', user.id)
          .order('created_at', ascending: false);

      setState(() {
        pengembalianList = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR FETCH PENGEMBALIAN: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

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
            Navigator.pushReplacementNamed(context, '/dashboardpeminjam');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/alatpeminjam');
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : pengembalianList.isEmpty
                              ? Center(
                                  child: Text(
                                    'Belum ada pengembalian',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: pengembalianList.length,
                                  itemBuilder: (context, index) {
                                    return PengembalianCard(
                                      data: pengembalianList[index],
                                    );
                                  },
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
  final Map<String, dynamic> data;
  const PengembalianCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final peminjaman = data['peminjaman'] ?? {};
    final user = peminjaman['users'] ?? {};
    final detail = peminjaman['detail_peminjaman'] ?? [];

    final String alat = detail.isEmpty
        ? '-'
        : detail.map((e) => e['alat']?['nama_alat'] ?? '-').join(', ');

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
                'PG-${data['id_pengembalian']}',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9B9B9B),
                ),
              ),
              Text(
                data['tanggal_kembali']?.toString().substring(0, 10) ?? '-',
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
            user['username'] ?? '-',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D2D2D),
            ),
          ),

          const SizedBox(height: 4),

          /// Email / Kelas
          Text(
            user['email'] ?? '-',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF7B7B7B),
            ),
          ),

          const SizedBox(height: 6),

          /// Barang
          Text(
            alat,
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
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: data['kondisi_alat'] == 'baik'
                      ? const Color(0xFF4CAF50)
                      : Colors.red,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  data['kondisi_alat'] ?? '-',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          if ((data['total_denda'] ?? 0) > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Total Denda: ${data['total_denda']}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
