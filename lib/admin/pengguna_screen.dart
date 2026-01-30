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

  List users = [];
  List filteredUsers = []; 
  bool isLoading = true;

  final TextEditingController searchController =
      TextEditingController(); 

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

  // ================== SEARCH USER ==================
  void searchUser(String keyword) {
    if (keyword.isEmpty) {
      setState(() {
        filteredUsers = users;
      });
      return;
    }

    final result = users.where((user) {
      final username = user["username"].toString().toLowerCase();
      final email = user["email"].toString().toLowerCase();

      return username.contains(keyword.toLowerCase()) ||
          email.contains(keyword.toLowerCase());
    }).toList();

    setState(() {
      filteredUsers = result;
    });
  }

  // ================== DELETE USER ==================
  Future<void> deleteUser(String idUser) async {
    await supabase.from('users').delete().eq('id_user', idUser);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User berhasil dihapus")),
    );

    fetchUsers();
  }

  // ================== KONFIRMASI DELETE ==================
  Future<void> confirmDelete(Map user) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Konfirmasi Hapus",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            "Apakah kamu yakin ingin menghapus pengguna:\n\n${user["username"]}?",
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal", style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await deleteUser(user["id_user"]);
              },
              child: Text(
                "Hapus",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ================== FORM DIALOG ==================
  Widget penggunaFormDialog({
    required String title,
    required TextEditingController nameController,
    required TextEditingController emailController,
    required VoidCallback onConfirm,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
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

            // INPUT NAMA
            TextField(
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
            ),

            const SizedBox(height: 14),

            // INPUT EMAIL
            TextField(
              controller: emailController,
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

            const SizedBox(height: 22),

            // BUTTON
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
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
                    onPressed: onConfirm,
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
    );
  }

  // ================== ADD USER ==================
  Future<void> addUser() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return penggunaFormDialog(
          title: "Tambah Pengguna",
          nameController: nameController,
          emailController: emailController,
          onConfirm: () async {
            await supabase.from("users").insert({
              "username": nameController.text,
              "email": emailController.text,
              "role": "peminjam",
            });

            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("User berhasil ditambahkan")),
            );

            fetchUsers();
          },
        );
      },
    );
  }

  // ================== EDIT USER ==================
  Future<void> editUser(Map user) async {
    final nameController = TextEditingController(text: user['username']);
    final emailController = TextEditingController(text: user['email']);

    showDialog(
      context: context,
      builder: (context) {
        return penggunaFormDialog(
          title: "Edit Pengguna",
          nameController: nameController,
          emailController: emailController,
          onConfirm: () async {
            await supabase
                .from("users")
                .update({
                  "username": nameController.text,
                  "email": emailController.text,
                  "update_at": DateTime.now().toIso8601String(),
                })
                .eq("id_user", user["id_user"]);

            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("User berhasil diupdate")),
            );

            fetchUsers();
          },
        );
      },
    );
  }

  // ================== INIT ==================
  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // ================== UI ==================
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
                onChanged: (value) => setState(() => searchUser(value)),
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
                    borderSide:
                        BorderSide(color: Colors.grey.shade400, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFF6C6D7A), width: 2),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return _userCard(user);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= USER CARD =================
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
                  user["username"],
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user["email"],
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
            onPressed: () => confirmDelete(user),
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
