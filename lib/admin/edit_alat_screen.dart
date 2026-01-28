import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/header_back.dart';
import 'package:tivestuff1/models/alat_models.dart';

class EditAlatScreen extends StatefulWidget {
  final AlatModel alat;

  const EditAlatScreen({super.key, required this.alat});

  @override
  State<EditAlatScreen> createState() => _EditAlatScreenState();
}

class _EditAlatScreenState extends State<EditAlatScreen> {
  final supabase = Supabase.instance.client;

  final OutlineInputBorder _border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
  );

  File? selectedImage;
  Uint8List? selectedWebImage;
  String? imageUrlLama;

  final namaController = TextEditingController();
  final hargaController = TextEditingController();
  final stokController = TextEditingController();
  final spesifikasiController = TextEditingController();

  List<Map<String, dynamic>> kategoriList = [];
  Map<String, dynamic>? selectedKategori;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _isiDataAwal();
    fetchKategori();
  }

  /// ================= ISI DATA AWAL =================
  void _isiDataAwal() {
    namaController.text = widget.alat.nama;
    hargaController.text = widget.alat.harga.toString();
    stokController.text = widget.alat.stok.toString();
    spesifikasiController.text = widget.alat.spesifikasi ?? '';
    imageUrlLama = widget.alat.gambar;
  }

  /// ================= FETCH KATEGORI =================
  Future<void> fetchKategori() async {
    final data = await supabase
        .from('kategori')
        .select()
        .filter('delete_at', 'is', null)
        .order('nama_kategori');

    kategoriList = List<Map<String, dynamic>>.from(data);

    selectedKategori = kategoriList.firstWhere(
      (k) => k['id_kategori'] == widget.alat.idKategori,
      orElse: () => kategoriList.first,
    );

    setState(() {});
  }

  /// ================= PICK IMAGE =================
  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null) return;

    final file = result.files.single;

    setState(() {
      if (kIsWeb) {
        selectedWebImage = file.bytes;
        selectedImage = null;
      } else {
        selectedImage = File(file.path!);
        selectedWebImage = null;
      }
    });
  }

  /// ================= SUBMIT EDIT =================
  Future<void> submitEdit() async {
    if (namaController.text.isEmpty ||
        hargaController.text.isEmpty ||
        selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama, Kategori, dan Harga wajib diisi")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String? imageUrl = imageUrlLama;

      if ((kIsWeb && selectedWebImage != null) ||
          (!kIsWeb && selectedImage != null)) {
        final fileName = 'alat_${DateTime.now().millisecondsSinceEpoch}.png';

        if (kIsWeb) {
          await supabase.storage.from('alat_image').uploadBinary(
                fileName,
                selectedWebImage!,
                fileOptions: const FileOptions(contentType: 'image/png'),
              );
        } else {
          await supabase.storage.from('alat_image').upload(
                fileName,
                selectedImage!,
                fileOptions: const FileOptions(contentType: 'image/png'),
              );
        }

        imageUrl =
            supabase.storage.from('alat_image').getPublicUrl(fileName);
      }

      await supabase.from('alat').update({
        'nama_alat': namaController.text,
        'id_kategori': selectedKategori!['id_kategori'],
        'harga_alat': double.parse(hargaController.text),
        'stok': int.tryParse(stokController.text) ?? 0,
        'spesifikasi_alat': spesifikasiController.text,
        'gambar_alat': imageUrl,
      }).eq('id_alat', widget.alat.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alat berhasil diperbarui")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("ERROR EDIT ALAT: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengedit alat")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
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
                  "Edit Alat",
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

  /// ================= FORM CARD =================
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
          _input("Nama Alat", "Masukkan nama", controller: namaController),
          const SizedBox(height: 14),
          _kategoriDropdown(),
          const SizedBox(height: 14),
          _input(
            "Harga",
            "Masukkan harga",
            controller: hargaController,
            keyboard: TextInputType.number,
          ),
          const SizedBox(height: 14),
          _input(
            "Stok",
            "Masukkan stok",
            controller: stokController,
            keyboard: TextInputType.number,
          ),
          const SizedBox(height: 14),
          _input(
            "Spesifikasi",
            "Masukkan spesifikasi",
            controller: spesifikasiController,
          ),
          const SizedBox(height: 14),
          _actionButtons(),
        ],
      ),
    );
  }

  /// ================= IMAGE =================
  Widget _buildImagePreview() {
    if (kIsWeb && selectedWebImage != null) {
      return Image.memory(selectedWebImage!, fit: BoxFit.cover);
    }
    if (!kIsWeb && selectedImage != null) {
      return Image.file(selectedImage!, fit: BoxFit.cover);
    }
    if (imageUrlLama != null) {
      return Image.network(imageUrlLama!, fit: BoxFit.cover);
    }

    return Center(
      child: Text(
        "Belum ada gambar",
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  Widget _imagePicker() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade400, width: 1.5),
            color: Colors.grey.shade100,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _buildImagePreview(),
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
          onPressed: pickImage,
          child: Text(
            "Ganti Gambar",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// ================= KATEGORI =================
  Widget _kategoriDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Kategori",
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400, width: 1.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: DropdownButton<Map<String, dynamic>>(
            isExpanded: true,
            underline: const SizedBox(),
            value: selectedKategori,
            items: kategoriList.map((kategori) {
              return DropdownMenuItem<Map<String, dynamic>>(
                value: kategori,
                child: Text(
                  kategori['nama_kategori'],
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedKategori = value;
              });
            },
          ),
        ),
      ],
    );
  }

  /// ================= INPUT =================
  Widget _input(
    String label,
    String hint, {
    TextEditingController? controller,
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
          controller: controller,
          keyboardType: keyboard,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(fontSize: 13),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: _border,
            focusedBorder: _border,
          ),
        ),
      ],
    );
  }

  /// ================= BUTTONS =================
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
            onPressed: () => Navigator.pop(context),
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
            onPressed: isLoading ? null : submitEdit,
            child: isLoading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  )
                : Text(
                    "Konfirmasi",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    namaController.dispose();
    hargaController.dispose();
    stokController.dispose();
    spesifikasiController.dispose();
    super.dispose();
  }
}
