import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../logic/auth_logic.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Get Real User Data from Provider
    final user = context.watch<AuthLogic>().userModel;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Convert total minutes to hours for display
    final totalHours = (user.totalMinutes / 60).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: AppColors.bgPurple,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Statistik",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // --- STATISTIK UMUM (GENERAL STATS) ---
              // Displaying this first as it's the most reliable DB data we have
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Statistik Umum", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildStatRow("Total Waktu Belajar", "$totalHours jam"),
                    _buildStatRow("Level Pet", "Level ${user.level}"),
                    // Note: 'Challenge Selesai' might need a specific field in UserModel if you want to track count separately, 
                    // or we can count it from a subcollection. For now, we'll use a placeholder or derived value.
                    // Assuming 'streak' represents consistent daily activity.
                    _buildStatRow("Streak Saat Ini", "${user.streak} Hari 🔥"),
                    _buildStatRow("Total Koin", "${user.coins} 🪙", isHighlighted: true),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- GRAFIK STREAK (STREAK GRAPH) ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Grafik Aktivitas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple.shade50, Colors.pink.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Generating dummy bars for visualization, but 
                          // in a real app you'd fetch 'daily_logs' collection.
                          // Here we visualize the current streak intensity.
                          _buildBar(0.3),
                          _buildBar(0.5),
                          _buildBar(0.2),
                          _buildBar(0.8),
                          _buildBar(0.4),
                          _buildBar(0.6),
                          _buildBar(user.streak > 0 ? 1.0 : 0.1, isCurrent: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("7 Hari Lalu", style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                        Text("Hari Ini", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandPurple)),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? Colors.amber : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double heightFactor, {bool isCurrent = false}) {
    return Flexible(
      child: FractionallySizedBox(
        heightFactor: heightFactor.clamp(0.1, 1.0),
        child: Container(
          width: 8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isCurrent 
                ? [AppColors.brandPurple, AppColors.brandPink] 
                : [AppColors.brandPurple.withValues(alpha: 0.3), AppColors.brandPink.withValues(alpha: 0.3)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}