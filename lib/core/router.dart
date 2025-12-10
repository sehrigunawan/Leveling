import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../logic/auth_logic.dart';
import '../presentation/pages/landing_page.dart';
import '../presentation/pages/auth/register_page.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/forgot_password_page.dart';

// Import halaman-halaman (Gunakan placeholder dulu agar tidak error)
import '../presentation/pages/pages_placeholder.dart';

class AppRouter {
  final AuthLogic authLogic;

  AppRouter(this.authLogic);

  late final GoRouter router = GoRouter(
    // KUNCI UTAMA: refreshListenable akan mendengarkan perubahan di AuthLogic
    // Setiap kali notifyListeners() dipanggil di AuthLogic, router akan mengecek ulang redirect.
    refreshListenable: authLogic, 
    
    initialLocation: '/', 
    
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = authLogic.isLoggedIn;
      final bool isLoading = authLogic.isLoading;
      
      // Daftar halaman yang bisa diakses tanpa login
      final isPublicRoute = state.uri.path == '/' || 
                            state.uri.path == '/login' || 
                            state.uri.path == '/register';

      // 1. Jika masih loading, jangan lakukan apa-apa (tunggu splash selesai)
      if (isLoading) return null;

      // 2. Jika BELUM login dan mencoba akses halaman PRIVAT -> Lempar ke Login
      if (!loggedIn && !isPublicRoute) {
        return '/login';
      }

      // 3. Jika SUDAH login dan mencoba akses halaman PUBLIK -> Lempar ke Dashboard
      if (loggedIn && isPublicRoute) {
        return '/dashboard';
      }

      // 4. Lanjut ke tujuan semula
      return null;
    },

    routes: [
      // --- PUBLIC ROUTES ---
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      
      // --- ONBOARDING ROUTES ---
      GoRoute(
        path: '/character-select',
        builder: (context, state) => const CharacterSelectPage(),
      ),
      GoRoute(
        path: '/pet-naming',
        builder: (context, state) => const PetNamingPage(),
      ),

      // --- PROTECTED ROUTES ---
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/goals',
        builder: (context, state) => const GoalsPage(),
      ),
      GoRoute(
        path: '/shop',
        builder: (context, state) => const ShopPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      // Contoh detail page dengan parameter
      // GoRoute(
      //   path: '/goal-detail/:goalId',
      //   builder: (context, state) => GoalDetailPage(id: state.pathParameters['goalId']!),
      // ),
    ],
  );
}