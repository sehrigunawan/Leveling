import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/challenge_services.dart';
import '../../../data/models/challenge_model.dart';
import '../../../logic/auth_logic.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/dialogs/goal_timer_dialog.dart'; // Reuse Timer Goal

class ChallengeDetailPage extends StatefulWidget {
  final ChallengeModel challenge;

  const ChallengeDetailPage({super.key, required this.challenge});

  @override
  State<ChallengeDetailPage> createState() => _ChallengeDetailPageState();
}

class _ChallengeDetailPageState extends State<ChallengeDetailPage> {
  late ChallengeModel _challenge; // Local state untuk update UI real-time

  @override
  void initState() {
    super.initState();
    _challenge = widget.challenge;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthLogic>().firebaseUser;
    final service = ChallengeService();
    final progressPercent = _challenge.duration == 0 ? 0.0 : (_challenge.completedDays.length / _challenge.duration);
    
    // Tentukan target menit berdasarkan difficulty (Hardcode logic sesuai React code)
    int targetMinutes = 30; // Default Medium
    if (_challenge.difficulty == "Easy") targetMinutes = 10;
    if (_challenge.difficulty == "Hard") targetMinutes = 45;

    return Scaffold(
      backgroundColor: AppColors.bgPurple,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text("Detail Challenge", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER CARD ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_challenge.difficulty, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.brandPurple)),
                      Text("🪙 ${_challenge.reward} Koin", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_challenge.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_challenge.description, style: const TextStyle(color: AppColors.textMuted)),
                  const SizedBox(height: 24),
                  
                  if (!_challenge.isTaken)
                    GradientButton(
                      text: "Ambil Challenge Ini",
                      onPressed: () async {
                        await service.joinChallenge(user!.uid, _challenge.id);
                        setState(() {
                          // Update local state biar UI berubah jadi 'Taken'
                          _challenge = ChallengeModel(
                            id: _challenge.id,
                            name: _challenge.name,
                            description: _challenge.description,
                            difficulty: _challenge.difficulty,
                            duration: _challenge.duration,
                            reward: _challenge.reward,
                            requirements: _challenge.requirements,
                            tips: _challenge.tips,
                            weekStart: _challenge.weekStart,
                            isTaken: true, // <--- Jadi True
                            completedDays: [],
                          );
                        });
                      },
                    )
                  else
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Progress: ${_challenge.completedDays.length}/${_challenge.duration} Hari", style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text("${(progressPercent * 100).toInt()}%", style: const TextStyle(color: AppColors.brandPurple, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: progressPercent, color: AppColors.brandPurple, backgroundColor: Colors.grey[100]),
                      ],
                    )
                ],
              ),
            ),

            if (_challenge.isTaken) ...[
              const SizedBox(height: 24),
              const Text("Kalender Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              // --- GRID HARI ---
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, 
                  crossAxisSpacing: 10, mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: _challenge.duration,
                itemBuilder: (context, index) {
                  final dayNum = index + 1;
                  final isDone = _challenge.completedDays.contains(dayNum);

                  return GestureDetector(
                    onTap: () {
                      if (isDone) return;
                      // Buka Timer
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => GoalTimerDialog(
                          targetMinutes: targetMinutes, 
                          dayTitle: "Challenge Hari $dayNum", 
                          onComplete: (minutes) async {
                            // Simpan Progress
                            await service.completeChallengeDay(user!.uid, _challenge.id, dayNum, minutes);
                            
                            // Cek jika ini hari terakhir (Selesai Challenge)
                            if (_challenge.completedDays.length + 1 == _challenge.duration) {
                               await service.claimReward(user.uid, _challenge.reward);
                               if (context.mounted) {
                                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("CHALLENGE COMPLETE! +Koin"), backgroundColor: Colors.amber));
                               }
                            }

                            // Update UI Local
                            setState(() {
                              _challenge.completedDays.add(dayNum);
                            });
                          }
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDone ? Colors.green : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDone ? Colors.transparent : Colors.grey.shade300),
                      ),
                      child: Center(
                        child: isDone 
                          ? const Icon(Icons.check, color: Colors.white)
                          : Text("Hari\n$dayNum", textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                },
              ),
            ],

            // --- TIPS & REQUIREMENTS ---
            const SizedBox(height: 24),
            _InfoListCard(title: "Syarat", items: _challenge.requirements, icon: Icons.rule),
            const SizedBox(height: 16),
            _InfoListCard(title: "Tips & Trik", items: _challenge.tips, icon: Icons.lightbulb, bgColor: Colors.amber.shade50),
          ],
        ),
      ),
    );
  }
}

class _InfoListCard extends StatelessWidget {
  final String title;
  final List<String> items;
  final IconData icon;
  final Color bgColor;

  const _InfoListCard({required this.title, required this.items, required this.icon, this.bgColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
          const SizedBox(height: 12),
          ...items.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(child: Text(e, style: const TextStyle(fontSize: 14))),
            ]),
          ))
        ],
      ),
    );
  }
}