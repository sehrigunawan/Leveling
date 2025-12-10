import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../logic/auth_logic.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/auth_widgets.dart'; // CustomTextField & GradientButton

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // State untuk melacak tahapan (0: Email, 1: Kode, 2: Password Baru)
  int _currentStep = 0;
  bool _isLoading = false;

  // Controllers
  final _emailController = TextEditingController();
  final _codeController = TextEditingController(); // Untuk kode OTP
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  // --- LOGIC TAHAP 1: CEK EMAIL ---
  void _handleCheckEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnack("Email harus diisi", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final authLogic = Provider.of<AuthLogic>(context, listen: false);
    
    // 1. Cek apakah email terdaftar di DB
    final exists = await authLogic.checkEmailExists(email);

    setState(() => _isLoading = false);

    if (exists) {
      // (Simulasi) Kirim kode ke email (Backend logic diperlukan di sini)
      _showSnack("Kode verifikasi telah dikirim ke $email", isError: false);
      setState(() => _currentStep = 1); // Pindah ke tahap Input Kode
    } else {
      _showSnack("Akun dengan email ini belum terdaftar.", isError: true);
    }
  }

  // --- LOGIC TAHAP 2: VERIFIKASI KODE ---
  void _handleVerifyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isLoading = true);
    
    // Simulasi Cek Kode (Disini seharusnya panggil API Backend)
    await Future.delayed(const Duration(seconds: 1)); 

    setState(() => _isLoading = false);

    if (code == "123456") { // Hardcode sementara untuk testing UI
      _showSnack("Kode benar!", isError: false);
      setState(() => _currentStep = 2); // Pindah ke tahap Password Baru
    } else {
      _showSnack("Kode verifikasi salah.", isError: true);
    }
  }

  // --- LOGIC TAHAP 3: SIMPAN PASSWORD BARU ---
  void _handleSavePassword() async {
    final pass = _newPassController.text;
    final confirm = _confirmPassController.text;

    if (pass.length < 6) {
      _showSnack("Password minimal 6 karakter", isError: true);
      return;
    }
    if (pass != confirm) {
      _showSnack("Konfirmasi password tidak cocok", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    // CATATAN: Firebase Client SDK tidak bisa update password user yang tidak login.
    // Solusi Real: Gunakan authLogic.sendResetLink(email) yang mengirim link ke email.
    // Untuk simulasi UI ini, kita anggap sukses dan redirect ke login.
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      _showSnack("Password berhasil diubah! Silakan login.", isError: false);
      context.go('/login'); // Kembali ke login
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lupa Password"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            // Jika di step lanjut, tombol back mundur step dulu
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.bgPurple, AppColors.bgBlue, AppColors.bgPink],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Icon Kunci/Lock Besar
              const Text("🔐", style: TextStyle(fontSize: 60)),
              const SizedBox(height: 24),

              // Card Container
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
                  ],
                ),
                child: _buildFormContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    switch (_currentStep) {
      case 0: // Input Email
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Reset Password", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Masukkan email yang terdaftar. Kami akan mengirimkan kode konfirmasi.", style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
            const SizedBox(height: 24),
            CustomTextField(
              label: "Email",
              hint: "kamu@contoh.com",
              icon: Icons.email_outlined,
              controller: _emailController,
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: "Kirim Kode",
              isLoading: _isLoading,
              onPressed: _handleCheckEmail,
            ),
          ],
        );

      case 1: // Input Kode
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Verifikasi Kode", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Masukkan kode 6 digit yang dikirim ke ${_emailController.text}", style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
            const SizedBox(height: 24),
            CustomTextField(
              label: "Kode Verifikasi",
              hint: "123456",
              icon: Icons.lock_clock_outlined,
              controller: _codeController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: "Verifikasi",
              isLoading: _isLoading,
              onPressed: _handleVerifyCode,
            ),
            TextButton(
              onPressed: () {
                _showSnack("Kode dikirim ulang (Simulasi)");
              }, 
              child: const Center(child: Text("Kirim Ulang Kode", style: TextStyle(color: AppColors.brandPurple))),
            )
          ],
        );

      case 2: // Password Baru
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Buat Password Baru", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Silakan masukkan password baru Anda.", style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
            const SizedBox(height: 24),
            CustomTextField(
              label: "Password Baru",
              hint: "••••••••",
              icon: Icons.lock_outline,
              isPassword: true,
              controller: _newPassController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: "Konfirmasi Password",
              hint: "••••••••",
              icon: Icons.lock_outline,
              isPassword: true,
              controller: _confirmPassController,
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: "Simpan Password",
              isLoading: _isLoading,
              onPressed: _handleSavePassword,
            ),
          ],
        );
      
      default:
        return const SizedBox.shrink();
    }
  }
}