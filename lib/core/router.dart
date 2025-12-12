import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../logic/auth_logic.dart';
import '../presentation/pages/landing_page.dart';
import '../presentation/pages/auth/register_page.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/forgot_password_page.dart';
import '../presentation/pages/onboarding/character_select_page.dart';
import '../presentation/pages/onboarding/pet_naming_page.dart';
import '../presentation/pages/main/dashboard_page.dart';
import '../presentation/pages/main/main_wrapper.dart';
import '../presentation/pages/main/goals_page.dart';
import '../presentation/pages/main/goal_detail_page.dart';
import '../presentation/pages/main/daily_tips_page.dart';
import '../presentation/pages/main/challenges_page.dart';
import '../presentation/pages/main/challenge_detail_page.dart';
import '../presentation/pages/main/statistics_page.dart';
import '../presentation/pages/main/profile_page.dart';
import '../presentation/pages/main/pet_page.dart';
import '../presentation/pages/main/shop_page.dart';
import '../data/models/goals_model.dart';
import '../data/models/challenge_model.dart';


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
                            state.uri.path == '/register'||
                            state.uri.path == '/forgot-password'||
                            state.uri.path == '/character-select'||
                            state.uri.path == '/pet-naming';

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
        builder: (context, state) => const MainWrapper(),
      ),
      GoRoute(
        path: '/goals',
        builder: (context, state) => const MainWrapper(),
      ),
      GoRoute(
        path: '/goal-detail/:goalId',
        builder: (context, state) {
          final id = state.pathParameters['goalId']!;
          return GoalDetailPage(goalId: id);
        },
      ),
      GoRoute(
        path: '/daily-tips',
        builder: (context, state) {
          // Kita kirim Data via 'extra' karena butuh Object GoalModel lengkap
          final map = state.extra as Map<String, dynamic>;
          final goal = map['goal'] as GoalModel;
          final day = map['day'] as int;

          return DailyTipsPage(goal: goal, dayNumber: day);
        },
      ),
      GoRoute(
        path: '/challenge-detail',
        builder: (context, state) {
          final challenge = state.extra as ChallengeModel;
          return ChallengeDetailPage(challenge: challenge);
        },
      ),
      // GoRoute(
      //   path: '/shop',
      //   builder: (context, state) => const ShopPage(),
      // ),
      GoRoute(
        path: '/Statistic',
        builder: (context, state) => const StatisticsPage(),
      ),
      GoRoute(
        path: '/pet',
        builder: (context, state) => const PetPage(),
      ),
      GoRoute(
        path: '/shop',
        builder: (context, state) => const ShopPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
}