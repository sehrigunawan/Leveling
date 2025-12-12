import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/goal_services.dart';
import '../../../data/models/goals_model.dart';
import '../../../logic/auth_logic.dart';
import '../../widgets/auth_widgets.dart'; 
import '../../widgets/dialogs/goal_timer_dialog.dart'; 

class DailyTipsPage extends StatelessWidget {
  final GoalModel goal;
  final int dayNumber;

  const DailyTipsPage({
    super.key,
    required this.goal,
    required this.dayNumber,
  });

  @override
  Widget build(BuildContext context) {
    final DailyPlan? plan = goal.dailyPlan.any((p) => p.day == dayNumber)
        ? goal.dailyPlan.firstWhere((p) => p.day == dayNumber)
        : null;

    final String topic = plan?.topic ?? "Latihan Mandiri";
    final String description = plan?.description ?? "Lakukan latihan rutin untuk skill ini.";
    final List<String> references = plan?.references ?? [];
    final bool isCompleted = goal.completedDays.contains(dayNumber);

    return Scaffold(
      backgroundColor: AppColors.bgPurple,
      // --- PERBAIKAN 1: Mencegah error overflow saat keyboard muncul ---
      resizeToAvoidBottomInset: false, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text("Hari $dayNumber", style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      // --- PERBAIKAN 2: SafeArea agar tidak tertutup poni/tombol navigasi HP ---
      body: SafeArea( 
        child: Column(
          children: [
            // --- CONTENT AREA (Scrollable) ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul Topik
                    Text(
                      topic,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brandPurple,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Card Isi Materi
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.lightbulb_outline, color: Colors.amber),
                              SizedBox(width: 8),
                              Text("Tips / Materi", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Isi Deskripsi
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textPrimary,
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),

                          // --- SECTION REFERENSI BELAJAR ---
                          const Row(
                            children: [
                              Icon(Icons.link, color: Colors.blueAccent),
                              SizedBox(width: 8),
                              Text("Referensi Belajar:", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            ],
                          ),
                          const SizedBox(height: 12),

                          if (references.isEmpty)
                            const Text(
                              "- Tidak ada referensi khusus.",
                              style: TextStyle(color: AppColors.textMuted, fontSize: 14, fontStyle: FontStyle.italic),
                            )
                          else
                            ...references.map((ref) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("• ", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                                  Expanded(
                                    child: Text(
                                      ref,
                                      style: const TextStyle(
                                        fontSize: 14, 
                                        color: AppColors.textPrimary, 
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.blueAccent,
                                        decorationStyle: TextDecorationStyle.dotted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- BOTTOM ACTION BUTTON ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
                ],
              ),
              child: isCompleted
                  ? SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {}, 
                        icon: const Icon(Icons.check_circle),
                        label: const Text("Sudah Selesai"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    )
                  : GradientButton(
                      text: "Mulai Timer (${goal.dailyMinutes} Menit)",
                      onPressed: () {
                        _showTimer(context);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimer(BuildContext context) {
    final user = context.read<AuthLogic>().firebaseUser;
    final goalService = GoalService();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GoalTimerDialog(
        targetMinutes: goal.dailyMinutes,
        dayTitle: "Hari $dayNumber",
        onComplete: (minutes) async {
          if (user == null) return;

          await goalService.completeGoalDay(goal.id, user.uid, dayNumber, minutes);

          if (context.mounted) {
            context.pop(); 
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Yey! Hari ini selesai 🎉"), backgroundColor: Colors.green),
            );
          }
        },
      ),
    );
  }
}