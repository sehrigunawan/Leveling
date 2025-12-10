import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../logic/auth_logic.dart';

// --- Auth & Public ---
class LaandingPage extends StatelessWidget {
  const LaandingPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Landing Page")));
}

// NOTE: LoginPage dan RegisterPage sebaiknya gunakan file asli yang sudah kita buat sebelumnya.
// Jika belum di-import di router, gunakan placeholder ini dulu:
class LooginPage extends StatelessWidget {
  const LooginPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Login Page Placeholder")));
}

class FoorgotPasswordPage extends StatelessWidget {
  const FoorgotPasswordPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Forgot Password Page Placeholder")));
}

class ReegisterPage extends StatelessWidget {
  const ReegisterPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Register Page Placeholder")));
}

// --- Onboarding ---
class CharacterSelectPage extends StatelessWidget {
  const CharacterSelectPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Character Select Page")));
}

class PetNamingPage extends StatelessWidget {
  const PetNamingPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Pet Naming Page")));
}

// --- Main App ---
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          // Tombol Logout di AppBar
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // 1. Panggil fungsi logout
              context.read<AuthLogic>().logout();
              // 2. Router akan mendeteksi perubahan auth dan otomatis redirect ke Login/Landing
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Ini Halaman Dashboard Sementara"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<AuthLogic>().logout();
              },
              child: const Text("Logout (Kembali)"),
            ),
          ],
        ),
      ),
    );
  }
}

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Goals Page")));
}

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Shop Page")));
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Profile Page")));
}