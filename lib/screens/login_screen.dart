import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dashboard_screen.dart';
import 'dashboard_petugas.dart';
import 'dashboard_peminjam.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailC = TextEditingController();
  final _passwordC = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // 1️⃣ Login ke Supabase Auth
      final auth = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailC.text.trim(),
        password: _passwordC.text.trim(),
      );

      final userId = auth.user!.id;

      // 2️⃣ Ambil role dari tabel users
      final data = await Supabase.instance.client
          .from('users')
          .select('role')
          .eq('id_user', userId)
          .single();

      final role = data['role'];

      if (!mounted) return;

      // sesuai role
      switch (role) {
        case 'admin':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
          break;

        case 'petugas':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardPetugas()),
          );
          break;

        case 'peminjam':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardPeminjam()),
          );
          break;

        default:
          _showError('Role tidak dikenali');
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Login gagal, coba lagi');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          color: Colors.white,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logotivestuff.png', width: 200),
                const SizedBox(height: 10),
                Text(
                  'TiveStuff',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pengelola Peminjaman Inventaris\nBarang Jurusan Otomotif',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 28),

                _inputField(
                  hint: 'Email',
                  icon: Icons.email_outlined,
                  controller: _emailC,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Email wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                _inputField(
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  controller: _passwordC,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Password wajib diisi' : null,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E5757),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Login',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: validator,
        style: GoogleFonts.poppins(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(fontSize: 12),
          prefixIcon: Icon(icon, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
