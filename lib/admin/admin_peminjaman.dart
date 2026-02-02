import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tivestuff1/widgets/header_back.dart';

class AdminPeminjamScreen extends StatefulWidget {
  const AdminPeminjamScreen({super.key});

  @override
  State<AdminPeminjamScreen> createState() => _AlatScreenState();
}

class _AlatScreenState extends State<AdminPeminjamScreen> {
  final supabase = Supabase.instance.client;

  String selectedCategory = "Kategori";
  String searchQuery = ""; // ================= SEARCH STATE =================

  // ================= DROPDOWN OVERLAY =================
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  // ================= DATA =================
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

    setState(() => kategoriList = response);
  }

  // ================= FETCH ALAT =================
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

  @override
  void initState() {
    super.initState();
    fetchKategori();
    fetchAlat();
  }

  @override
  void dispose() {
    _removeDropdown();
    super.dispose();
  }

  // ================= FILTER =================
  List get alatFiltered {
    List filtered = alatList;

    // Filter by category
    if (selectedCategory != "Semua" && selectedCategory != "Kategori") {
      filtered = filtered.where((alat) {
        return alat["kategori"]?["nama_kategori"] == selectedCategory;
      }).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((alat) {
        final namaAlat = (alat["nama_alat"] ?? "").toString().toLowerCase();
        return namaAlat.contains(searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
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
          Navigator.pushNamed(context, '/adminkeranjang', arguments: keranjang);
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

      // ================= BODY =================
      body: SafeArea(
        child: Column(
          children: [
            const Header(),
            const SizedBox(height: 16),
            _searchSection(),
            const SizedBox(height: 12),
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

  // ================= SEARCH & DROPDOWN =================
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

          // SEARCH
          TextField(
            onChanged: (value) {
              setState(() {
                searchQuery =
                    value; // ================= UPDATE QUERY =================
              });
            },
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // DROPDOWN KATEGORI
          CompositedTransformTarget(
            link: _layerLink,
            child: InkWell(
              onTap: _toggleDropdown,
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 14),
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
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= OVERLAY DROPDOWN =================
  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlay();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _removeDropdown();
    }
  }

  OverlayEntry _createOverlay() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: 170,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: const Offset(0, 42),
          showWhenUnlinked: false,
          child: Material(
            elevation: 6,
            child: Container(
              decoration: BoxDecoration(color: Colors.white),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dropdownItem("Semua"),
                  ...kategoriList.map((k) => _dropdownItem(k["nama_kategori"])),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dropdownItem(String title) {
    return InkWell(
      onTap: () {
        setState(() => selectedCategory = title);
        _removeDropdown();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(title, style: GoogleFonts.poppins(fontSize: 13)),
        ),
      ),
    );
  }

  void _removeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // ================= GRID =================
  // ================= GRID =================
  Widget _gridAlat() {
    final filteredAlat = alatFiltered;

    if (filteredAlat.isEmpty) {
      return const Center(
        child: Text(
          "Data alat kosong",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        itemCount: filteredAlat.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) {
          final alat = filteredAlat[index];
          return _alatCard(alat);
        },
      ),
    );
  }

  // ================= CARD =================
  Widget _alatCard(Map alat) {
    final String namaAlat = alat["nama_alat"];
    final int stok = alat["stok"] ?? 0;
    final String spesifikasi = alat["spesifikasi_alat"] ?? "";
    final bool sudahDiKeranjang = keranjang.any(
      (item) => item["nama_alat"] == namaAlat,
    );

    return InkWell(
      onTap: sudahDiKeranjang
          ? null
          : () {
              setState(() {
                keranjang.add({
                  "id_alat": alat["id_alat"],
                  "nama_alat": namaAlat,
                  "stok": stok,
                  "spesifikasi_alat": spesifikasi,
                  "gambar_alat": alat["gambar_alat"],
                  "jumlah": 1,
                });
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("$namaAlat ditambahkan ke keranjang")),
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
                image:
                    alat["gambar_alat"] != null &&
                        alat["gambar_alat"].toString().isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(alat["gambar_alat"]),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
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
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "Spesifikasi : $spesifikasi",
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
