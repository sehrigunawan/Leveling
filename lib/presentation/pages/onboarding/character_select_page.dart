import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/auth_widgets.dart';

class CharacterSelectPage extends StatefulWidget {
  const CharacterSelectPage({super.key});

  @override
  State<CharacterSelectPage> createState() => _CharacterSelectPageState();
}

class _CharacterSelectPageState extends State<CharacterSelectPage> {
  String? _selectedCharacterId;

  final List<Map<String, dynamic>> _characters = [
    {
      "id": "cat",
      "name": "Anak Kucing Buluk",
      "emoji": "😸",
      "desc": "Lucu, buluk, dan penuh energi! Siap belajar bersama kamu.",
    },
    {
      "id": "dog",
      "name": "Anak Anjing Kecil",
      "emoji": "🐕",
      "desc": "Ceria dan setia, akan menemani setiap latihan kamu.",
    },
    {
      "id": "hamster",
      "name": "Hamster Kecil",
      "emoji": "🐹",
      "desc": "Mungil tapi tangguh, siap petualangan skill learning.",
    },
  ];

  void _handleSelect() {
    if (_selectedCharacterId != null) {
      // 1. Ambil data registrasi (email, pass, name) dari halaman sebelumnya
      final registerData = GoRouterState.of(context).extra as Map<String, dynamic>?;

      if (registerData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Data registrasi hilang. Silakan daftar ulang.")),
        );
        return;
      }

      // 2. Gabungkan data registrasi dengan pilihan karakter
      final dataToSend = {
        ...registerData, // Copy email, password, name
        'characterId': _selectedCharacterId, // Tambah characterId
      };

      // 3. Kirim paket lengkap ke Pet Naming
      context.push('/pet-naming', extra: dataToSend);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.bgPurple, AppColors.bgBlue, AppColors.bgPink],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Pilih Karakter Pet-mu",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Pet ini akan tumbuh dan berkembang seiring dengan kemajuan belajar kamu.\nSemakin lama streak kamu, semakin keren pet-nya! 🎮",
                    style: TextStyle(fontSize: 16, color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 48),

                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: _characters.map((char) {
                      final isSelected = _selectedCharacterId == char['id'];
                      return _CharacterCard(
                        id: char['id'],
                        name: char['name'],
                        emoji: char['emoji'],
                        desc: char['desc'],
                        isSelected: isSelected,
                        onTap: () => setState(() => _selectedCharacterId = char['id']),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 48),

                  SizedBox(
                    width: 200,
                    child: GradientButton(
                      text: "Adopsi Pet-ku!",
                      onPressed: _selectedCharacterId == null ? () {} : _handleSelect,
                      isLoading: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget Kartu Karakter (Sama seperti sebelumnya)
class _CharacterCard extends StatelessWidget {
  final String id;
  final String name;
  final String emoji;
  final String desc;
  final bool isSelected;
  final VoidCallback onTap;

  const _CharacterCard({
    required this.id,
    required this.name,
    required this.emoji,
    required this.desc,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 280,
        padding: const EdgeInsets.all(24),
        transform: isSelected ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected 
              ? Border.all(color: AppColors.brandPurple, width: 3) 
              : Border.all(color: Colors.transparent, width: 3),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? AppColors.brandPurple.withOpacity(0.2) 
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 20 : 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 24),
            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            if (isSelected) ...[
              const SizedBox(height: 16),
              const Divider(color: AppColors.bgPurple),
              const SizedBox(height: 8),
              const Text("✓ Dipilih", style: TextStyle(color: AppColors.brandPurple, fontWeight: FontWeight.bold, fontSize: 12)),
            ]
          ],
        ),
      ),
    );
  }
}