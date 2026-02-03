import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tivestuff1/admin/admin_keranjang.dart';
import 'package:tivestuff1/peminjam/ajukan_pengembalian.dart';
import 'package:tivestuff1/petugas/kartu_peminjaman.dart';

// Screens umum
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

// Admin Screens
import 'screens/dashboard_screen.dart';
import 'admin/alat_screen.dart';
import 'admin/add_kategori.dart';
import 'admin/pengguna_screen.dart';
import 'admin/riwayat_screen.dart';
import 'admin/aktivitas_screen.dart';

// Petugas Screens
import 'petugas/peminjaman_screen.dart';
import 'petugas/pengembalian_screen.dart';
import 'petugas/laporan_screen.dart';
import 'screens/dashboard_petugas.dart';
import 'package:tivestuff1/petugas/kartu_peminjaman.dart';

// Peminjam Screens
import 'peminjam/alat_peminjaman.dart';
import 'peminjam/keranjang_peminjaman.dart';
import 'peminjam/pengajuan_screen.dart';
import 'peminjam/pengembalian_screen.dart';
import 'screens/dashboard_peminjam.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://sksteptzyiwukwyfqfth.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrc3RlcHR6eWl3dWt3eWZxZnRoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgyNzIxMzcsImV4cCI6MjA4Mzg0ODEzN30.DIGZVunje7iy1Sr80HWdV3HOQ3tGxQ8OyP8DBebFakQ', 
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      routes: {
        // ===== COMMON ROUTES =====
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),

        // ===== ADMIN ROUTES =====
        '/dashboard': (context) => const DashboardScreen(),
        '/alat': (context) => const AlatScreen(),
        '/kategori': (context) => const KategoriScreen(),
        '/pengguna': (context) => const PenggunaScreen(),
        '/riwayat': (context) => const RiwayatScreen(),
        '/aktivitas': (context) => const AktivitasScreen(),
        '/adminkeranjang': (context) => const AdminKeranjang(),

        // ===== PETUGAS ROUTES =====
        '/dashboardpetugas': (context) => const DashboardPetugas(),
        '/peminjaman': (context) => const PengajuanPeminjamanScreen(),
        '/pengembalian': (context) => const PengembalianScreen(),
        '/laporan': (context) => const LaporanScreen(),
        '/kartupeminjaman': (context) => KartuPeminjamanScreen(idPeminjaman: 0),

        // ===== PEMINJAM ROUTES =====
        '/dashboardpeminjam': (context) => const DashboardPeminjam(),
        '/alatpeminjam': (context) => const AlatPeminjamScreen(),
        '/keranjangpeminjaman': (context) => const KeranjangPeminjamanScreen(),
        '/peminjamanpeminjam': (context) => const AlatPeminjamScreen(),
        '/pengajuanpeminjam': (context) => const PengajuanScreen(),
        '/pengembalianpeminjam': (context) => const PengembalianPeminjamScreen(),
        '/ajukanpengembalian' : (context) => const AjukanPengembalianScreen(),
      },
    );
  }
}

// ===== AUTH GATE =====
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<String> _initialRoute() async {
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;
    if (session == null) return '/login';

    // Ambil role dari tabel users
    final user = await supabase
        .from('users')
        .select('role')
        .eq('id_user', session.user.id)
        .single();

    final role = user['role'];

    // Tentukan dashboard awal sesuai role
    switch (role) {
      case 'admin':
        return '/dashboard';
      case 'petugas':
        return '/dashboardpetugas';
      case 'peminjam':
        return '/dashboardpeminjam';
      default:
        return '/login';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _initialRoute(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Redirect ke route sesuai role
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, snapshot.data!);
        });

        // Placeholder sementara
        return const Scaffold();
      },
    );
  }
}
