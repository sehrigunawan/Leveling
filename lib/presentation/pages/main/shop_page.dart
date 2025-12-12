import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/auth_services.dart';
import '../../../data/models/ability_model.dart';
import '../../../logic/auth_logic.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  void _handleBuy(BuildContext context, Ability item, String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Beli ${item.name}?"),
        content: Text("Harga: ${item.price} Koin\n\n${item.description}"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandPurple, foregroundColor: Colors.white),
            child: const Text("Beli"),
          )
        ],
      ),
    );

    if (confirm != true) return;

    final result = await AuthService().buyAbility(userId, item);

    if (context.mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Berhasil membeli ${item.name}! 🎉"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: ${result['error']}"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthLogic>().userModel;
    final userId = context.read<AuthLogic>().firebaseUser?.uid;
    
    if (user == null || userId == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: AppColors.bgPurple,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text("Ability Shop", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.amber)),
            child: Text("🪙 ${user.coins}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
          )
        ],
      ),
      body: SafeArea( // Tambahkan SafeArea
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            // --- PERBAIKAN UTAMA DISINI ---
            // Ubah ratio agar kartu lebih tinggi (makin kecil angka, makin tinggi)
            childAspectRatio: 0.60, 
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: Ability.catalog.length,
          itemBuilder: (context, index) {
            final item = Ability.catalog[index];
            final canAfford = user.coins >= item.price;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Text(item.icon, style: const TextStyle(fontSize: 48))),
                  const SizedBox(height: 12),
                  
                  // Nama Item (Fixed height biar rapi)
                  SizedBox(
                    height: 40,
                    child: Text(
                      item.name, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // --- GUNAKAN EXPANDED UNTUK DESKRIPSI ---
                  // Agar deskripsi mengisi sisa ruang tanpa mendorong tombol ke bawah layar
                  Expanded(
                    child: Text(
                      item.description, 
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted), 
                      maxLines: 4, 
                      overflow: TextOverflow.ellipsis
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Harga
                  Text("🪙 ${item.price}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 16)),
                  
                  const SizedBox(height: 8),
                  
                  // Tombol Beli
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: canAfford ? () => _handleBuy(context, item, userId) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canAfford ? AppColors.brandPurple : Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 0), // Kompak
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(canAfford ? "Beli" : "Kurang"),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}