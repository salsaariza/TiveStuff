import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/header_back.dart';
import '../widgets/nav_admin.dart';

class AktivitasScreen extends StatefulWidget {
  const AktivitasScreen({super.key});

  @override
  State<AktivitasScreen> createState() => _AktivitasScreenState();
}

class _AktivitasScreenState extends State<AktivitasScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<Map<String, dynamic>> aktivitas = [];
  bool isLoading = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchAktivitas();
  }

  // ================= FETCH DATA =================
  Future<void> fetchAktivitas() async {
    setState(() => isLoading = true);
    try {
      final List<dynamic> data = await supabase
          .from('log_aktivitas')
          .select('id_log, aktivitas, id_user, created_at')
          .order('created_at', ascending: false);

      setState(() {
        aktivitas = data
            .map((e) => {
                  'id': e['id_log'],
                  'aktivitas': e['aktivitas'] ?? '',
                  'petugas': e['id_user'] ?? 'Unknown',
                  'created_at': e['created_at'] != null
                      ? DateTime.parse(e['created_at']).toLocal()
                      : null,
                })
            .toList();
      });
    } catch (e) {
      print('Error fetching aktivitas: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================= SEARCH FILTER =================
  List<Map<String, dynamic>> get filteredAktivitas {
    if (searchQuery.isEmpty) return aktivitas;
    return aktivitas
        .where((a) =>
            a['aktivitas'].toLowerCase().contains(searchQuery.toLowerCase()) ||
            a['petugas'].toString().toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),

      // ================= NAVBAR =================
      bottomNavigationBar: AppBottomNav(
        currentIndex: 4,
        onTap: (index) {
          if (index == 4) return;
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/alat');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/pengguna');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/riwayat');
          }
        },
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Header(),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Log Aktivitas",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ================= SEARCH BAR =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (value) => setState(() => searchQuery = value),
                decoration: InputDecoration(
                  hintText: "Cari",
                  hintStyle: GoogleFonts.poppins(fontSize: 15),
                  suffixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: Colors.grey.shade400, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFF6C6D7A), width: 2),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ================= LIST AKTIVITAS =================
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredAktivitas.isEmpty
                      ? Center(
                          child: Text(
                            "Data Aktivitas Kosong",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: filteredAktivitas.length,
                          itemBuilder: (context, index) {
                            return _aktivitasCard(filteredAktivitas[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CARD =================
  Widget _aktivitasCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['aktivitas'],
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Petugas : ${data['petugas']}",
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.black54,
            ),
          ),

          Text(
            data['created_at'] != null
                ? "Waktu : ${data['created_at'].day}-${data['created_at'].month}-${data['created_at'].year} ${data['created_at'].hour}:${data['created_at'].minute}"
                : "",
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 12),

        ],
      ),
    );
  }
}
