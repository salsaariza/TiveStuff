import 'package:flutter/material.dart';
import 'package:tivestuff1/widgets/back_peminjam.dart';
import 'package:tivestuff1/widgets/nav_peminjam.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PengajuanScreen extends StatefulWidget {
  const PengajuanScreen({super.key});

  @override
  State<PengajuanScreen> createState() => _PengajuanScreenState();
}

class _PengajuanScreenState extends State<PengajuanScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> pengajuanList = [];
  bool isLoading = true; // ✅ LOADING STATE

  @override
  void initState() {
    super.initState();
    fetchPengajuan();
  }

  /// ================= FETCH DATA =================
  Future<void> fetchPengajuan() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final data = await supabase
          .from('peminjaman')
          .select('''
          id_peminjaman,
          tanggal_pinjam,
          status_peminjaman,
          id_alat,
          users!peminjaman_id_user_fkey (
            username,
            email
          ),

          detail_peminjaman (
            id_alat,

            alat:alat!detail_peminjaman_id_alat_fkey (
              nama_alat
            )
          )
        ''')
          .eq('id_user', user.id)
          .order('created_at', ascending: false);

      setState(() {
        pengajuanList = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR FETCH PENGAJUAN: $e");
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
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) return;
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboardpeminjam');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/alatpeminjam');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/pengembalianpeminjam');
          }
        },
      ),

      /// ================= BODY =================
      body: SafeArea(
        child: Column(
          children: [
            const BackPeminjam(),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pengajuan",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    /// ================= CONTENT =================
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : pengajuanList.isEmpty
                          ? Center(
                              child: Text(
                                'Belum ada pengajuan',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: pengajuanList.length,
                              itemBuilder: (context, index) {
                                return PengajuanCard(
                                  data: pengajuanList[index],
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
class PengajuanCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const PengajuanCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final List detail = data['detail_peminjaman'] ?? [];

    final String alat = detail.isEmpty
        ? '-'
        : detail.map((e) => e['alat']?['nama_alat'] ?? '-').join(', ');

    final bool canReturn = data['status_peminjaman'] == 'disetujui';

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
          /// Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PJ-${data['id_peminjaman']}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9B9B9B),
                ),
              ),
              Text(
                data['tanggal_pinjam']?.toString().substring(0, 10) ?? '-',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9B9B9B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// Nama
          Text(
            data['users']?['username'] ?? '-',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D2D2D),
            ),
          ),

          const SizedBox(height: 4),

          /// Email
          Text(
            data['users']?['email'] ?? '-',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Color(0xFF7B7B7B),
            ),
          ),

          const SizedBox(height: 6),

          /// Alat
          Text(
            alat,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Color(0xFF7B7B7B),
            ),
          ),

          const SizedBox(height: 12),

          /// Status & Pengembalian
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Status :',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF7B7B7B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 26,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _statusColor(data['status_peminjaman']),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Text(
                      data['status_peminjaman'] ?? '-',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

  
              if (canReturn)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/pengembalianpeminjam',
                      arguments: data['id_peminjaman'],
                    );
                  },
                  child: const Text(
                    'Kembalikan',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
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

  static Color _statusColor(String? status) {
    switch (status) {
      case 'menunggu':
        return Colors.orange;
      case 'disetujui':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

