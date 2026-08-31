class Mahasiswa {
  Mahasiswa({required this.nama, required this.aktif});
  final String nama;
  final bool aktif;
  String status() => aktif ? '$nama aktif' : '$nama tidak aktif';
}

String sapa(String nama, int semester) => 'Halo $nama, semester $semester';

void main() {
    String nama = 'Alyaa';
    int semester = 4;
    // String namaPanggilan = 'coy';

    final bool aktif = true;
    print(sapa(nama,semester));
    
    final mahasiswa = Mahasiswa(nama: nama, aktif:aktif);
    print(mahasiswa.status());
    
    String? namaPanggilan;
    print(namaPanggilan?.toUpperCase() ?? 'BELUM DIISI');
}