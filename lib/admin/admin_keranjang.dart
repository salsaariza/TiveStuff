import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tivestuff1/widgets/header_back.dart';

class AdminKeranjang extends StatefulWidget {
  const AdminKeranjang({Key? key}) : super(key: key);

  @override
  State<AdminKeranjang> createState() => _KeranjangPeminjamanScreenState();
}

class _KeranjangPeminjamanScreenState extends State<AdminKeranjang> {
  final supabase = Supabase.instance.client;

  final TextEditingController tanggalPinjamController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();

  List<Map<String, dynamic>> keranjang = [];

  /// ================= STATE USER =================
  List<Map<String, dynamic>> userList = [];
  String? selectedUserId;
  Map<String, Map<String, dynamic>> userMap = {};

  bool loadingUsers = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args != null && args is List<Map<String, dynamic>>) {
      keranjang = List<Map<String, dynamic>>.from(args);
    }

    if (userList.isEmpty) {
      _fetchUsers();
    }
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await supabase
          .from('users')
          .select('id_user, username, role')
          .eq('role', 'peminjam')
          .order('username', ascending: true);

      final users = List<Map<String, dynamic>>.from(response);

      setState(() {
        userList = users;
        userMap = {for (var u in users) u['id_user'] as String: u};
        selectedUserId = users.isNotEmpty
            ? users.first['id_user'] as String
            : null;
        loadingUsers = false;
      });
    } catch (e) {
      debugPrint('ERROR FETCH USERS: $e');
      loadingUsers = false;
      _showSnack('Gagal memuat daftar peminjam');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: SafeArea(
        child: Column(
          children: [
            const Header(),
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
          ...keranjang.map((alat) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildItemCard(
                nama: alat['nama_alat'] ?? '-',
                jumlah: '1',
                onDelete: () {
                  setState(() {
                    keranjang.remove(alat);
                  });
                },
              ),
            );
          }),

          const SizedBox(height: 18),

          /// DROPDOWN PILIH USER
          Text(
            "Pilih Peminjam",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),

          loadingUsers
              ? const Center(child: CircularProgressIndicator())
              : DropdownButtonFormField<String>(
                  value: selectedUserId,
                  items: userList
                      .map(
                        (u) => DropdownMenuItem<String>(
                          value: u['id_user'] as String,
                          child: Text(
                            u['username'] ?? '-',
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedUserId = val;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

          const SizedBox(height: 18),

          /// TANGGAL
          Text("Tanggal Peminjaman", style: GoogleFonts.poppins(fontSize: 12)),
          const SizedBox(height: 6),
          _buildTanggalField(tanggalPinjamController),

          const SizedBox(height: 18),

          Text(
            "Tanggal Pengembalian",
            style: GoogleFonts.poppins(fontSize: 12),
          ),
          const SizedBox(height: 6),
          _buildTanggalField(tanggalController),

          const SizedBox(height: 24),

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
      if (selectedUserId == null) {
        _showSnack('Peminjam belum dipilih');
        return;
      }

      if (keranjang.isEmpty) {
        _showSnack('Keranjang kosong');
        return;
      }

      if (tanggalPinjamController.text.isEmpty ||
          tanggalController.text.isEmpty) {
        _showSnack('Tanggal belum diisi');
        return;
      }

      final tanggalPinjam = _parseTanggal(tanggalPinjamController.text);
      final tanggalKembali = _parseTanggal(tanggalController.text);

      for (final alat in keranjang) {
        await supabase.rpc(
          'ajukan_peminjaman_dengan_stok',
          params: {
            'p_id_user': selectedUserId,
            'p_id_alat': alat['id_alat'],
            'p_tanggal_pinjam': tanggalPinjam.toIso8601String(),
            'p_tanggal_kembali': tanggalKembali.toIso8601String(),
          },
        );
      }

      if (!mounted) return;

      _showSnack('Peminjaman berhasil diajukan');
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      debugPrint('ERROR PEMINJAMAN: $e');

      if (e.toString().contains('Stok alat habis')) {
        _showSnack('Stok alat sudah habis');
      } else {
        _showSnack('Gagal mengajukan peminjaman');
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
