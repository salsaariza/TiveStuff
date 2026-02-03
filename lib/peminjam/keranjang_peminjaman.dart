import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tivestuff1/widgets/back_peminjam.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KeranjangPeminjamanScreen extends StatefulWidget {
  const KeranjangPeminjamanScreen({Key? key}) : super(key: key);

  @override
  State<KeranjangPeminjamanScreen> createState() =>
      _KeranjangPeminjamanScreenState();
}

class _KeranjangPeminjamanScreenState extends State<KeranjangPeminjamanScreen> {
  final supabase = Supabase.instance.client;

  final TextEditingController tanggalPinjamController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();

  List<Map<String, dynamic>> keranjang = [];

  /// ================= DROPDOWN KELAS (ENUM SUPABASE) =================
  final List<String> listKelas = [
    'X TO 1',
    'X TO 2',
    'X TO 3',
    'X TO 4',
    'X TO 5',
    'X TO 6',
    'X TO 7',
    'XI TKR 1',
    'XI TKR 2',
    'XI TKR 3',
    'XI TKR 4',
    'XI TKR 5',
    'XI TKR 6',
    'XII TKR 1',
    'XII TKR 2',
    'XII TKR 3',
    'XII TKR 4',
    'XII TKR 5',
    'XII TKR 6',
  ];

  String? selectedKelas;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

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
              child: keranjang.isEmpty ? _keranjangKosong() : _keranjangAda(),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= UI =================

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
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),

          /// LIST ITEM
          ...keranjang.asMap().entries.map((entry) {
            final index = entry.key;
            final alat = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildItemCard(
                nama: alat['nama_alat'] ?? '-',
                jumlah: '1',
                onDelete: () {
                  setState(() {
                    keranjang.removeAt(index);
                  });
                },
              ),
            );
          }).toList(),

          const SizedBox(height: 18),

          /// DROPDOWN KELAS
          Text(
            "Pilih Kelas",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedKelas,
                hint: Text(
                  "Pilih Kelas",
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                isExpanded: true,
                items: listKelas.map((kelas) {
                  return DropdownMenuItem(
                    value: kelas,
                    child: Text(
                      kelas,
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedKelas = value;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 18),

          /// TANGGAL PEMINJAMAN
          Text("Tanggal Peminjaman", style: GoogleFonts.poppins(fontSize: 12)),
          const SizedBox(height: 6),
          _buildTanggalField(tanggalPinjamController),

          const SizedBox(height: 18),

          /// TANGGAL PENGEMBALIAN
          Text(
            "Tanggal Pengembalian",
            style: GoogleFonts.poppins(fontSize: 12),
          ),
          const SizedBox(height: 6),
          _buildTanggalField(tanggalController),

          const SizedBox(height: 24),

          /// BUTTON
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: _ajukanPeminjaman,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6E6E7A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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

  /// ================= LOGIC =================

  DateTime _parseTanggal(String tanggal) {
    final p = tanggal.split('/');
    return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
  }

  Future<void> _ajukanPeminjaman() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        _showSnack("User belum login");
        return;
      }

      if (keranjang.isEmpty) {
        _showSnack("Keranjang kosong");
        return;
      }

      if (selectedKelas == null) {
        _showSnack("Kelas belum dipilih");
        return;
      }

      if (tanggalPinjamController.text.isEmpty ||
          tanggalController.text.isEmpty) {
        _showSnack("Tanggal belum diisi");
        return;
      }

      final tanggalPinjam = _parseTanggal(tanggalPinjamController.text);
      final tanggalKembali = _parseTanggal(tanggalController.text);

      // Ambil ID alat pertama untuk di tabel peminjaman
      final int? firstAlatId = keranjang.isNotEmpty
          ? keranjang.first['id_alat']
          : null;

      /// INSERT PEMINJAMAN
      final peminjaman = await supabase
          .from('peminjaman')
          .insert({
            'id_user': user.id,
            'id_alat': firstAlatId, // <-- ini yang masuk ke tabel peminjaman
            'tingkatan_kelas': selectedKelas,
            'tanggal_pinjam': tanggalPinjam.toIso8601String(),
            'tanggal_kembali': tanggalKembali.toIso8601String(),
            'status_peminjaman': 'menunggu',
          })
          .select('id_peminjaman')
          .single();

      final int idPeminjaman = peminjaman['id_peminjaman'];

      /// INSERT DETAIL
      for (final alat in keranjang) {
        await supabase.from('detail_peminjaman').insert({
          'id_peminjaman': idPeminjaman,
          'id_alat': alat['id_alat'],
          'jumlah': 1,
        });
      }

      if (!mounted) return;

      _showSnack("Peminjaman berhasil diajukan");
      Navigator.pushReplacementNamed(context, '/pengajuanpeminjam');
    } catch (e) {
      debugPrint("ERROR PEMINJAMAN: $e");
      _showSnack("Gagal menyimpan data");
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildTanggalField(TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        hintText: "dd/MM/yyyy",
        suffixIcon: const Icon(Icons.calendar_today, size: 18),
        filled: true,
        fillColor: Colors.white,
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
          controller.text =
              "${picked.day.toString().padLeft(2, '0')}/"
              "${picked.month.toString().padLeft(2, '0')}/"
              "${picked.year}";
        }
      },
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
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama, style: GoogleFonts.poppins(fontSize: 12)),
                Text(jumlah, style: GoogleFonts.poppins(fontSize: 11)),
              ],
            ),
          ),
          InkWell(
            onTap: onDelete,
            child: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
