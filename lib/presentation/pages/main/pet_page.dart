import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../logic/auth_logic.dart';
import '../../../core/services/auth_services.dart';
import '../../../data/models/ability_model.dart';

class PetPage extends StatelessWidget {
  const PetPage({super.key});

  final Map<String, List<String>> _petEmojis = const {
    'cat': ['😸', '😼'],
    'dog': ['🐕', '🦮'],
    'hamster': ['🐹', '🐹'],
  };

  @override
  Widget build(BuildContext context) {
    final authLogic = context.watch<AuthLogic>();
    final user = authLogic.userModel;
    final firebaseUser = authLogic.firebaseUser;

    if (user == null || firebaseUser == null) return const Center(child: CircularProgressIndicator());

    final petEmoji = _petEmojis[user.selectedCharacter]?[0] ?? '😸';
    final petEmoji2 = _petEmojis[user.selectedCharacter]?[1] ?? '😼';

    return Scaffold(
      backgroundColor: AppColors.bgPurple,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Pet & Abilities", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.push('/shop'), // Navigasi ke Shop
            icon: const Icon(Icons.storefront, color: AppColors.brandPurple),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- PET CARD (Sama seperti sebelumnya tapi dibersihkan) ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade50, Colors.pink.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Text(petEmoji, style: const TextStyle(fontSize: 80)),
                  const SizedBox(height: 16),
                  Text(user.petName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text("Level ${user.level} • ${user.streak} Streak 🔥", style: const TextStyle(color: AppColors.textMuted)),
                  const SizedBox(height: 24),
                  
                  // Tombol Cepat ke Shop
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/shop'),
                      icon: const Icon(Icons.shopping_bag),
                      label: const Text("Beli Ability Baru"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 32),
            
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Ability Kamu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),

            // --- INVENTORY LIST (STREAM DARI DATABASE) ---
            StreamBuilder<List<Ability>>(
              stream: AuthService().getUserInventory(firebaseUser.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final inventory = snapshot.data ?? [];

                if (inventory.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        const Icon(Icons.backpack_outlined, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        const Text("Belum punya ability.", style: TextStyle(color: Colors.grey)),
                        TextButton(onPressed: () => context.push('/shop'), child: const Text("Kunjungi Toko"))
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: inventory.length,
                  itemBuilder: (context, index) {
                    final item = inventory[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                            child: Text(item.icon, style: const TextStyle(fontSize: 24)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(item.description, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.brandPurple,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text("x${item.quantity}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}