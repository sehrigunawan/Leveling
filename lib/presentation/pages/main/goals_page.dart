import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/goal_services.dart';
import '../../../data/models/goals_model.dart';
import '../../../logic/auth_logic.dart';
import '../../widgets/dialogs/add_goal_dialog.dart'; // Import Dialog yang baru dibuat

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthLogic>().firebaseUser;
    final goalService = GoalService();

    if (user == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: AppColors.bgPurple,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Daftar Goals", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(context: context, builder: (_) => const AddGoalDialog());
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Tambah Goal"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPurple,
                      foregroundColor: Colors.white,
                    ),
                  )
                ],
              ),
            ),

            // --- GOALS LIST (REALTIME) ---
            Expanded(
              child: StreamBuilder<List<GoalModel>>(
                stream: goalService.getUserGoals(user.uid),
                builder: (context, snapshot) {
                  // 1. Cek Error (Biasanya karena Index belum dibuat)
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Error: ${snapshot.error}", 
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final goals = snapshot.data ?? [];
                  
                  if (goals.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("📋", style: TextStyle(fontSize: 50)),
                          const SizedBox(height: 16),
                          const Text("Belum ada goal.", style: TextStyle(color: AppColors.textMuted)),
                          TextButton(
                            onPressed: () => showDialog(context: context, builder: (_) => const AddGoalDialog()),
                            child: const Text("Buat goal pertamamu sekarang!", style: TextStyle(color: AppColors.brandPurple)),
                          )
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      final goal = goals[index];
                      final progress = goal.completedDays.length / goal.durationDays;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.track_changes, color: AppColors.brandPurple),
                                    const SizedBox(width: 8),
                                    Text(goal.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.brandPurple.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(goal.status, style: const TextStyle(fontSize: 10, color: AppColors.brandPurple, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfo("Durasi", "${goal.durationDays} Hari"),
                                _buildInfo("Target", "${goal.dailyMinutes} Menit"),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Progress Bar
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Progress", style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                    Text("Hari ${goal.completedDays.length}/${goal.durationDays}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.grey.shade100,
                                  color: AppColors.brandPurple,
                                  borderRadius: BorderRadius.circular(8),
                                  minHeight: 8,
                                )
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  // TODO: Navigate to Goal Detail
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.brandPurple),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text("Lanjut", style: TextStyle(color: AppColors.brandPurple)),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}