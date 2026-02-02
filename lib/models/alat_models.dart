class AlatModel {
  final int id;
  final String nama;
  final int idKategori;
  final int stok;
  final double harga;
  final String? spesifikasi;
  final String? gambar;
  final DateTime? deleteAt; // untuk soft delete

  AlatModel({
    required this.id,
    required this.nama,
    required this.idKategori,
    required this.stok,
    required this.harga,
    this.spesifikasi,
    this.gambar,
    this.deleteAt,
  });

  factory AlatModel.fromMap(Map<String, dynamic> map) {
    return AlatModel(
      id: map['id_alat'],
      nama: map['nama_alat'],
      idKategori: map['id_kategori'],
      stok: map['stok'],
      harga: (map['harga_alat'] as num).toDouble(),
      spesifikasi: map['spesifikasi_alat'],
      gambar: map['gambar_alat'],
      deleteAt: map['delete_at'] != null ? DateTime.tryParse(map['delete_at']) : null,
    );
  }
}
