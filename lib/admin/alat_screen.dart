import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tivestuff1/admin/edit_alat_screen.dart';

import '../models/alat_models.dart';
import '../widgets/header_back.dart';
import '../widgets/nav_admin.dart';
import 'add_alat.dart';
import 'add_kategori.dart';

/// ================= MODEL KATEGORI =================
class KategoriModel {
  final int id;
  final String nama;
  final DateTime? deleteAt;

  KategoriModel({
    required this.id,
    required this.nama,
    this.deleteAt,
  });

  factory KategoriModel.fromMap(Map<String, dynamic> map) {
    return KategoriModel(
      id: map['id_kategori'],
      nama: map['nama_kategori'],
      deleteAt: map['delete_at'] != null
          ? DateTime.tryParse(map['delete_at'])
          : null,
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

  /// subscription realtime
  StreamSubscription? alatSub;
  StreamSubscription? kategoriSub;

  @override
  void initState() {
    super.initState();
    setupRealtimeKategori();
    setupRealtimeAlat();
  }

  @override
  void dispose() {
    alatSub?.cancel();
    kategoriSub?.cancel();
    super.dispose();
  }

  /// ================= REALTIME ALAT =================
  void setupRealtimeAlat() {
    alatSub = supabase
        .from('alat')
        .stream(primaryKey: ['id_alat'])
        .listen((event) {
          final data = event
              .map((e) => AlatModel.fromMap(e))
              .where((alat) => alat.deleteAt == null)
              .toList();

          if (!mounted) return;

          setState(() {
            alatList = data;

            filteredList = selectedKategori == null
                ? data
                : data
                    .where((alat) =>
                        alat.idKategori == selectedKategori!.id)
                    .toList();

            isLoading = false;
          });
        });
  }

  /// ================= REALTIME KATEGORI =================
  void setupRealtimeKategori() {
    kategoriSub = supabase
        .from('kategori')
        .stream(primaryKey: ['id_kategori'])
        .listen((event) {
          final data = event
              .map((e) => KategoriModel.fromMap(e))
              .where((k) => k.deleteAt == null)
              .toList();

          if (!mounted) return;

          setState(() {
            kategoriList = data;
            if (selectedKategori != null &&
                !kategoriList.any((k) => k.id == selectedKategori!.id)) {
              selectedKategori = null;
            }

            filteredList = selectedKategori == null
                ? alatList
                : alatList
                    .where((alat) =>
                        alat.idKategori == selectedKategori!.id)
                    .toList();
          });
        });
  }

  /// ================= FILTER KATEGORI =================
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
          .where((alat) =>
              alat.nama.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    });
  }

  /// ================= DELETE ALAT =================
  Future<void> deleteAlat(int id) async {
    try {
      await supabase.from('alat').delete().eq('id_alat', id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alat berhasil dihapus permanen")),
      );
    } catch (e) {
      debugPrint("ERROR DELETE ALAT: $e");
    }
  }

  /// ================= KONFIRMASI DELETE =================
  void confirmDelete(AlatModel alat) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          "Hapus Alat",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          "Apakah kamu yakin ingin menghapus alat '${alat.nama}'?",
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal", style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              deleteAlat(alat.id);
            },
            child: Text(
              "Hapus",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C6D7A),
        child: const Icon(Icons.build, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahAlatScreen()),
          );
        },
      ),

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

      body: SafeArea(
        child: Column(
          children: [
            const Header(),
            const SizedBox(height: 16),
            _searchSection(),
            const SizedBox(height: 10),
            _kategoriSection(),
            const SizedBox(height: 12),
            Expanded(child: _gridAlat()),
          ],
        ),
      ),
    );
  }

  /// ================= SEARCH UI =================
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
          const SizedBox(height: 20),
          TextField(
            onChanged: searchAlat,
            decoration: InputDecoration(
              hintText: "Cari alat",
              suffixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= KATEGORI UI =================
  Widget _kategoriSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF6C6D7A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<KategoriModel?>(
                value: selectedKategori,
                isDense: true,
                dropdownColor: Colors.white,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 18,
                ),
                hint: Text(
                  "Kategori",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text("Semua",
                        style: GoogleFonts.poppins(fontSize: 13,
                        color: Colors.white)),
                  ),
                  ...kategoriList.map(
                    (k) => DropdownMenuItem(
                      value: k,
                      child: Text(k.nama,
                          style: GoogleFonts.poppins(fontSize: 13)),
                    ),
                  ),
                ],
                onChanged: filterKategori,
              ),
            ),
          ),
          const SizedBox(width: 10),

          InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KategoriScreen()),
              );
            },
            child: Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF6C6D7A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= GRID UI =================
  Widget _gridAlat() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredList.isEmpty) {
      return Center(
        child: Text(
          "Data alat kosong",
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
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
        itemBuilder: (_, i) => _alatCard(filteredList[i]),
      ),
    );
  }

  /// ================= CARD UI =================
  Widget _alatCard(AlatModel alat) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 20),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "Stok : ${alat.stok}",
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditAlatScreen(alat: alat),
                    ),
                  ),
                  child: const Icon(Icons.edit, size: 20),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () => confirmDelete(alat),
                  child: const Icon(Icons.delete, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
