import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/goal_services.dart';
import '../../../data/models/goals_model.dart';
import '../../../logic/auth_logic.dart';
import '../../widgets/dialogs/goal_timer_dialog.dart';

class GoalDetailPage extends StatelessWidget {
  final String goalId;

  const GoalDetailPage({super.key, required this.goalId});

  @override
  Widget build(BuildContext context) {
    final goalService = GoalService();
    // Kita butuh UID user untuk update statistik saat timer selesai
    final user = context.read<AuthLogic>().firebaseUser;

    return Scaffold(
      backgroundColor: AppColors.bgPurple, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text("Detail Goal", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<GoalModel>(
        stream: goalService.getGoalStream(goalId),
        builder: (context, snapshot) {
          // Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Error State
          if (!snapshot.hasData) {
            return const Center(child: Text("Goal tidak ditemukan"));
          }

          final goal = snapshot.data!;
          final progress = goal.durationDays == 0 ? 0.0 : (goal.completedDays.length / goal.durationDays);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER CARD (INFO GOAL) ---
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul & Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              goal.name,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.brandPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(goal.status.toUpperCase(), style: const TextStyle(color: AppColors.brandPurple, fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                      Text(goal.skill, style: const TextStyle(color: AppColors.textMuted)),
                      
                      const SizedBox(height: 24),
                      
                      // Info Grid (Durasi & Target)
                      Row(
                        children: [
                          _InfoBadge(icon: Icons.timer, label: "Target Harian", value: "${goal.dailyMinutes} m"),
                          const SizedBox(width: 24),
                          _InfoBadge(icon: Icons.calendar_today, label: "Total Durasi", value: "${goal.durationDays} h"),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Progress Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Progress", style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          Text("Hari ${goal.completedDays.length}/${goal.durationDays}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: Colors.grey[100],
                          color: AppColors.brandPurple,
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                
                // --- KALENDER HARIAN (GRID) ---
                Text("Kalender Harian (1-${goal.durationDays})", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // Menggunakan GridView untuk menampilkan kartu hari
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 Kartu per baris
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3, // Proporsi kartu
                  ),
                  itemCount: goal.durationDays,
                  itemBuilder: (context, index) {
                    final dayNum = index + 1;
                    
                    // Cek apakah hari ini sudah selesai
                    final isCompleted = goal.completedDays.contains(dayNum);
                    
                    // Ambil detail dari dailyPlan AI (jika tersedia)
                    String title = "Hari $dayNum";
                    String desc = "Fokus belajar rutin";
                    
                    // Logic aman: Cek jika index ada di dalam list dailyPlan
                    if (index < goal.dailyPlan.length) {
                      title = goal.dailyPlan[index].topic;
                      desc = goal.dailyPlan[index].description;
                    }

                    return GestureDetector(
                      onTap: () {
                        context.push(
                          '/daily-tips', 
                          extra: {
                            'goal': goal,
                            'day': dayNum,
                          }
                        );
                      },

                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          // Jika selesai: Gradient Ungu. Jika belum: Putih.
                          color: isCompleted ? AppColors.brandPurple : Colors.white,
                          gradient: isCompleted 
                              ? const LinearGradient(colors: [AppColors.brandPurple, AppColors.brandPink], begin: Alignment.topLeft, end: Alignment.bottomRight)
                              : null,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isCompleted ? Colors.transparent : AppColors.border),
                          boxShadow: [
                            if (!isCompleted) 
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Kartu (Hari ke-X + Icon Check)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Hari $dayNum", 
                                  style: TextStyle(
                                    fontSize: 12, 
                                    fontWeight: FontWeight.bold, 
                                    color: isCompleted ? Colors.white : AppColors.textPrimary
                                  )
                                ),
                                if (isCompleted) 
                                  const Icon(Icons.check_circle, color: Colors.white, size: 18),
                              ],
                            ),
                            
                            const Spacer(),
                            
                            // Topik Belajar
                            Text(
                              title, 
                              style: TextStyle(
                                fontSize: 14, 
                                fontWeight: FontWeight.bold, 
                                color: isCompleted ? Colors.white : AppColors.textPrimary
                              ),
                              maxLines: 2, 
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            // Deskripsi Singkat
                            Text(
                              desc, 
                              style: TextStyle(
                                fontSize: 10, 
                                color: isCompleted ? Colors.white.withOpacity(0.8) : AppColors.textMuted
                              ),
                              maxLines: 2, 
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Widget Kecil untuk Info Icon + Teks
// PASTIKAN CLASS INI ADA DI BAGIAN BAWAH FILE
class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoBadge({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.bgPurple, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: AppColors.brandPurple),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }
}