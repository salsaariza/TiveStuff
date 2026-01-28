import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tivestuff1/widgets/back_petugas.dart';
import 'package:tivestuff1/widgets/nav_petugas.dart';
import 'package:tivestuff1/petugas/detail_pengembalian.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PengembalianScreen extends StatefulWidget {
  const PengembalianScreen({super.key});

  @override
  State<PengembalianScreen> createState() => _PengembalianPageState();
}

class _PengembalianPageState extends State<PengembalianScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: SafeArea(
        child: Column(
          children: const [
            HeaderPetugas(),
            Expanded(child: _PengembalianContent()),
          ],
        ),
      ),
      bottomNavigationBar: NavPetugas(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) return;
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboardpetugas');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/peminjaman');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/laporan');
          }
        },
      ),
    );
  }
}

// =====================================================

class _PengembalianContent extends StatefulWidget {
  const _PengembalianContent();

  @override
  State<_PengembalianContent> createState() => _PengembalianContentState();
}

class _PengembalianContentState extends State<_PengembalianContent> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<Map<String, dynamic>> dataPengembalian = [];
  bool isLoading = true;
  String search = '';

  @override
  void initState() {
    super.initState();
    fetchPengembalian();
  }

  // ================= FETCH DATA FIX =================
  Future<void> fetchPengembalian() async {
    try {
      setState(() => isLoading = true);

      final res = await supabase
          .from('pengembalian')
          .select('''
        id_pengembalian,
        tanggal_kembali,
        hari_terlambat,
        peminjaman (
          id_peminjaman,
          tanggal_pinjam,
          tingkatan_kelas,
          users!peminjaman_id_user_fkey ( username ),
          alat ( nama_alat )
        )
      ''')
          .order('id_pengembalian', ascending: false);

      final List<Map<String, dynamic>> temp = [];

      for (final e in res) {
        final p = e['peminjaman'];
        if (p == null) continue;

        temp.add({
          'id_pengembalian': e['id_pengembalian'],
          'id_peminjaman': p['id_peminjaman'],
          'kode': 'PJ ${p['id_peminjaman'].toString().padLeft(4, '0')}',
          'nama': p['users']['username'],
          'kelas': p['tingkatan_kelas'],
          'alat': p['alat']['nama_alat'],
          'tanggal_pinjam': p['tanggal_pinjam'],
          'tanggal_kembali': e['tanggal_kembali'],
          'terlambat': e['hari_terlambat'] ?? 0,
        });
      }

      setState(() {
        dataPengembalian = temp;
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = dataPengembalian.where((e) {
      return e['kode'].toLowerCase().contains(search.toLowerCase()) ||
          e['nama'].toLowerCase().contains(search.toLowerCase());
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            "Pengembalian",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // SEARCH
          TextField(
            onChanged: (v) => setState(() => search = v),
            decoration: InputDecoration(
              hintText: "Cari",
              suffixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // LIST
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final d = filtered[i];
                      final terlambat = d['terlambat'] > 0;

                      return _BaseCardPengembalian(
                        id: d['kode'],
                        nama: d['nama'],
                        kelas: d['kelas'],
                        tanggalPinjam: d['tanggal_pinjam'].toString().substring(
                          0,
                          10,
                        ),
                        alat: d['alat'],
                        tanggalKembali: d['tanggal_kembali']
                            .toString()
                            .substring(0, 10),
                        button: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: terlambat
                                ? Colors.red
                                : const Color(0xFF5B8F2E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DetailPengembalianScreen(data: d),
                              ),
                            );

                            if (result == true) {
                              fetchPengembalian(); // 🔁 refresh list
                            }
                          },

                          child: Text(
                            terlambat
                                ? 'Konfirmasi Pengembalian Terlambat'
                                : 'Konfirmasi Pengembalian',
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// =====================================================

class _BaseCardPengembalian extends StatelessWidget {
  final String id;
  final String nama;
  final String kelas;
  final String tanggalPinjam;
  final String alat;
  final String tanggalKembali;
  final Widget button;

  const _BaseCardPengembalian({
    required this.id,
    required this.nama,
    required this.kelas,
    required this.tanggalPinjam,
    required this.alat,
    required this.tanggalKembali,
    required this.button,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(id), Text(tanggalPinjam)],
          ),
          const SizedBox(height: 8),
          Text(nama, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(kelas),
          Text(alat),
          const SizedBox(height: 6),
          Text('Pengembalian : $tanggalKembali'),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: button),
        ],
      ),
    );
  }
}
