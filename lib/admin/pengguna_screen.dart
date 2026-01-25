import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/header_back.dart';
import '../widgets/nav_admin.dart';

class PenggunaScreen extends StatefulWidget {
  const PenggunaScreen({super.key});

  @override
  State<PenggunaScreen> createState() => _PenggunaScreenState();
}

class _PenggunaScreenState extends State<PenggunaScreen> {
  final List<Map<String, String>> users = [
    {
      "name": "Ajeng Chalista",
      "email": "ajengrent@gmail.com",
    },
    {
      "name": "Richo Ferdinand",
      "email": "richorent@gmail.com",
    },
    {
      "name": "Azura Selly",
      "email": "azurastaff@gmail.com",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),

      // ================= FLOATING BUTTON =================
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C6D7A),
        onPressed: () {
        },
        child: const Icon(Icons.person_add, color: Colors.white),
      ),

      // ================= NAVBAR =================
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2, // PENGGUNA
        onTap: (index) {
          if (index == 2) return;

          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
          else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/riwayat');
          }
          else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/alat');
          }
          else if (index == 4) {
            Navigator.pushReplacementNamed(context, '/aktivitas');
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
                "Pengguna",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // SEARCH
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Cari Pengguna",
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

            // LIST USER
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return _userCard(
                    users[index]["name"]!,
                    users[index]["email"]!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= USER CARD =================
  Widget _userCard(String name, String email) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // DELETE
          IconButton(
            icon: const Icon(Icons.delete, size: 20),
            onPressed: () {
              // TODO: delete user
            },
          ),

          // EDIT
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () {
              // TODO: edit user
            },
          ),
        ],
      ),
    );
  }
}
