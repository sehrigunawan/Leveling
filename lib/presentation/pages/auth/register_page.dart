import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../logic/auth_logic.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/auth_widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  // Animation Controller
  late final AnimationController _animController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: const Offset(0, 0),
    end: const Offset(0, -0.1),
  ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    // 1. Validasi Password Match
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password tidak cocok"), backgroundColor: Colors.red),
      );
      return;
    }

    // 2. Validasi Panjang Password
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password minimal 6 karakter"), backgroundColor: Colors.red),
      );
      return;
    }

    // 3. Register Process
    final authLogic = Provider.of<AuthLogic>(context, listen: false);
    
    // NOTE: Di React code, ini navigate ke '/character-select'.
    // Disini kita langsung register dulu untuk testing Dashboard.
    final error = await authLogic.register(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      name: _nameController.text.trim(),
      selectedCharacter: 'cat', // Default sementara
      petName: 'Pet-mu',        // Default sementara
    );

    if (mounted) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
      } else {
         // Sukses -> Router otomatis redirect ke Dashboard
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Akun berhasil dibuat!")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthLogic>().isLoading;

    return Scaffold(
      body: Container(
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
                children: [
                  // --- HEADER ---
                  SlideTransition(
                    position: _offsetAnimation,
                    child: const Text("🐱", style: TextStyle(fontSize: 60)), 
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Bergabunglah!",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Mulai petualangan belajar bersama SkillPet",
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 32),

                  // --- REGISTER CARD ---
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CustomTextField(
                          label: "Nama",
                          hint: "Nama lengkapmu",
                          icon: Icons.person_outline,
                          controller: _nameController,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: "Email",
                          hint: "kamu@contoh.com",
                          icon: Icons.email_outlined,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: "Password",
                          hint: "••••••••",
                          icon: Icons.lock_outline,
                          isPassword: true,
                          controller: _passwordController,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: "Konfirmasi Password",
                          hint: "••••••••",
                          icon: Icons.lock_outline,
                          isPassword: true,
                          controller: _confirmController,
                        ),
                        const SizedBox(height: 24),
                        
                        GradientButton(
                          text: "Buat Akun",
                          isLoading: isLoading,
                          onPressed: _handleRegister,
                        ),

                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Sudah punya akun? ", style: TextStyle(color: AppColors.textMuted)),
                            GestureDetector(
                              onTap: () => context.push('/login'),
                              child: const Text(
                                "Login di sini",
                                style: TextStyle(color: AppColors.brandPurple, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        )
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