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

  /// ================= DROPDOWN KELAS =================
  List<String> listKelas = [];
  String? selectedKelas;
  bool loadingKelas = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args != null && args is List<Map<String, dynamic>>) {
      keranjang = List<Map<String, dynamic>>.from(args);
    }

    fetchKelas();
  }

  /// ================= FETCH DATA KELAS =================
  Future<void> fetchKelas() async {
    try {
      final res = await supabase.from('peminjaman').select('tingkatan_kelas');

      final temp = res
          .map((e) => e['tingkatan_kelas'].toString())
          .toSet()
          .toList();

      setState(() {
        listKelas = temp;
        loadingKelas = false;
      });
    } catch (e) {
      debugPrint("ERROR FETCH KELAS: $e");
      setState(() => loadingKelas = false);
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

          loadingKelas
              ? const Center(child: CircularProgressIndicator())
              : Container(
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
          Text(
            "Tanggal Peminjaman",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          _buildTanggalField(tanggalPinjamController),

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

      if (keranjang.first['id_alat'] == null) {
        _showSnack("ID alat tidak valid");
        return;
      }

      final tanggalPinjam = _parseTanggal(tanggalPinjamController.text);
      final tanggalKembali = _parseTanggal(tanggalController.text);

      /// ================= INSERT PEMINJAMAN =================
      final peminjaman = await supabase
          .from('peminjaman')
          .insert({
            'id_user': user.id,
            'id_alat': keranjang.first['id_alat'],
            'tingkatan_kelas': selectedKelas,
            'tanggal_pinjam': tanggalPinjam.toIso8601String(),
            'tanggal_kembali': tanggalKembali.toIso8601String(),
            'status_peminjaman': 'menunggu',
            'created_by': user.id,
          })
          .select('id_peminjaman')
          .single();

      final int idPeminjaman = peminjaman['id_peminjaman'];

      /// ================= INSERT DETAIL =================
      for (final alat in keranjang) {
        await supabase.from('detail_peminjaman').insert({
          'id_peminjaman': idPeminjaman,
          'id_alat': alat['id_alat'],
          'jumlah': 1,
          'id_user': user.id,
          'created_by': user.id,
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
