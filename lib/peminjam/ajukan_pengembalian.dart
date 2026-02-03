import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tivestuff1/widgets/back_peminjam.dart';
import 'package:tivestuff1/widgets/nav_peminjam.dart';

class AjukanPengembalianScreen extends StatefulWidget {
  const AjukanPengembalianScreen({super.key});

  @override
  State<AjukanPengembalianScreen> createState() =>
      _AjukanPengembalianScreenState();
}

class _AjukanPengembalianScreenState extends State<AjukanPengembalianScreen> {
  final supabase = Supabase.instance.client;

  int? idPeminjaman;
  bool isLoading = true;

  Map<String, dynamic>? peminjaman;
  List detailAlat = [];

  final List<String> kondisiEnum = ['baik', 'rusak', 'pemeliharaan'];

  final Map<int, String> kondisiAlat = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (route == null || route.settings.arguments == null) {
      setState(() => isLoading = false);
      return;
    }

    final args = route.settings.arguments as Map<String, dynamic>;
    idPeminjaman = args['idPeminjaman'];

    fetchDetail();
  }

  // ================= FETCH DETAIL =================
  Future<void> fetchDetail() async {
    if (idPeminjaman == null) {
      setState(() => isLoading = false);
      return;
    }

    final int peminjamanId = idPeminjaman!;

    try {
      final res = await supabase
          .from('peminjaman')
          .select('''
  id_peminjaman,
  tanggal_pinjam,
  tanggal_kembali,
  tingkatan_kelas,
  users!peminjaman_id_user_fkey(
    username,
    email
  ),
  detail_peminjaman(
    jumlah,
    alat(
      nama_alat
    )
  )
''')
          .eq('id_peminjaman', peminjamanId)
          .maybeSingle();

      if (res == null) {
        setState(() => isLoading = false);
        return;
      }

      setState(() {
        peminjaman = res;
        detailAlat = res['detail_peminjaman'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      debugPrint('ERROR FETCH DETAIL: $e');
      setState(() => isLoading = false);
    }
  }

  // ================= KONFIRMASI =================
  Future<void> konfirmasiPengembalian() async {
    if (idPeminjaman == null) return;

    final int peminjamanId = idPeminjaman!;

    try {
      for (int i = 0; i < detailAlat.length; i++) {
        if (!kondisiAlat.containsKey(i)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Semua kondisi alat harus diisi')),
          );
          return;
        }
      }

      for (int i = 0; i < detailAlat.length; i++) {
        await supabase.from('pengembalian').insert({
          'id_peminjaman': peminjamanId,
          'kondisi_alat': kondisiAlat[i],
          'tanggal_kembali': DateTime.now().toIso8601String(),
        });
      }

      // update status peminjaman
      await supabase
          .from('peminjaman')
          .update({'status_peminjaman': 'dikembalikan'})
          .eq('id_peminjaman', peminjamanId);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      debugPrint('ERROR KONFIRMASI: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal konfirmasi pengembalian')),
      );
    }
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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
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

                          _infoCard(),

                          const SizedBox(height: 12),

                          Text(
                            "Daftar Alat",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),

                          ...detailAlat.asMap().entries.map(
                            (entry) => _alatCard(entry.key, entry.value),
                          ),

                          const SizedBox(height: 12),

                          _dendaCard(),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: konfirmasiPengembalian,
                              child: Text(
                                "Konfirmasi Pengembalian",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
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

  // ================= WIDGET =================

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Nama : ${peminjaman?['users']?['username'] ?? '-'}"),
          Text("Email : ${peminjaman?['users']?['email'] ?? '-'}"),
          Text("Kelas : ${peminjaman?['tingkatan_kelas'] ?? '-'}"),
          const SizedBox(height: 6),
          Text(
            "Rencana Pengembalian : ${peminjaman?['tanggal_kembali'] ?? '-'}",
          ),
          Text("Tanggal Pinjam : ${peminjaman?['tanggal_pinjam'] ?? '-'}"),
          Text(
            "Tanggal Pengembalian : ${DateTime.now().toString().substring(0, 10)}",
          ),
        ],
      ),
    );
  }

  Widget _alatCard(int index, Map data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['alat']?['nama_alat'] ?? '-',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: DropdownButtonFormField<String>(
              value: kondisiAlat[index],
              hint: const Text('Kondisi Alat'),
              decoration: const InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              items: kondisiEnum.map((e) {
                return DropdownMenuItem(value: e, child: Text(e));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  kondisiAlat[index] = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _dendaCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Status : Tepat Waktu"),
          Text("Terlambat (hari) : 0"),
          Text("Denda Kerusakan : 0"),
          Text("Denda Terlambat : 0"),
          Divider(),
          Text("Total Denda : 0"),
        ],
      ),
    );
  }

  BoxDecoration _box() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
