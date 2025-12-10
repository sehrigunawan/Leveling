import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/auth_widgets.dart'; // GradientButton
import '../../../logic/auth_logic.dart'; // Logic Auth

class PetNamingPage extends StatefulWidget {
  const PetNamingPage({super.key});

  @override
  State<PetNamingPage> createState() => _PetNamingPageState();
}

class _PetNamingPageState extends State<PetNamingPage> {
  final _petNameController = TextEditingController();
  
  // Data dummy emoji (Sama seperti React)
  final Map<String, List<String>> _petEmojis = {
    'cat': ['😸', '😼', '😻'],
    'dog': ['🐕', '🦮', '🐶'],
    'hamster': ['🐹', '🐹'],
  };

  void _handleFinalRegistration() async {
    final petName = _petNameController.text.trim();
    if (petName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama pet tidak boleh kosong")),
      );
      return;
    }

    // 1. Ambil Data dari Halaman Sebelumnya (Register -> Character -> Naming)
    final allData = GoRouterState.of(context).extra as Map<String, dynamic>?;

    if (allData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan: Data registrasi hilang."), backgroundColor: Colors.red),
      );
      return;
    }

    // 2. Panggil Logic Register ke Firebase
    final authLogic = Provider.of<AuthLogic>(context, listen: false);
    
    final error = await authLogic.register(
      email: allData['email'],
      password: allData['password'],
      name: allData['name'],
      selectedCharacter: allData['characterId'],
      petName: petName,
    );

    if (mounted) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      } else {
        // Sukses! Router akan otomatis redirect ke Dashboard karena authState berubah
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Selamat datang ${allData['name']}!"), backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil characterId dari data yang dikirim, default ke 'cat' jika null
    final extraData = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final charId = extraData?['characterId'] as String? ?? 'cat';
    
    final emojis = _petEmojis[charId] ?? ['😸'];
    final isLoading = context.watch<AuthLogic>().isLoading;

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
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- HEADER ---
                  const Text(
                    "Beri Nama Pet-mu",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Pet-mu siap menunggu nama istimewa",
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 48),

                  // --- PET DISPLAY CARD (White Box) ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Emoji Utama Besar
                        Text(emojis[0], style: const TextStyle(fontSize: 80)),
                        const SizedBox(height: 16),
                        // Emoji Kecil di bawahnya
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(emojis[0], style: const TextStyle(fontSize: 40)),
                            const SizedBox(width: 8),
                            if (emojis.length > 1) 
                              Text(emojis[1], style: const TextStyle(fontSize: 40)),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- NAMING FORM CARD ---
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Nama Pet", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                        const SizedBox(height: 8),
                        
                        // Input Field Sederhana
                        TextField(
                          controller: _petNameController,
                          maxLength: 20,
                          decoration: InputDecoration(
                            hintText: "Masukkan nama pet-mu",
                            hintStyle: const TextStyle(color: AppColors.textMuted),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            counterText: "", // Menyembunyikan counter default flutter agar rapi
                          ),
                        ),
                        // Counter Manual (opsional, sesuai desain React)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 16),
                            child: ValueListenableBuilder(
                              valueListenable: _petNameController,
                              builder: (context, value, child) {
                                return Text(
                                  "${value.text.length}/20 karakter",
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                );
                              },
                            ),
                          ),
                        ),
                        
                        GradientButton(
                          text: isLoading ? "Membuat Pet..." : "Mulai Petualangan",
                          isLoading: isLoading,
                          onPressed: _handleFinalRegistration,
                        ),
                      ],
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