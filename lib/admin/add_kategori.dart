import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/header_back.dart';
import '../widgets/nav_admin.dart';

class KategoriScreen extends StatefulWidget {
  const KategoriScreen({super.key});

  @override
  State<KategoriScreen> createState() => _KategoriScreenState();
}

class _KategoriScreenState extends State<KategoriScreen> {
  final List<String> categories = [
    "Kelistrikan",
    "Diagnostik",
  ];

  final TextEditingController _kategoriController = TextEditingController();

  @override
  void dispose() {
    _kategoriController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),

      // ================= NAVBAR =================
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        },
      ),

      // ================= BODY =================
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Header(),
            const SizedBox(height: 20),

            // TITLE
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

            // TAMBAH KATEGORI
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

            // LIST
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return _categoryCard(categories[index], index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CARD =================
  Widget _categoryCard(String title, int index) {
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
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // EDIT
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            onPressed: () => _showKategoriDialog(
              isEdit: true,
              index: index,
              initialValue: title,
            ),
          ),

          // DELETE
          IconButton(
            icon: const Icon(Icons.delete, size: 18),
            onPressed: () => _confirmDelete(index),
          ),
        ],
      ),
    );
  }

  // ================= ADD / EDIT DIALOG =================
  void _showKategoriDialog({
    bool isEdit = false,
    int? index,
    String initialValue = "",
  }) {
    _kategoriController.text = initialValue;

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
                    "Tambah Kategori",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  "Nama Kategori",
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                const SizedBox(height: 6),

                TextField(
                  controller: _kategoriController,
                  decoration: InputDecoration(
                    hintText: "Masukkan Kategori",
                    hintStyle: GoogleFonts.poppins(fontSize: 12),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
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
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Batal",
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
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

                          setState(() {
                            if (isEdit && index != null) {
                              categories[index] =
                                  _kategoriController.text;
                            } else {
                              categories.add(_kategoriController.text);
                            }
                          });

                          Navigator.pop(context);
                        },
                        child: Text(
                          "Konfirmasi",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white,
                          ),
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

  // ================= DELETE CONFIRM =================
  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Hapus Kategori",
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          content: Text(
            "Yakin ingin menghapus kategori ini?",
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Batal",
                style: GoogleFonts.poppins(),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  categories.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: Text(
                "Hapus",
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
