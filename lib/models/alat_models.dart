class AlatModel {
  final int id;
  final String nama;
  final int stok;
  final String? gambar;
  final int? idKategori;

  AlatModel({
    required this.id,
    required this.nama,
    required this.stok,
    this.gambar,
    this.idKategori,
  });

  factory AlatModel.fromMap(Map<String, dynamic> map) {
    return AlatModel(
      id: map['id_alat'],
      nama: map['nama_alat'],
      stok: map['stok'] ?? 0,
      gambar: map['gambar_alat'],
      idKategori: map['id_kategori'],
    );
  }
}