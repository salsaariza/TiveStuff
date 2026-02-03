import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tivestuff1/widgets/back_peminjam.dart';
import 'package:tivestuff1/widgets/nav_peminjam.dart';

class PengembalianPeminjamScreen extends StatefulWidget {
  const PengembalianPeminjamScreen({super.key});

  @override
  State<PengembalianPeminjamScreen> createState() =>
      _PengembalianScreenState();
}

class _PengembalianScreenState extends State<PengembalianPeminjamScreen> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _futurePeminjaman;

  @override
  void initState() {
    super.initState();
    _futurePeminjaman = fetchPeminjamanUser();
  }

  /// Fetch data peminjaman user dari Supabase v2
  Future<List<Map<String, dynamic>>> fetchPeminjamanUser() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    // Query join peminjaman + detail_peminjaman + alat + pengembalian
    final response = await supabase
        .from('peminjaman')
        .select(
          '''
          id_peminjaman,
          created_at,
          status_peminjaman,
          users!peminjaman_id_user_fkey(nama, tingkatan_kelas),
          detail_peminjaman(
            jumlah,
            alat!detail_peminjaman_id_alat_fkey(nama_alat)
          ),
          pengembalian(id_pengembalian)
          ''',
        )
        .eq('id_user', userId)
        .order('created_at', ascending: false);

    if (response == null) return [];

    // Supabase v2 sudah langsung return List<Map<String,dynamic>>
    final List data = response as List;

    return data.map<Map<String, dynamic>>((item) {
      // Gabungkan daftar alat
      final List detail = item['detail_peminjaman'] ?? [];
      final String listAlat = detail
          .map((d) => '${d['jumlah']} ${d['alat']['nama_alat']}')
          .join(', ');

      // Cek sudah dikembalikan
      final sudahDikembalikan =
          item['pengembalian'] != null && (item['pengembalian'] as List).isNotEmpty;

      return {
        'id_peminjaman': item['id_peminjaman'],
        'kode_peminjaman': 'PG ${item['id_peminjaman'].toString().padLeft(4, '0')}',
        'nama': item['users']['nama'] ?? '-',
        'kelas': item['users']['tingkatan_kelas'] ?? '-',
        'list_alat': listAlat,
        'status_peminjaman': item['status_peminjaman'],
        'sudah_dikembalikan': sudahDikembalikan,
      };
    }).toList();
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: _futurePeminjaman,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(
                                child: Text(
                                    'Terjadi kesalahan: ${snapshot.error}'));
                          }

                          final data = snapshot.data ?? [];
                          if (data.isEmpty) {
                            return const Center(
                                child: Text('Tidak ada peminjaman.'));
                          }

                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              final item = data[index];
                              return PengembalianCard(
                                kodePeminjaman: item['kode_peminjaman'],
                                nama: item['nama'],
                                kelas: item['kelas'],
                                listAlat: item['list_alat'],
                                sudahDikembalikan: item['sudah_dikembalikan'],
                                statusPeminjaman: item['status_peminjaman'],
                                idPeminjaman: item['id_peminjaman'],
                              );
                            },
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
  final String kodePeminjaman;
  final String nama;
  final String kelas;
  final String listAlat;
  final bool sudahDikembalikan;
  final String statusPeminjaman;
  final int idPeminjaman;

  const PengembalianCard({
    super.key,
    required this.kodePeminjaman,
    required this.nama,
    required this.kelas,
    required this.listAlat,
    required this.sudahDikembalikan,
    required this.statusPeminjaman,
    required this.idPeminjaman,
  });

  @override
  Widget build(BuildContext context) {
    // Hanya bisa ajukan pengembalian jika status = disetujui & belum dikembalikan
    bool bisaAjukan =
        !sudahDikembalikan && statusPeminjaman == 'disetujui';

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
                kodePeminjaman,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9B9B9B),
                ),
              ),
              Text(
                DateTime.now().toString().split(' ')[0],
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
            nama,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D2D2D),
            ),
          ),

          const SizedBox(height: 4),

          /// Kelas
          Text(
            kelas,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF7B7B7B),
            ),
          ),

          const SizedBox(height: 6),

          /// Barang
          Text(
            listAlat,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF7B7B7B),
            ),
          ),

          const SizedBox(height: 12),

          /// Status / Tombol Ajukan Pengembalian
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
              sudahDikembalikan
                  ? Container(
                      height: 26,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Text(
                        'Sudah dikembalikan',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : bisaAjukan
                      ? GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/ajukanpengembalian',
                              arguments: {'idPeminjaman': idPeminjaman},
                            );
                          },
                          child: Container(
                            height: 26,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Text(
                              'Ajukan Pengembalian',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          height: 26,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Text(
                            statusPeminjaman,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
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
