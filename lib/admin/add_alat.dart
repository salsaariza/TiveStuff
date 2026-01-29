import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/header_back.dart';
import 'package:tivestuff1/models/alat_models.dart';

class TambahAlatScreen extends StatefulWidget {
  final AlatModel? alat;

  const TambahAlatScreen({super.key, this.alat});

  @override
  State<TambahAlatScreen> createState() => _TambahAlatScreenState();
}

class _TambahAlatScreenState extends State<TambahAlatScreen> {
  final OutlineInputBorder _border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: BorderSide(color: Colors.grey.shade400),
  );

  final supabase = Supabase.instance.client;

  File? selectedImage;
  Uint8List? selectedWebImage;
  String? uploadedImageUrl;

  final TextEditingController namaController = TextEditingController();
  final TextEditingController stokController = TextEditingController();
  final TextEditingController spesifikasiController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();

  List<Map<String, dynamic>> kategoriList = [];
  Map<String, dynamic>? selectedKategori;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchKategori();
  }

  /// Ambil kategori dari Supabase
  Future<void> fetchKategori() async {
    try {
      final response = await supabase
          .from('kategori')
          .select()
          .filter('delete_at', 'is', null)
          .order('nama_kategori');

      setState(() {
        kategoriList = (response as List).cast<Map<String, dynamic>>();
      });
    } catch (e) {
      debugPrint('ERROR FETCH KATEGORI: $e');
    }
  }

  /// PICK IMAGE DARI LAPTOP
  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result == null) return;

    final file = result.files.single;

    setState(() {
      if (kIsWeb) {
        // ✅ WEB → gunakan bytes
        selectedWebImage = file.bytes;
        selectedImage = null;
      } else {
        // ✅ MOBILE/DESKTOP → gunakan path
        selectedImage = File(file.path!);
        selectedWebImage = null;
      }
    });
  }

  /// SUBMIT FORM KE SUPABASE
  Future<void> submitForm() async {
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
      String? imageUrl;

      /// =============================
      /// UPLOAD GAMBAR (JIKA ADA)
      /// =============================
      if ((kIsWeb && selectedWebImage != null) ||
          (!kIsWeb && selectedImage != null)) {
        final fileName = "alat_${DateTime.now().millisecondsSinceEpoch}.png";

        if (kIsWeb) {
          // ✅ WEB Upload
          await supabase.storage
              .from('alat_image')
              .uploadBinary(
                fileName,
                selectedWebImage!,
                fileOptions: const FileOptions(contentType: "image/png"),
              );
        } else {
          // ✅ MOBILE/DESKTOP Upload
          await supabase.storage
              .from('alat_image')
              .upload(
                fileName,
                selectedImage!,
                fileOptions: const FileOptions(contentType: "image/png"),
              );
        }

        // ✅ Ambil URL publik
        imageUrl = supabase.storage.from('alat_image').getPublicUrl(fileName);

        debugPrint("URL gambar berhasil: $imageUrl");
      }

      /// =============================
      /// INSERT DATA KE DATABASE
      /// =============================
      final response = await supabase.from('alat').insert({
        'nama_alat': namaController.text,
        'id_kategori': selectedKategori!['id_kategori'],
        'harga_alat': double.tryParse(hargaController.text) ?? 0,
        'spesifikasi_alat': spesifikasiController.text,
        'stok': int.tryParse(stokController.text) ?? 0,
        'gambar_alat': imageUrl,
      }).select();

      /// =============================
      /// BERHASIL
      /// =============================
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alat berhasil ditambahkan")),
      );

      // ✅ Kembali sambil kirim data baru
      Navigator.pop(context, response[0]);
    } catch (e) {
      debugPrint("ERROR ADD ALAT: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menambahkan alat: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// BUILD UI
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

  /// FORM CARD
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

  Widget _buildImagePreview() {
    // ✅ WEB Preview
    if (kIsWeb && selectedWebImage != null) {
      return Image.memory(selectedWebImage!, fit: BoxFit.cover);
    }

    // ✅ MOBILE/DESKTOP Preview
    if (!kIsWeb && selectedImage != null) {
      return Image.file(selectedImage!, fit: BoxFit.cover);
    }

    // ✅ Default jika belum pilih gambar
    return Center(
      child: Text(
        "Belum ada gambar",
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// IMAGE PICKER WIDGET
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

          /// PREVIEW GAMBAR
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
            "Tambahkan Gambar",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// DROPDOWN KATEGORI
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
            hint: Text(
              "Pilih kategori",
              style: GoogleFonts.poppins(fontSize: 13),
            ),
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

  /// INPUT FIELD
  Widget _input(
    String label,
    String hint, {
    TextInputType keyboard = TextInputType.text,
    TextEditingController? controller,
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

  /// ACTION BUTTONS
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
            onPressed: isLoading ? null : submitForm,
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
    stokController.dispose();
    spesifikasiController.dispose();
    hargaController.dispose();
    super.dispose();
  }
}
