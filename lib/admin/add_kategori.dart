import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/header_back.dart';

class KategoriScreen extends StatefulWidget {
  const KategoriScreen({super.key});

  @override
  State<KategoriScreen> createState() => _KategoriScreenState();
}

class _KategoriScreenState extends State<KategoriScreen> {
  final supabase = Supabase.instance.client;

  final TextEditingController _kategoriController = TextEditingController();

  bool isLoading = true;

  List<Map<String, dynamic>> kategoriList = [];

  @override
  void initState() {
    super.initState();
    fetchKategori();
  }

  @override
  void dispose() {
    _kategoriController.dispose();
    super.dispose();
  }

  /// ================= FETCH =================
  Future<void> fetchKategori() async {
    setState(() => isLoading = true);

    try {
      final response = await supabase
          .from('kategori')
          .select()
          .filter('delete_at', 'is', null)
          .order('nama_kategori');

      setState(() {
        kategoriList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint("ERROR FETCH KATEGORI: $e");
    }

    if (mounted) setState(() => isLoading = false);
  }

  /// ================= ADD =================
  Future<void> addKategori(String nama) async {
    await supabase.from('kategori').insert({
      'nama_kategori': nama,
    });
    await fetchKategori();
    Navigator.pop(context);
    Navigator.pop(context, true); // balik ke AlatScreen
  }

  /// ================= UPDATE =================
  Future<void> updateKategori(int id, String nama) async {
    await supabase
        .from('kategori')
        .update({'nama_kategori': nama})
        .eq('id_kategori', id);

    await fetchKategori();
    Navigator.pop(context);
    Navigator.pop(context, true);
  }

  /// ================= DELETE  =================
  Future<void> deleteKategori(int id) async {
  try {
    await supabase
        .from('kategori')
        .delete() 
        .eq('id_kategori', id);

    await fetchKategori();
  } catch (e) {
    debugPrint("ERROR DELETE KATEGORI: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),

      // ================= BODY =================
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Header(),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Kategori",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _showKategoriDialog(),
                child: Text(
                  "Tambah Kategori",
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: kategoriList.length,
                      itemBuilder: (context, index) {
                        final kategori = kategoriList[index];
                        return _categoryCard(kategori);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= CARD =================
  Widget _categoryCard(Map<String, dynamic> kategori) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              kategori['nama_kategori'],
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            onPressed: () => _showKategoriDialog(
              isEdit: true,
              kategori: kategori,
            ),
          ),

          IconButton(
            icon: const Icon(Icons.delete, size: 18),
            onPressed: () => _confirmDelete(kategori['id_kategori']),
          ),
        ],
      ),
    );
  }

  /// ================= ADD / EDIT =================
  void _showKategoriDialog({
    bool isEdit = false,
    Map<String, dynamic>? kategori,
  }) {
    _kategoriController.text =
        isEdit ? kategori!['nama_kategori'] : "";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    isEdit ? "Edit Kategori" : "Tambah Kategori",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text("Nama Kategori",
                    style: GoogleFonts.poppins(fontSize: 12)),
                const SizedBox(height: 6),

                TextField(
                  controller: _kategoriController,
                  decoration: InputDecoration(
                    hintText: "Masukkan Kategori",
                    hintStyle: GoogleFonts.poppins(fontSize: 12),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Batal",
                            style: GoogleFonts.poppins(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C6D7A),
                        ),
                        onPressed: () {
                          if (_kategoriController.text.isEmpty) return;

                          if (isEdit) {
                            updateKategori(
                              kategori!['id_kategori'],
                              _kategoriController.text,
                            );
                          } else {
                            addKategori(_kategoriController.text);
                          }
                        },
                        child: Text(
                          "Konfirmasi",
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ================= DELETE =================
  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              Text("Hapus Kategori", style: GoogleFonts.poppins()),
          content: Text("Yakin ingin menghapus kategori ini?",
              style: GoogleFonts.poppins(fontSize: 13)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal", style: GoogleFonts.poppins()),
            ),
            TextButton(
              onPressed: () {
                deleteKategori(id);
                Navigator.pop(context);
              },
              child: Text("Hapus",
                  style:
                      GoogleFonts.poppins(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
