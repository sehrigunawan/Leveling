import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../logic/auth_logic.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/auth_widgets.dart'; // Gunakan CustomTextField & GradientButton

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Animation Controller untuk Emoji Floating
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final authLogic = Provider.of<AuthLogic>(context, listen: false);
    
    // Panggil fungsi login
    final error = await authLogic.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (mounted) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Berhasil!"), backgroundColor: Colors.green),
        );
        // Router akan otomatis redirect ke /dashboard karena refreshListenable
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
              constraints: const BoxConstraints(maxWidth: 450), // Batasi lebar seperti max-w-md
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- HEADER ---
                  SlideTransition(
                    position: _offsetAnimation,
                    child: const Text("😸", style: TextStyle(fontSize: 60)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Welcome Back!",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Lanjutkan petualangan belajarmu",
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 32),

                  // --- LOGIN CARD ---
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
                        const SizedBox(height: 24),
                        
                        GradientButton(
                          text: "Login",
                          icon: Icons.login,
                          isLoading: isLoading,
                          onPressed: _handleLogin,
                        ),

                        const SizedBox(height: 24),
                        
                        // --- DIVIDER "ATAU" ---
                        Row(
                          children: [
                            const Expanded(child: Divider(color: AppColors.border)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text("ATAU", style: TextStyle(fontSize: 12, color: AppColors.textMuted.withOpacity(0.7))),
                            ),
                            const Expanded(child: Divider(color: AppColors.border)),
                          ],
                        ),
                        
                        const SizedBox(height: 24),

                        // --- GOOGLE BUTTON ---
                        OutlinedButton.icon(
                          onPressed: () async {
                            final authLogic = Provider.of<AuthLogic>(context, listen: false);
                            final error = await authLogic.loginWithGoogle();
                            if (error != null && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                            }
                          },
                          icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.red), // Placeholder Icon
                          label: const Text("Login dengan Google", style: TextStyle(color: AppColors.textPrimary)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            minimumSize: const Size(double.infinity, 48),
                            side: const BorderSide(color: AppColors.border, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // --- LINKS ---
                        TextButton(
                          onPressed: () {
                            context.push('/forgot-password');
                          },
                          child: const Text("Lupa Password?", style: TextStyle(color: AppColors.brandPurple)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Belum punya akun? ", style: TextStyle(color: AppColors.textMuted)),
                            GestureDetector(
                              onTap: () => context.push('/register'),
                              child: const Text(
                                "Daftar di sini",
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