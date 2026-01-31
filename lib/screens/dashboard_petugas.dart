import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tivestuff1/widgets/header_petugas.dart';
import 'package:tivestuff1/widgets/nav_petugas.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPetugas extends StatefulWidget {
  const DashboardPetugas({super.key});

  @override
  State<DashboardPetugas> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardPetugas> {
  final SupabaseClient supabase = Supabase.instance.client;

  // ================= DATA =================
  int totalUser = 0;
  int totalAlat = 0;
  int alatTersedia = 0;
  int alatDipinjam = 0;

  List<Map<String, dynamic>> riwayat = [];
  bool isLoading = true;

  // ================= RESPONSIVE FONT =================
  double rf(BuildContext context, double base) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1024) return base + 4;
    if (width >= 600) return base + 2;
    return base;
  }

  @override
  void initState() {
    super.initState();
    fetchDashboard();
  }

  // ================= FETCH DASHBOARD =================
  Future<void> fetchDashboard() async {
    try {
      // ================= USERS =================
      final usersRes = await supabase.from('users').select('id_user');
      final List users = List.from(usersRes);

      // ================= ALAT =================
      final alatRes = await supabase.from('alat').select('id_alat');
      final List alat = List.from(alatRes);

      // ================= ALAT TERSEDIA =================
      final tersediaRes = await supabase
          .from('alat')
          .select('id_alat')
          .eq('ketersediaan', 'ada');
      final List tersedia = List.from(tersediaRes);

      // ================= ALAT DIPINJAM =================
      final dipinjamRes = await supabase
          .from('peminjaman')
          .select('id_peminjaman')
          .or(
            'status_peminjaman.eq.menunggu,'
            'status_peminjaman.eq.disetujui,'
            'status_peminjaman.eq.ditolak',
          );
      final List dipinjam = List.from(dipinjamRes);

      // ================= RIWAYAT =================
      final historyRes = await supabase
          .from('peminjaman')
          .select('id_peminjaman, created_at')
          .order('created_at', ascending: false)
          .limit(5);

      final List<Map<String, dynamic>> history =
          List<Map<String, dynamic>>.from(historyRes);

      if (!mounted) return;

      setState(() {
        totalUser = users.length;
        totalAlat = alat.length;
        alatTersedia = tersedia.length;
        alatDipinjam = dipinjam.length;
        riwayat = history;
        isLoading = false;
      });
    } catch (e, s) {
      debugPrint('ERROR DASHBOARD: $e');
      debugPrint('STACKTRACE: $s');
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),

      // ================= NAVBAR =================
      bottomNavigationBar: NavPetugas(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;

          switch (index) {
            case 1:
              Navigator.pushReplacementNamed(context, '/peminjaman');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/pengembalian');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/laporan');
              break;
          }
        },
      ),


      // ================= BODY =================
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DashboardHeaderPetugas(),
                    const SizedBox(height: 20),
                    _dashboardTitle(context),
                    const SizedBox(height: 12),
                    _statsGrid(context),
                    const SizedBox(height: 24),
                    _riwayatTitle(context),
                    const SizedBox(height: 12),
                    _riwayatList(context),
                  ],
                ),
              ),
      ),
    );
  }

  // ================= TITLE =================
  Widget _dashboardTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Text(
        "Dashboard",
        style: GoogleFonts.poppins(
          fontSize: rf(context, 18),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ================= GRID =================
  Widget _statsGrid(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 600 ? 4 : 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
        children: [
          _statCard(context, totalUser.toString(), "PENGGUNA"),
          _statCard(context, totalAlat.toString(), "JUMLAH ALAT"),
          _statCard(context, alatTersedia.toString(), "ALAT TERSEDIA"),
          _statCard(context, alatDipinjam.toString(), "ALAT DIPINJAM"),
        ],
      ),
    );
  }

  // ================= CARD =================
  Widget _statCard(BuildContext context, String value, String title) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade400, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: rf(context, 20),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: rf(context, 14),
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ================= RIWAYAT =================
  Widget _riwayatTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        "Daftar Riwayat Peminjaman",
        style: GoogleFonts.poppins(
          fontSize: rf(context, 16),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _riwayatList(BuildContext context) {
    if (riwayat.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text("Belum ada riwayat peminjaman"),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: riwayat.map((item) {
          final date = DateTime.parse(item['created_at']);
          return _riwayatItem(
            context,
            "Peminjaman #${item['id_peminjaman']}",
            "${date.hour}:${date.minute.toString().padLeft(2, '0')} | "
                "${date.day}-${date.month}-${date.year}",
          );
        }).toList(),
      ),
    );
  }

  Widget _riwayatItem(BuildContext context, String title, String tanggal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: rf(context, 14),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  tanggal,
                  style: GoogleFonts.poppins(
                    fontSize: rf(context, 12),
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
