import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tivestuff1/widgets/back_petugas.dart';
import 'splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePetugasScreen extends StatefulWidget {
  const ProfilePetugasScreen({super.key});

  @override
  State<ProfilePetugasScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfilePetugasScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    setState(() => isLoading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('users')
          .select('username, email, role')
          .eq('id_user', user.id)
          .maybeSingle();

      setState(() {
        userData = response;
      });
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const HeaderPetugas(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Riwayat",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // ================= PROFIL CARD =================
                          _profileCard(width),
                          const SizedBox(height: 20),

                          // ================= LOGOUT CARD =================
                          _logoutCard(context, width),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// ================= PROFIL CARD =================
  Widget _profileCard(double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: const Color(0xFF6D6E7A),
            child: const Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 10),
          Text(
            userData?['username'] ?? 'User',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          _infoField(label: 'Username', value: userData?['username'] ?? '-'),
          const SizedBox(height: 12),
          _infoField(label: 'Email', value: userData?['email'] ?? '-'),
          const SizedBox(height: 12),
          _infoField(label: 'Role', value: userData?['role'] ?? '-'),
        ],
      ),
    );
  }

  /// ================= LOGOUT CARD DENGAN KONFIRMASI =================
  Widget _logoutCard(BuildContext context, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.logout, color: Colors.red, size: 18),
              const SizedBox(width: 6),
              Text(
                'Keluar dari Aplikasi',
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Kamu akan keluar dari akun yang perlu login kembali untuk akses aplikasi.',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () async {
                // Dialog konfirmasi logout
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Konfirmasi Logout'),
                    content: Text(
                      'Apakah kamu yakin ingin keluar dari aplikasi?',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          'Keluar',
                          style: GoogleFonts.poppins(
                            color: Colors.red,
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                if (shouldLogout ?? false) {
                  await supabase.auth.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const SplashScreen()),
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout),
              label: Text(
                'Keluar Sekarang',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= INFO FIELD =================
  Widget _infoField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  /// ================= CARD DECORATION =================
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
      ],
    );
  }
}
