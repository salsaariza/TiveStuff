import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tivestuff1/widgets/back_peminjam.dart';

class KeranjangPeminjamanScreen extends StatefulWidget {
  const KeranjangPeminjamanScreen({Key? key}) : super(key: key);

  @override
  State<KeranjangPeminjamanScreen> createState() =>
      _KeranjangPeminjamanScreenState();
}

class _KeranjangPeminjamanScreenState
    extends State<KeranjangPeminjamanScreen> {
  TextEditingController tanggalPinjamController = TextEditingController();
  TextEditingController tanggalController = TextEditingController();

  List<Map<String, dynamic>> keranjang = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ambil data dari AlatPeminjamScreen
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is List<Map<String, dynamic>>) {
      keranjang = List<Map<String, dynamic>>.from(args);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: SafeArea(
        child: Column(
          children: [
            const BackPeminjam(),
            Expanded(
              child: keranjang.isEmpty
                  ? _keranjangKosong()
                  : _keranjangAda(),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _keranjangAda() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Keranjang Peminjaman",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),

          // LIST ITEM
          ...keranjang.map(
            (alat) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildItemCard(
                nama: alat['nama_alat'] ?? '-',
                jumlah: "1",
                onDelete: () {
                  setState(() {
                    keranjang.remove(alat);
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 18),

          // TANGGAL PEMINJAMAN
          Text(
            "Tanggal Peminjaman",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: tanggalPinjamController,
            readOnly: true,
            decoration: InputDecoration(
              hintText: "dd/mm/yyyy",
              hintStyle: GoogleFonts.poppins(fontSize: 12),
              suffixIcon: const Icon(Icons.calendar_today, size: 18),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                  tanggalPinjamController.text =
                      "${picked.day}/${picked.month}/${picked.year}";
                });
              }
            },
          ),

          const SizedBox(height: 18),

          // TANGGAL PENGEMBALIAN
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
              suffixIcon: const Icon(Icons.calendar_today, size: 18),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Tambahkan logic submit ke supabase
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

  Widget _buildItemCard({
    required String nama,
    required String jumlah,
    required VoidCallback onDelete,
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
          // Kotak placeholder (sebelumnya untuk gambar)
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
          // Tombol Hapus
          InkWell(
            onTap: onDelete,
            child: Icon(
              Icons.delete_outline,
              size: 20,
              color: Colors.red.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
