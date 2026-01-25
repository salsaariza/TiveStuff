import 'package:flutter/material.dart';
import 'package:tivestuff1/peminjam/alat_peminjaman.dart';
import 'package:tivestuff1/peminjam/keranjang_peminjaman.dart';
import 'package:tivestuff1/peminjam/pengajuan_screen.dart';
import 'package:tivestuff1/peminjam/pengembalian_screen.dart';
import 'package:tivestuff1/screens/dashboard_peminjam.dart';
import 'package:tivestuff1/screens/login_screen.dart';
import 'package:tivestuff1/screens/splash_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboardpeminjam': (context) => const DashboardPeminjam(),
        '/alatpeminjam': (context) => const AlatPeminjamScreen(),  
        '/keranjangpeminjaman': (context) => const KeranjangPeminjamanScreen(),  
        '/peminjamanpeminjam':(context) => const AlatPeminjamScreen(),  
        '/pengajuanpeminjam':(context) => const PengajuanScreen(),
        '/pengembalianpeminjam':(context) => const PengembalianPeminjamScreen(),
      },
    );
  }
}
