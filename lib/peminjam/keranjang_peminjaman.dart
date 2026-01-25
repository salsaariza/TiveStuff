import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tivestuff1/widgets/back_peminjam.dart';
import 'package:tivestuff1/widgets/nav_peminjam.dart';

class KeranjangPeminjamanScreen extends StatefulWidget {
  const KeranjangPeminjamanScreen({Key? key}) : super(key: key);

  @override
  State<KeranjangPeminjamanScreen> createState() =>
      _KeranjangPeminjamanScreenState();
}

class _KeranjangPeminjamanScreenState
    extends State<KeranjangPeminjamanScreen> {
  TextEditingController tanggalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // ================= TERIMA DATA KERANJANG =================
    final List<String> keranjang =
        (ModalRoute.of(context)?.settings.arguments ??
            <String>[]) as List<String>;

    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            const BackPeminjam(),

            /// CONTENT
            Expanded(
              child: keranjang.isEmpty
                  ? _keranjangKosong()
                  : _keranjangAda(keranjang),
            ),
          ],
        ),
      ),

      /// NAVBAR
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
    );
  }

  // ================= TAMPILAN KERANJANG KOSONG =================
  Widget _keranjangKosong() {
    return Center(
      child: Text(
        "Keranjang kosong",
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ================= TAMPILAN KERANJANG ADA =================
  Widget _keranjangAda(List<String> keranjang) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// JUDUL
          Text(
            "Keranjang Peminjaman",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),

          /// LIST ITEM
          ...keranjang.map(
            (alat) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildItemCard(
                nama: alat,
                jumlah: "1",
              ),
            ),
          ),

          const SizedBox(height: 18),

          /// TANGGAL PENGEMBALIAN
          Text(
            "Tanggal Pengembalian",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),

          TextField(
            controller: tanggalController,
            readOnly: true,
            decoration: InputDecoration(
              hintText: "dd/mm/yyyy",
              hintStyle: GoogleFonts.poppins(fontSize: 12),
              suffixIcon:
                  const Icon(Icons.calendar_today, size: 18),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );

              if (picked != null) {
                setState(() {
                  tanggalController.text =
                      "${picked.day}/${picked.month}/${picked.year}";
                });
              }
            },
          ),

          const SizedBox(height: 24),

          /// BUTTON AJUKAN (FIX NAVIGASI)
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/pengajuanpeminjam');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6E6E7A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                "Ajukan Peminjaman",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= CARD ITEM =================
  Widget _buildItemCard({
    required String nama,
    required String jumlah,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  jumlah,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.delete_outline,
            size: 20,
            color: Colors.grey.shade600,
          ),
        ],
      ),
    );
  }
}
