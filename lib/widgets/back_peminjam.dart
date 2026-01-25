import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BackPeminjam extends StatelessWidget {
  const BackPeminjam({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: width > 600 ? 32 : 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF6C6D7A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= BACK BUTTON =================
          Padding(
            padding: const EdgeInsets.only(
              top: 6,   // geser ke bawah
              right: 12,
            ),
            child: InkWell(
              onTap: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/dashboardpeminjam',
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),

          // ================= TEXT =================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "TiveStuff",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Hello, Peminjam",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
