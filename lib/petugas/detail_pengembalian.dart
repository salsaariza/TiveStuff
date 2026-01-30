import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tivestuff1/widgets/back_petugas.dart';

class DetailPengembalianScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const DetailPengembalianScreen({
    super.key,
    required this.data,
  });

  @override
  State<DetailPengembalianScreen> createState() =>
      _DetailPengembalianScreenState();
}

class _DetailPengembalianScreenState extends State<DetailPengembalianScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  String kondisi = 'baik';
  bool isLoading = false;

  Future<void> simpanPengembalian() async {
    try {
      setState(() => isLoading = true);

      await supabase
          .from('pengembalian')
          .update({
            'kondisi_alat': kondisi,
          })
          .eq('id_pengembalian', widget.data['id_pengembalian']);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
    
            const HeaderPetugas(),

            // ================= CONTENT =================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== TITLE =====
                    Text(
                      'Detail Pengembalian',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ===== CARD INFO =====
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.data['kode'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _rowInfo('Nama', widget.data['nama']),
                          _rowInfo('Kelas', widget.data['kelas']),
                          _rowInfo('Alat', widget.data['alat']),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_month, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'Pengembalian : ${widget.data['tanggal_kembali'].toString().substring(0, 10)}',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ===== KONDISI =====
                    Text(
                      'Kondisi Alat',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: kondisi,
                      items: const [
                        DropdownMenuItem(
                          value: 'baik',
                          child: Text('Baik'),
                        ),
                        DropdownMenuItem(
                          value: 'rusak',
                          child: Text('Rusak'),
                        ),
                      ],
                      onChanged: (v) => setState(() => kondisi = v!),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ===== BUTTON =====
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : simpanPengembalian,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F7F2F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Konfirmasi Pengembalian',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HELPER =================
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: child,
    );
  }

  Widget _rowInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '$label : $value',
        style: GoogleFonts.poppins(fontSize: 12),
      ),
    );
  }
}
