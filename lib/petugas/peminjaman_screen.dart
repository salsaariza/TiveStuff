import 'package:flutter/material.dart';
import 'package:tivestuff1/widgets/back_petugas.dart';
import 'package:tivestuff1/widgets/nav_petugas.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tivestuff1/petugas/kartu_peminjaman.dart';

class PengajuanPeminjamanScreen extends StatefulWidget {
  const PengajuanPeminjamanScreen({super.key});

  @override
  State<PengajuanPeminjamanScreen> createState() =>
      _PengajuanPeminjamanScreenState();
}

class _PengajuanPeminjamanScreenState extends State<PengajuanPeminjamanScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<Map<String, dynamic>> peminjaman = [];
  bool isLoading = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchPeminjaman();

    // ===== REALTIME =====
    supabase.from('peminjaman').stream(primaryKey: ['id_peminjaman']).listen((
      data,
    ) {
      fetchPeminjaman(); 
    });
  }

  Future<void> fetchPeminjaman() async {
  setState(() => isLoading = true);

  try {
    final data = await supabase
        .from('peminjaman')
        .select()
        .order('created_at', ascending: false);

    List<Map<String, dynamic>> temp = [];

    for (var e in data) {
      String namaUser = '-';
      String namaAlat = '-';

      if (e['id_user'] != null) {
        final user = await supabase
            .from('users')
            .select('username')
            .eq('id_user', e['id_user'])
            .maybeSingle();

        namaUser = user?['username'] ?? '-';
      }

      if (e['id_alat'] != null) {
        final alat = await supabase
            .from('alat')
            .select('nama_alat')
            .eq('id_alat', e['id_alat'])
            .maybeSingle();

        namaAlat = alat?['nama_alat'] ?? '-';
      }

      temp.add({
        'id': e['id_peminjaman'],
        'kode': 'PJ ${e['id_peminjaman'].toString().padLeft(4, '0')}',
        'nama': namaUser,
        'kelas': e['tingkatan_kelas'] ?? '-',
        'tanggal': e['tanggal_pinjam'] != null
            ? DateTime.parse(e['tanggal_pinjam']).toLocal()
            : null,
        'alat': namaAlat,
        'status': e['status_peminjaman'],
      });
    }

    setState(() {
      peminjaman = temp;
      isLoading = false;
    });
  } catch (e) {
    debugPrint('ERROR FETCH: $e');
    setState(() => isLoading = false);
  }
}


  // ================= FILTER =================
  List<Map<String, dynamic>> get filteredPeminjaman {
    if (searchQuery.isEmpty) return peminjaman;

    return peminjaman.where((p) {
      return p['kode'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          p['nama'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          p['kelas'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          p['alat'].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  // ================= BUILD UI =================
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      bottomNavigationBar: NavPetugas(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboardpetugas');
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
                    TextField(
                      onChanged: (v) => setState(() => searchQuery = v),
                      decoration: InputDecoration(
                        hintText: "Cari",
                        suffixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              itemCount: filteredPeminjaman.length,
                              itemBuilder: (context, index) {
                                final data = filteredPeminjaman[index];
                                return PengajuanCard(
                                  id: data['id'],
                                  kode: data['kode'],
                                  nama: data['nama'],
                                  kelas: data['kelas'],
                                  tanggal: data['tanggal'] != null
                                      ? "${data['tanggal'].day}-${data['tanggal'].month}-${data['tanggal'].year}"
                                      : '-',
                                  alat: data['alat'],
                                  status: data['status'],
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

// ================= CARD  =================
class PengajuanCard extends StatefulWidget {
  final int id;
  final String kode;
  final String nama;
  final String kelas;
  final String tanggal;
  final String alat;
  final String status;

  const PengajuanCard({
    super.key,
    required this.id,
    required this.kode,
    required this.nama,
    required this.kelas,
    required this.tanggal,
    required this.alat,
    required this.status,
  });

  @override
  State<PengajuanCard> createState() => _PengajuanCardState();
}

class _PengajuanCardState extends State<PengajuanCard> {
  final supabase = Supabase.instance.client;
  late String status;

  @override
  void initState() {
    super.initState();
    status = widget.status;
  }

  Future<void> updateStatus(String newStatus) async {
    await supabase
        .from('peminjaman')
        .update({'status_peminjaman': newStatus})
        .eq('id_peminjaman', widget.id);
  }

  void _openKartuPeminjaman() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KartuPeminjamanScreen(idPeminjaman: widget.id),
      ),
    );
  }

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
            children: [Text(widget.kode), const Spacer(), Text(widget.tanggal)],
          ),
          const SizedBox(height: 6),
          Text(
            widget.nama,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(widget.kelas, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Text(widget.alat),
          const SizedBox(height: 12),

          if (status == 'menunggu')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => updateStatus('ditolak'),
                    child: const Text("Tolak"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => updateStatus('disetujui'),
                    child: const Text("Setuju"),
                  ),
                ),
              ],
            )
          else if (status == 'disetujui')
            InkWell(
              onTap: _openKartuPeminjaman,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4F4D8),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Text(
                      "Peminjaman Disetujui",
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFADCDC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.cancel, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Peminjaman Ditolak",
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
