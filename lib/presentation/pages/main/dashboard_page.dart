import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../logic/auth_logic.dart';
import '../../../core/services/goal_services.dart';
import '../../../data/models/goals_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final Map<String, List<String>> _petEmojis = {
    'cat': ['😸', '😼'],
    'dog': ['🐕', '🦮'],
    'hamster': ['🐹', '🐹'],
  };

  @override
  Widget build(BuildContext context) {
    // 1. Ambil Data User
    final userModel = context.watch<AuthLogic>().userModel;
    final user = context.watch<AuthLogic>().firebaseUser; // Butuh UID untuk query goals
    
    // Setup Variable Tampilan
    final userName = userModel?.name ?? "Teman";
    final petName = userModel?.petName ?? "Pet-mu";
    final selectedChar = userModel?.selectedCharacter ?? "cat";
    
    final streak = userModel?.streak ?? 0;
    final totalMinutes = userModel?.totalMinutes ?? 0;
    final level = userModel?.level ?? 1;
    final currentXp = userModel?.currentXp ?? 0;
    final targetXp = userModel?.targetXp ?? 100;
    final coins = userModel?.coins ?? 0;

    final double xpProgress = (targetXp == 0) ? 0 : (currentXp / targetXp);
    final emojis = _petEmojis[selectedChar] ?? ['😸', '😸'];

    return Scaffold(
      backgroundColor: AppColors.bgPurple,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER SECTION (Tetap Sama) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.brandPurple, AppColors.brandPink, AppColors.brandOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Halo, $userName! 👋", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Text("$petName siap membantu belajar hari ini", style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.3))),
                    child: Row(
                      children: [
                        const Text("🪙", style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text("$coins", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- MAIN CONTENT (DI BUNGKUS STREAM BUILDER) ---
            // Kita bungkus area konten dengan StreamBuilder Goal agar datanya realtime
            if (user != null)
              StreamBuilder<List<GoalModel>>(
                stream: GoalService().getUserGoals(user.uid),
                builder: (context, snapshot) {
                  // Hitung Data Goals
                  final goals = snapshot.data ?? [];
                  final activeGoalsCount = goals.where((g) => g.status == 'active').length;
                  
                  // Ambil 3 Goal Terbaru
                  final recentGoals = goals.take(3).toList();

                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // 1. Stats Grid
                        Row(
                          children: [
                            // Total Goals (Sekarang Realtime!)
                            _buildStatCard("Total Goals", "$activeGoalsCount", "Sedang aktif", AppColors.brandPurple),
                            const SizedBox(width: 12),
                            _buildStatCard("Menit Latihan", "$totalMinutes", "Total menit", AppColors.brandOrange),
                            const SizedBox(width: 12),
                            _buildStatCard("Streak", "🔥 $streak", "Hari beruntun", AppColors.brandGreen),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // 2. Quick Actions
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                label: "Tambah Goal",
                                icon: Icons.add,
                                colors: [AppColors.brandPurple, AppColors.brandPink],
                                onTap: () => context.push('/goals'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildActionButton(
                                label: "Mulai Latihan",
                                icon: Icons.play_arrow_rounded,
                                colors: [AppColors.brandGreen, AppColors.brandYellow],
                                onTap: () {
                                  // Nanti arahkan ke Challenge / Timer
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // 3. Pet Progress Card (Tetap Sama)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Perkembangan Pet-mu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [Colors.purple.shade50, Colors.pink.shade50], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Column(
                                      children: [
                                        Text(emojis[0], style: const TextStyle(fontSize: 40)),
                                        Row(
                                          children: [
                                            Text(emojis[0], style: const TextStyle(fontSize: 20)),
                                            if (emojis.length > 1) Text(emojis[1], style: const TextStyle(fontSize: 20)),
                                          ],
                                        )
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(petName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          Text("Level $level • Semangat!", style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                          const SizedBox(height: 8),
                                          Container(
                                            height: 10,
                                            width: double.infinity,
                                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                            child: FractionallySizedBox(
                                              alignment: Alignment.centerLeft,
                                              widthFactor: xpProgress.clamp(0.0, 1.0),
                                              child: Container(decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.brandPurple, AppColors.brandPink]), borderRadius: BorderRadius.circular(10))),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Align(alignment: Alignment.centerRight, child: Text("$currentXp / $targetXp XP", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandPurple)))
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 4. Recent Goals List (SEKARANG REALTIME)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Goals Terbaru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  TextButton(
                                    onPressed: () => context.push('/goals'), 
                                    child: const Text("Lihat Semua", style: TextStyle(color: AppColors.textMuted))
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              
                              if (recentGoals.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text("Belum ada goal aktif.", style: TextStyle(color: AppColors.textMuted)),
                                )
                              else
                                ...recentGoals.map((goal) => _buildGoalItem(
                                  goal.name, 
                                  "${goal.dailyMinutes} menit/hari", 
                                  goal.completedDays.length, 
                                  goal.durationDays
                                )).toList(),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 100),
                      ],
                    ),
                  );
                }
              )
            else
              const Center(child: CircularProgressIndicator()) // Loading user state
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildStatCard(String title, String value, String subtitle, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 8, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required List<Color> colors, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(gradient: LinearGradient(colors: colors), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: colors[0].withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: Colors.white), const SizedBox(width: 8), Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
      ),
    );
  }

  Widget _buildGoalItem(String title, String subtitle, int current, int target) {
    double progress = target == 0 ? 0 : (current / target);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 80, height: 6,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.brandPurple, AppColors.brandPink]), borderRadius: BorderRadius.circular(6))),
                ),
              ),
              const SizedBox(height: 4),
              Text("Hari $current/$target", style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ],
          )
        ],
      ),
    );
  }
}