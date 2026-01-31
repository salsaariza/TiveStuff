import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/header_back.dart';
import '../widgets/nav_admin.dart';

class PenggunaScreen extends StatefulWidget {
  const PenggunaScreen({super.key});

  @override
  State<PenggunaScreen> createState() => _PenggunaScreenState();
}

class _PenggunaScreenState extends State<PenggunaScreen> {
  final supabase = Supabase.instance.client;

  final List<String> roleEnum = ['admin', 'petugas', 'peminjam'];

  List users = [];
  List filteredUsers = [];
  bool isLoading = true;

  // ================== LOAD USERS ==================
  Future<void> fetchUsers() async {
    setState(() => isLoading = true);

    final response = await supabase
        .from('users')
        .select()
        .order('created_at', ascending: false);

    setState(() {
      users = response;
      filteredUsers = response;
      isLoading = false;
    });
  }

  // ================== SEARCH ==================
  void searchUser(String keyword) {
    if (keyword.isEmpty) {
      filteredUsers = users;
    } else {
      filteredUsers = users.where((user) {
        return user['username'].toString().toLowerCase().contains(
              keyword.toLowerCase(),
            ) ||
            user['email'].toString().toLowerCase().contains(
              keyword.toLowerCase(),
            );
      }).toList();
    }
    setState(() {});
  }

  // ================== DELETE ==================
  Future<void> deleteUser(String id) async {
    await supabase.from('users').delete().eq('id_user', id);
    fetchUsers();
  }

  // ================== DIALOG FORM ==================
  Widget penggunaFormDialog({
    required String title,
    required TextEditingController nameController,
    required TextEditingController emailController,
    required String selectedRole,
    required ValueChanged<String> onRoleChanged,
    required VoidCallback onConfirm,
  }) {
    final formKey = GlobalKey<FormState>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              // NAMA
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: "Nama",
                  hintStyle: GoogleFonts.poppins(fontSize: 13),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama wajib diisi' : null,
              ),

              const SizedBox(height: 14),

              // EMAIL
              TextFormField(
                controller: emailController,
                readOnly: title == "Edit Pengguna",
                decoration: InputDecoration(
                  hintText: "Email",
                  hintStyle: GoogleFonts.poppins(fontSize: 13),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ROLE (STYLE IDENTIK TEXTFIELD)
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: roleEnum
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) onRoleChanged(v);
                },
                decoration: InputDecoration(
                  hintText: "Role",
                  hintStyle: GoogleFonts.poppins(fontSize: 13),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        "Batal",
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C6D7A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          onConfirm();
                        }
                      },
                      child: Text(
                        "Konfirmasi",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================== ADD ==================
  Future<void> addUser() async {
    final nameC = TextEditingController();
    final emailC = TextEditingController();
    String role = 'peminjam';

    showDialog(
      context: context,
      builder: (_) => penggunaFormDialog(
        title: "Tambah Pengguna",
        nameController: nameC,
        emailController: emailC,
        selectedRole: role,
        onRoleChanged: (v) => role = v,
        onConfirm: () async {
          await supabase.from('users').insert({
            'username': nameC.text.trim(),
            'email': emailC.text.trim(),
            'role': role,
          });
          Navigator.pop(context);
          fetchUsers();
        },
      ),
    );
  }

  // ================== EDIT ==================
  Future<void> editUser(Map user) async {
    final nameC = TextEditingController(text: user['username']);
    final emailC = TextEditingController(text: user['email']);
    String role = user['role'];

    showDialog(
      context: context,
      builder: (_) => penggunaFormDialog(
        title: "Edit Pengguna",
        nameController: nameC,
        emailController: emailC,
        selectedRole: role,
        onRoleChanged: (v) => role = v,
        onConfirm: () async {
          await supabase
              .from('users')
              .update({
                'username': nameC.text.trim(),
                'role': role,
                'update_at': DateTime.now().toIso8601String(),
              })
              .eq('id_user', user['id_user']);

          Navigator.pop(context);
          fetchUsers();
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // ================== UI (TIDAK DIUBAH) ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C6D7A),
        onPressed: addUser,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) return;

          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/alat');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/riwayat');
          } else if (index == 4) {
            Navigator.pushReplacementNamed(context, '/aktivitas');
          }
        },
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Header(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Pengguna",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: searchUser,
                decoration: InputDecoration(
                  hintText: "Cari Pengguna",
                  hintStyle: GoogleFonts.poppins(fontSize: 13),
                  suffixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF6C6D7A),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredUsers.isEmpty
                  ? Center(
                      child: Text(
                        "Data Riwayat Kosong",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _userCard(filteredUsers[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userCard(Map user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['username'],
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user['email'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20),
            onPressed: () => deleteUser(user['id_user']),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () => editUser(user),
          ),
        ],
      ),
    );
  }
}
