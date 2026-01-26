import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tivestuff1/widgets/back_peminjam.dart';
import '../widgets/nav_peminjam.dart';

class AlatPeminjamScreen extends StatefulWidget {
  const AlatPeminjamScreen({super.key});

  @override
  State<AlatPeminjamScreen> createState() => _AlatScreenState();
}

class _AlatScreenState extends State<AlatPeminjamScreen> {
  String selectedCategory = "Kategori";

  // ================= DATA ALAT + KATEGORI =================
  final List<Map<String, String>> alatList = [
    {"nama": "Multimeter", "kategori": "Kelistrikan"},
    {"nama": "Bor Listrik", "kategori": "Kelistrikan"},
    {"nama": "Tang Ampere", "kategori": "Kelistrikan"},
    {"nama": "Scanner ECU", "kategori": "Diagnostik"},
    {"nama": "Power Supply", "kategori": "Kelistrikan"},
  ];

  // ================= KERANJANG =================
  final List<String> keranjang = [];

  // ================= FILTERED ALAT =================
  List<Map<String, String>> get alatFiltered {
    if (selectedCategory == "Semua" || selectedCategory == "Kategori") {
      return alatList;
    }
    return alatList
        .where((alat) => alat["kategori"] == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),

      // ================= FLOATING BUTTON (FIX) =================
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
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
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
            Navigator.pushReplacementNamed(
                context, '/dashboardpeminjam');
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
            Expanded(child: _gridAlat()),
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

          // SEARCH (UI only)
          TextField(
            decoration: InputDecoration(
              hintText: "Cari",
              hintStyle: GoogleFonts.poppins(fontSize: 13),
              suffixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: Colors.grey.shade400, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                    color: Color(0xFF6C6D7A), width: 2),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // FILTER
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _showCategoryDropdown,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                  const Icon(Icons.keyboard_arrow_down,
                      size: 18, color: Colors.white),
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
              _categoryItem("Kelistrikan"),
              _categoryItem("Diagnostik"),
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
          return _alatCard(alat["nama"]!);
        },
      ),
    );
  }

  // ================= CARD ALAT =================
  Widget _alatCard(String namaAlat) {
    final bool sudahDiKeranjang = keranjang.contains(namaAlat);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: sudahDiKeranjang
          ? null
          : () {
              setState(() => keranjang.add(namaAlat));

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("$namaAlat ditambahkan ke keranjang"),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
      child: Container(
        decoration: BoxDecoration(
          color: sudahDiKeranjang
              ? Colors.grey.shade200
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: Colors.grey.shade400, width: 1.5),
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
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                namaAlat,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "Stok : 10",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "Spesifikasi",
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
