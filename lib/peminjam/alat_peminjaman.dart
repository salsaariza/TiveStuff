import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tivestuff1/widgets/back_peminjam.dart';
import '../widgets/nav_peminjam.dart';

class AlatPeminjamScreen extends StatefulWidget {
  const AlatPeminjamScreen({super.key});

  @override
  State<AlatPeminjamScreen> createState() => _AlatScreenState();
}

class _AlatScreenState extends State<AlatPeminjamScreen> {
  final supabase = Supabase.instance.client;

  String selectedCategory = "Kategori";

  // ================= LIST DATA DARI DATABASE =================
  List alatList = [];
  List kategoriList = [];

  bool isLoading = true;

  // ================= KERANJANG =================
  final List<Map<String, dynamic>> keranjang = [];

  // ================= FETCH KATEGORI =================
  Future<void> fetchKategori() async {
    final response = await supabase
        .from("kategori")
        .select()
        .order("nama_kategori", ascending: true);

    setState(() {
      kategoriList = response;
    });
  }

  // ================= FETCH ALAT + JOIN KATEGORI =================
  Future<void> fetchAlat() async {
    setState(() => isLoading = true);

    final response = await supabase
        .from("alat")
        .select('''
  id_alat,
  nama_alat,
  stok,
  spesifikasi_alat,
  gambar_alat,
  kategori (
    id_kategori,
    nama_kategori
  )
''')
        .order("created_at", ascending: false);

    setState(() {
      alatList = response;
      isLoading = false;
    });
  }

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    fetchKategori();
    fetchAlat();
  }

  // ================= FILTERED ALAT =================
  List get alatFiltered {
    if (selectedCategory == "Semua" || selectedCategory == "Kategori") {
      return alatList;
    }

    return alatList.where((alat) {
      return alat["kategori"]?["nama_kategori"] == selectedCategory;
    }).toList();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),

      // ================= FLOATING BUTTON =================
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C6D7A),
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/keranjangpeminjaman',
            arguments: keranjang,
          );
        },
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            const Icon(Icons.shopping_cart, color: Colors.white),
            if (keranjang.isNotEmpty)
              Positioned(
                right: 0,
                top: 0,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.red,
                  child: Text(
                    keranjang.length.toString(),
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),

      // ================= NAVBAR =================
      bottomNavigationBar: NavPeminjam(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;

          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboardpeminjam');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/pengajuanpeminjam');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/pengembalianpeminjam');
          }
        },
      ),

      // ================= BODY =================
      body: SafeArea(
        child: Column(
          children: [
            const BackPeminjam(),
            const SizedBox(height: 16),
            _searchSection(),
            const SizedBox(height: 12),

            // ================= GRID =================
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _gridAlat(),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SEARCH & FILTER =================
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
          const SizedBox(height: 8),

          // SEARCH (UI ONLY)
          TextField(
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
                borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
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

          const SizedBox(height: 15),

          // FILTER DROPDOWN
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _showCategoryDropdown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF6C6D7A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedCategory,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
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
        ],
      ),
    );
  }

  // ================= DROPDOWN KATEGORI =================
  void _showCategoryDropdown() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _categoryItem("Semua"),

              ...kategoriList.map((kategori) {
                return _categoryItem(kategori["nama_kategori"]);
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _categoryItem(String title) {
    return ListTile(
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
      onTap: () {
        setState(() => selectedCategory = title);
        Navigator.pop(context);
      },
    );
  }

  // ================= GRID =================
  Widget _gridAlat() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        itemCount: alatFiltered.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) {
          final alat = alatFiltered[index];
          return _alatCard(alat);
        },
      ),
    );
  }

  // ================= CARD ALAT =================
  Widget _alatCard(Map alat) {
    final String namaAlat = alat["nama_alat"];
    final int stok = alat["stok"] ?? 0;
    final String spesfikasiAlat = alat["spesifikasi_alat"] ?? "";
    final bool sudahDiKeranjang =
        keranjang.any((item) => item["nama_alat"] == namaAlat);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: sudahDiKeranjang
          ? null
          : () {
              setState(() {
                keranjang.add({
                  "nama_alat": namaAlat,
                  "stok": stok,
                  "spesifikasi_alat": spesfikasiAlat,
                  "gambar_alat": alat["gambar_alat"],
                });
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("$namaAlat ditambahkan ke keranjang"),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
      child: Container(
        decoration: BoxDecoration(
          color: sudahDiKeranjang ? Colors.grey.shade200 : Colors.white,
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
                image: alat["gambar_alat"] != null &&
                        alat["gambar_alat"].toString().isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(alat["gambar_alat"]),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: alat["gambar_alat"] == null
                  ? const Icon(Icons.image, size: 40, color: Colors.white70)
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                namaAlat,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "Stok : $stok",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "Spesifikasi : $spesfikasiAlat",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
