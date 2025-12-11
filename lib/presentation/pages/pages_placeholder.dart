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
class ChaaracterSelectPage extends StatelessWidget {
  const ChaaracterSelectPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Character Select Page")));
}

class PeetNamingPage extends StatelessWidget {
  const PeetNamingPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Pet Naming Page")));
}

class DaashboardPage extends StatelessWidget {
  const DaashboardPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Dashboard Page")));
}

class GooalsPage extends StatelessWidget {
  const GooalsPage({super.key});
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