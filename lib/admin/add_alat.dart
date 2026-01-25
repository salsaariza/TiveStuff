import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/header_back.dart';
import '../widgets/nav_admin.dart';

class TambahAlatScreen extends StatefulWidget {
  const TambahAlatScreen({super.key});

  @override
  State<TambahAlatScreen> createState() => _TambahAlatScreenState();
}

class _TambahAlatScreenState extends State<TambahAlatScreen> {
  final OutlineInputBorder _border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: BorderSide(color: Colors.grey.shade400),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),

      // ===== NAVBAR =====
      bottomNavigationBar: AppBottomNav(currentIndex: 1, onTap: (index) {}),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Header(),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Tambah Alat",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _formCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= FORM CARD =================
  Widget _formCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _imagePicker(),
          const SizedBox(height: 20),

          _input("Nama Alat", "Nama alat"),
          const SizedBox(height: 14),

          _input("Kategori", "Umum"),
          const SizedBox(height: 14),

          _input("Stok", "10", keyboard: TextInputType.number),
          const SizedBox(height: 14),

          _input("Spesifikasi", "Spesifikasi"),
          const SizedBox(height: 14),

          _input("Spesifikasi", "Spesifikasi"),
          const SizedBox(height: 24),

          _actionButtons(),
        ],
      ),
    );
  }

  // ================= IMAGE PICKER =================
  Widget _imagePicker() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade400, width: 1.5),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C6D7A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () {},
          child: Text(
            "Tambahkan Gambar",
            style: GoogleFonts.poppins(fontSize: 13, 
            color: Colors.white,
            fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ================= INPUT FIELD =================
  Widget _input(
    String label,
    String hint, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextField(
          keyboardType: keyboard,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            enabledBorder: _border,
            focusedBorder: _border,
          ),
        ),
      ],
    );
  }

  // ================= BUTTONS =================
  Widget _actionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide(color: Colors.grey.shade400),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Batal", style: GoogleFonts.poppins(fontSize: 13)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C6D7A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {},
            child: Text("Konfirmasi", style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white,
            )),
          ),
        ),
      ],
    );
  }
}
