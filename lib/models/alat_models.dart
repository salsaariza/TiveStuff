class AlatModel {
  final int id;
  final String nama;
  final int stok;
  final double harga;
  final String? spesifikasi;
  final String? gambar;
  final int idKategori;

  AlatModel({
    required this.id,
    required this.nama,
    required this.stok,
    required this.harga,
    this.spesifikasi,
    this.gambar,
    required this.idKategori,
  });

  factory AlatModel.fromMap(Map<String, dynamic> map) {
    return AlatModel(
      id: map['id_alat'],
      nama: map['nama_alat'] ?? '',
      stok: map['stok'] ?? 0,
      harga: (map['harga_alat'] ?? 0).toDouble(),
      spesifikasi: map['spesifikasi_alat'],
      gambar: map['gambar_alat'],
      idKategori: map['id_kategori'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_alat': id,
      'nama_alat': nama,
      'stok': stok,
      'harga_alat': harga,
      'spesifikasi_alat': spesifikasi,
      'gambar_alat': gambar,
      'id_kategori': idKategori,
    };
  }
}
