import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/alat_models.dart';
import '../widgets/header_back.dart';
import '../widgets/nav_admin.dart';

import 'add_alat.dart';
import 'add_kategori.dart';

/// ================= MODEL KATEGORI =================
class KategoriModel {
  final int id;
  final String nama;

  KategoriModel({
    required this.id,
    required this.nama,
  });

  factory KategoriModel.fromMap(Map<String, dynamic> map) {
    return KategoriModel(
      id: map['id_kategori'],
      nama: map['nama_kategori'],
    );
  }
}

/// ================= SCREEN =================
class AlatScreen extends StatefulWidget {
  const AlatScreen({super.key});

  @override
  State<AlatScreen> createState() => _AlatScreenState();
}

class _AlatScreenState extends State<AlatScreen> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;

  List<AlatModel> alatList = [];
  List<AlatModel> filteredList = [];

  List<KategoriModel> kategoriList = [];
  KategoriModel? selectedKategori;

  @override
  void initState() {
    super.initState();
    fetchKategori();
    fetchAlat();
  }

  /// ================= FETCH ALAT =================
  Future<void> fetchAlat() async {
    setState(() => isLoading = true);

    try {
      final response = await supabase
          .from('alat')
          .select()
          .filter('delete_at', 'is', null)
          .order('created_at', ascending: false);

      final data = (response as List)
          .map((e) => AlatModel.fromMap(e))
          .toList();

      setState(() {
        alatList = data;

        filteredList = selectedKategori == null
            ? data
            : data
                .where((alat) =>
                    alat.idKategori == selectedKategori!.id)
                .toList();
      });
    } catch (e) {
      debugPrint("ERROR FETCH ALAT: $e");
    }

    setState(() => isLoading = false);
  }

  /// ================= FETCH KATEGORI =================
  Future<void> fetchKategori() async {
    try {
      final response = await supabase
          .from('kategori')
          .select()
          .filter('delete_at', 'is', null)
          .order('nama_kategori');

      final data = (response as List)
          .map((e) => KategoriModel.fromMap(e))
          .toList();

      setState(() {
        kategoriList = data;
      });
    } catch (e) {
      debugPrint("ERROR FETCH KATEGORI: $e");
    }
  }

  /// ================= FILTER =================
  void filterKategori(KategoriModel? kategori) {
    setState(() {
      selectedKategori = kategori;

      filteredList = kategori == null
          ? alatList
          : alatList
              .where((alat) => alat.idKategori == kategori.id)
              .toList();
    });
  }

  /// ================= SEARCH =================
  void searchAlat(String keyword) {
    setState(() {
      filteredList = alatList
          .where(
            (alat) => alat.nama
                .toLowerCase()
                .contains(keyword.toLowerCase()),
          )
          .toList();
    });
  }

  /// ================= DELETE =================
  Future<void> deleteAlat(int id) async {
    try {
      await supabase.from('alat').update({
        'delete_at': DateTime.now().toIso8601String(),
      }).eq('id_alat', id);

      fetchAlat();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alat berhasil dihapus")),
      );
    } catch (e) {
      debugPrint("ERROR DELETE ALAT: $e");
    }
  }

  /// ================= EDIT =================
  Future<void> editAlat(AlatModel alat) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TambahAlatScreen(alat: alat),
      ),
    );

    if (result != null) {
      fetchAlat();
    }
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),

      /// FLOATING BUTTON TAMBAH ALAT
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C6D7A),
        child: const Icon(Icons.build, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TambahAlatScreen(),
            ),
          );

          if (result != null) {
            fetchAlat();
          }
        },
      ),

      /// NAVBAR
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;

          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/pengguna');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/riwayat');
          } else if (index == 4) {
            Navigator.pushReplacementNamed(context, '/aktivitas');
          }
        },
      ),

      /// BODY
      body: SafeArea(
        child: Column(
          children: [
            const Header(),
            const SizedBox(height: 16),
            _searchSection(),
            const SizedBox(height: 12),
            Expanded(child: _gridAlat()),
          ],
        ),
      ),
    );
  }

  /// ================= SEARCH + FILTER =================
  Widget _searchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Alat",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          /// SEARCH BAR
          TextField(
            onChanged: searchAlat,
            decoration: InputDecoration(
              hintText: "Cari alat",
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

          const SizedBox(height: 14),

          /// FILTER + TAMBAH KATEGORI
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _showCategoryDropdown,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C6D7A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        selectedKategori?.nama ?? "Semua",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              /// TAMBAH KATEGORI
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const KategoriScreen(),
                    ),
                  ).then((_) => fetchKategori());
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF6C6D7A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ================= DROPDOWN KATEGORI =================
  void _showCategoryDropdown() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  "Semua",
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                onTap: () {
                  filterKategori(null);
                  Navigator.pop(context);
                },
              ),
              ...kategoriList.map(
                (kategori) => ListTile(
                  title: Text(
                    kategori.nama,
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  onTap: () {
                    filterKategori(kategori);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ================= GRID ALAT =================
  Widget _gridAlat() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredList.isEmpty) {
      return Center(
        child: Text(
          "Data alat kosong",
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        itemCount: filteredList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemBuilder: (context, index) {
          return _alatCard(filteredList[index]);
        },
      ),
    );
  }

  /// ================= CARD ALAT =================
  Widget _alatCard(AlatModel alat) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade400, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// GAMBAR
            Container(
              height: 100,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
                image: alat.gambar != null
                    ? DecorationImage(
                        image: NetworkImage(alat.gambar!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),

            /// NAMA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                alat.nama,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 6),

            /// STOK
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "Stok : ${alat.stok}",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),

            const Spacer(),

            /// BUTTON EDIT + DELETE
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => editAlat(alat),
                    child: const Icon(Icons.edit, size: 20),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () => deleteAlat(alat.id),
                    child: const Icon(Icons.delete, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
