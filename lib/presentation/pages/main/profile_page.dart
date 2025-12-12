import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../logic/auth_logic.dart';
import '../../../core/services/auth_services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Map<String, List<String>> _petEmojis = {
    'cat': ['😸', '😼'],
    'dog': ['🐕', '🦮'],
    'hamster': ['🐹', '🐹'],
  };

  // Fungsi Logout
  void _handleLogout(BuildContext context) async {
    final authService = AuthService();
    await authService.logout();
    
    if (mounted) {
      // Reset state user di provider jika perlu (tergantung implementasi AuthLogic)
      // Navigasi ke halaman Login dan hapus history route
      context.go('/login'); 
    }
  }

  // Fungsi Edit Nama User
  void _showEditNameDialog(BuildContext context, String currentName, String uid) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ubah Nama Profil"),
        content: TextField(
          controller: controller,
          maxLength: 20,
          decoration: const InputDecoration(
            hintText: "Nama baru...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                // Update langsung ke Firestore
                await FirebaseFirestore.instance.collection('users').doc(uid).update({
                  'name': controller.text.trim()
                });
                if (mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandPurple, foregroundColor: Colors.white),
            child: const Text("Simpan"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data user dari Provider (Realtime Update)
    final user = context.watch<AuthLogic>().userModel;
    final firebaseUser = context.read<AuthLogic>().firebaseUser;

    if (user == null || firebaseUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final petEmoji = _petEmojis[user.selectedCharacter] ?? ['😸', '😸'];
    final double xpProgress = (user.targetXp == 0) ? 0 : (user.currentXp / user.targetXp);

    return Scaffold(
      backgroundColor: AppColors.bgPurple,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Profile", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 24),

              // --- PET CARD ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade50, Colors.pink.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.brandPurple.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Pet-mu", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(petEmoji[0], style: const TextStyle(fontSize: 48)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.petName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text("Level ${user.level} • ${user.streak} hari streak 🔥", style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              const SizedBox(height: 8),
                              // XP Bar
                              Container(
                                height: 8,
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                child: FractionallySizedBox(
                                  widthFactor: xpProgress.clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [AppColors.brandPurple, AppColors.brandPink]),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- PROFILE INFO CARD ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Nama", style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        GestureDetector(
                          onTap: () => _showEditNameDialog(context, user.name, user.uid),
                          child: const Text("Edit", style: TextStyle(fontSize: 12, color: AppColors.brandPurple, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(user.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    
                    const Divider(height: 32),
                    
                    // Email
                    const Text("Email", style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    Text(user.email, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- PENGATURAN (TANPA DARK MODE) ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Pengaturan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    
                    // Ganti Karakter Pet (Info Only)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Ganti Karakter Pet", style: TextStyle(fontSize: 14)),
                        TextButton(
                          onPressed: null, // Disabled
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textMuted,
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text("Tidak Bisa (Harus Reset)", style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- TENTANG APLIKASI ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Tentang Aplikasi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Text("Leveling v1.0.0", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("Belajar skill dengan cara yang menyenangkan dan gamified", style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- LOGOUT BUTTON ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleLogout(context),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
              
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}