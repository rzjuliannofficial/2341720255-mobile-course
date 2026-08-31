class Profile{
  Profile({this.nama, this.nim, this.email});

//urutan dibaca : 2
  //coba jika final dihapus dan kembali ke urutan 1, maka 
  //maka nama, nim dan email bisa diubah ditengah jalan
  
  final String? nama; //? digunakan agar nama null safety atau bisa bernilai null
  final int? nim;
  final String? email;

  String info() => 'Nama = $nama, \nNIM = $nim, \nEmail = ${email ?? "BELUM DIISI"}';
}

double hitungLuasPersegiPanjang(double panjang, double lebar){
  return panjang * lebar;
}

void main(){
  String nama = 'Julian';
  int nim = 2341720255;
  double panjang = 4, lebar = 5;

  final profile = Profile(nama: nama, nim: nim); // dengan menggunakan final, maka variabel profile tidak bisa diisi nilai baru
  final luasPersegiPanjang = hitungLuasPersegiPanjang(panjang, lebar);

//urutan dibaca : 1
  //ini adalah contoh jika variabel nama, nim dan email menggunakan **final**
  // maka nama, nim dan email tidak bisa di ubah ditengah jalan
  
  // profile.nama = 'ayu';
  // profile.nim = 23;
  // profile.email = 'aoeaoe';
  
  print(profile.info());
  print('Luas Persegi Panjang: $luasPersegiPanjang');
}