import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/header_back.dart';
import '../widgets/nav_admin.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  final supabase = Supabase.instance.client;

  int selectedFilter = 0; // 0 = Semua, 1 = Peminjaman, 2 = Pengembalian
  bool isLoading = true;

  List<Map<String, dynamic>> riwayatData = [];

  final List<String> kondisiOptions = ['baik', 'pemeliharaan', 'rusak'];

  // ================== SEARCH ==================
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchRiwayat();

    // ✅ realtime search
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ================== FETCH DATA ==================
  Future<void> fetchRiwayat() async {
    setState(() => isLoading = true);

    try {
      // Ambil Peminjaman beserta user
      final peminjaman = await supabase
          .from('peminjaman')
          .select('''
            id_peminjaman, status_peminjaman, tanggal_pinjam, tanggal_kembali, 
            users!peminjaman_id_user_fkey(username)
            ''')
          .order('created_at', ascending: false);

      // Ambil Pengembalian beserta peminjaman dan user
      final pengembalian = await supabase
          .from('pengembalian')
          .select('''
            id_pengembalian, tanggal_kembali, kondisi_alat, peminjaman!pengembalian_id_peminjaman_fkey(
              users!peminjaman_id_user_fkey(username)
            )
            ''')
          .order('created_at', ascending: false);

      List<Map<String, dynamic>> combined = [];

      // Map Peminjaman
      for (var item in peminjaman) {
        combined.add({
          'id': item['id_peminjaman'],
          'nama': item['users']?['username'] ?? 'Unknown',
          'status': item['status_peminjaman'] ?? 'menunggu',
          'tanggal_pinjam': item['tanggal_pinjam'],
          'tanggal_kembali': item['tanggal_kembali'],
          'kondisi': '-',
          'type': 'Peminjaman',
        });
      }

      // Map Pengembalian
      for (var item in pengembalian) {
        combined.add({
          'id': item['id_pengembalian'],
          'nama': item['peminjaman']?['users']?['username'] ?? 'Unknown',
          'status': 'Pengembalian',
          'tanggal_pinjam': null,
          'tanggal_kembali': item['tanggal_kembali'],
          'kondisi': item['kondisi_alat'] ?? 'baik',
          'type': 'Pengembalian',
        });
      }

      setState(() {
        riwayatData = combined;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetchRiwayat: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengambil data riwayat: $e")),
      );
    }
  }

  // ================== FILTER + SEARCH ==================
  List<Map<String, dynamic>> get filteredData {
    List<Map<String, dynamic>> data = riwayatData;

    // ✅ Filter Chip
    if (selectedFilter == 1) {
      data = data.where((e) => e['type'] == 'Peminjaman').toList();
    } else if (selectedFilter == 2) {
      data = data.where((e) => e['type'] == 'Pengembalian').toList();
    }

    // ✅ Search Filter
    if (searchQuery.isNotEmpty) {
      data = data.where((e) {
        final nama = (e['nama'] ?? '').toString().toLowerCase();
        final status = (e['status'] ?? '').toString().toLowerCase();
        final kondisi = (e['kondisi'] ?? '').toString().toLowerCase();

        return nama.contains(searchQuery) ||
            status.contains(searchQuery) ||
            kondisi.contains(searchQuery);
      }).toList();
    }

    return data;
  }

  // ================== DELETE ==================
  Future<void> deleteRiwayat(Map<String, dynamic> item) async {
    try {
      if (item['type'] == 'Peminjaman') {
        await supabase
            .from('peminjaman')
            .delete()
            .eq('id_peminjaman', item['id']);
      } else {
        await supabase
            .from('pengembalian')
            .delete()
            .eq('id_pengembalian', item['id']);
      }

      fetchRiwayat();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Riwayat berhasil dihapus")),
      );
    } catch (e) {
      print("Error deleteRiwayat: $e");
    }
  }

  void showDeleteDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hapus Riwayat",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Yakin ingin menghapus data ini?",
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Batal",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      deleteRiwayat(item);
                    },
                    child: Text(
                      "Hapus",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================== EDIT (TETAP) ==================
  void editRiwayat(Map<String, dynamic> item) {
    DateTime tanggalKembali = item['tanggal_kembali'] != null
        ? DateTime.parse(item['tanggal_kembali'])
        : DateTime.now();
    String kondisi = item['kondisi'] ?? 'baik';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Edit Riwayat",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        "Tanggal Kembali",
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                      const SizedBox(height: 6),

                      GestureDetector(
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: tanggalKembali,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setStateDialog(() => tanggalKembali = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${tanggalKembali.day}-${tanggalKembali.month}-${tanggalKembali.year}",
                                style: GoogleFonts.poppins(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (item['type'] == 'Pengembalian') ...[
                        Text(
                          "Kondisi Alat",
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: kondisi,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          items: kondisiOptions
                              .map(
                                (k) => DropdownMenuItem(
                                  value: k,
                                  child: Text(
                                    k,
                                    style: GoogleFonts.poppins(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setStateDialog(
                            () => kondisi = value ?? kondisiOptions.first,
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                "Batal",
                                style: GoogleFonts.poppins(fontSize: 13),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (item['type'] == 'Pengembalian') {
                                  await supabase
                                      .from('pengembalian')
                                      .update({
                                        'tanggal_kembali':
                                            tanggalKembali.toIso8601String(),
                                        'kondisi_alat': kondisi,
                                      })
                                      .eq('id_pengembalian', item['id']);
                                } else {
                                  await supabase
                                      .from('peminjaman')
                                      .update({
                                        'tanggal_kembali':
                                            tanggalKembali.toIso8601String(),
                                      })
                                      .eq('id_peminjaman', item['id']);
                                }

                                Navigator.pop(context);
                                fetchRiwayat();
                              },
                              child: Text(
                                "Konfirmasi",
                                style: GoogleFonts.poppins(fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ================== UI ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 3,
        onTap: (index) {
          if (index == 3) return;
          if (index == 0) Navigator.pushReplacementNamed(context, '/dashboard');
          if (index == 1) Navigator.pushReplacementNamed(context, '/alat');
          if (index == 2) Navigator.pushReplacementNamed(context, '/pengguna');
          if (index == 4) Navigator.pushReplacementNamed(context, '/aktivitas');
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
                "Riwayat",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ✅ SEARCH FIELD (UI TIDAK BERUBAH)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: searchController,
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
            ),

            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _filterChip("Semua", 0),
                  const SizedBox(width: 8),
                  _filterChip("Peminjaman", 1),
                  const SizedBox(width: 8),
                  _filterChip("Pengembalian", 2),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _riwayatCard(filteredData[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String text, int index) {
    final isActive = selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF6C6D7A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: isActive ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _riwayatCard(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(10),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nama'],
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F8F2F),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item['status'],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (item['type'] == 'Pengembalian')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade600,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item['kondisi'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.delete, size: 18),
                onPressed: () => showDeleteDialog(item),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => editRiwayat(item),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
