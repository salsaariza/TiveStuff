import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tivestuff1/widgets/back_peminjam.dart';
import 'package:tivestuff1/widgets/nav_peminjam.dart';

class PengembalianPeminjamScreen extends StatefulWidget {
  const PengembalianPeminjamScreen({super.key});

  @override
  State<PengembalianPeminjamScreen> createState() =>
      _PengembalianPeminjamScreenState();
}

class _PengembalianPeminjamScreenState
    extends State<PengembalianPeminjamScreen> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _futurePeminjaman;

  @override
  void initState() {
    super.initState();
    _futurePeminjaman = fetchPeminjamanUser();
  }

  /// ================= FETCH PEMINJAMAN =================
  Future<List<Map<String, dynamic>>> fetchPeminjamanUser() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabase.from('peminjaman').select('''
      id_peminjaman,
      created_at,
      status_peminjaman,
      users!peminjaman_id_user_fkey(username, tingkatan_kelas),
      detail_peminjaman(
        jumlah,
        alat!detail_peminjaman_id_alat_fkey(nama_alat)
      ),
      pengembalian(id_pengembalian)
    ''').eq('id_user', userId).order('created_at', ascending: false);

    final List data = response as List;

    return data.map<Map<String, dynamic>>((item) {
      final detail = item['detail_peminjaman'] ?? [];
      final alat = detail
          .map((d) => '${d['jumlah']} ${d['alat']['nama_alat']}')
          .join(', ');

      final sudahDikembalikan =
          item['pengembalian'] != null &&
              (item['pengembalian'] as List).isNotEmpty;

      return {
        'id_peminjaman': item['id_peminjaman'],
        'kode': 'PG-${item['id_peminjaman'].toString().padLeft(4, '0')}',
        'nama': item['users']['username'] ?? '-',
        'kelas': item['users']['tingkatan_kelas'] ?? '-',
        'alat': alat,
        'status': item['status_peminjaman'],
        'sudah_dikembalikan': sudahDikembalikan,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
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
      body: SafeArea(
        child: Column(
          children: [
            const BackPeminjam(),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pengembalian",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                              return PengembalianCard(
                                data: data[index],
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

/// ================= CARD =================
class PengembalianCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const PengembalianCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final bool bisaAjukan =
        !data['sudah_dikembalikan'] && data['status'] == 'disetujui';

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data['kode'],
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: const Color(0xFF9B9B9B),
                ),
              ),
              Text(
                DateTime.now().toString().substring(0, 10),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF9B9B9B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data['nama'],
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data['kelas'],
            style: GoogleFonts.poppins(fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            data['alat'],
            style: GoogleFonts.poppins(fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Status :',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              const SizedBox(width: 8),
              bisaAjukan
                  ? GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/ajukanpengembalian',
                          arguments: {
                            'idPeminjaman': data['id_peminjaman']
                          },
                        );
                      },
                      child: Container(
                        height: 26,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Text(
                          'Ajukan Pengembalian',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      height: 26,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: data['sudah_dikembalikan']
                            ? Colors.green
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Text(
                        data['sudah_dikembalikan']
                            ? 'Sudah dikembalikan'
                            : data['status'],
                        style: GoogleFonts.poppins(
                          fontSize: 11,
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
