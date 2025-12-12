import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/challenge_services.dart';
import '../../../data/models/challenge_model.dart';
import '../../../logic/auth_logic.dart';

class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  final ChallengeService _service = ChallengeService();

  @override
  void initState() {
    super.initState();
    // Cek dan Generate Challenge saat halaman dibuka
    _service.checkAndGenerateWeeklyChallenges().then((_) {
      if (mounted) setState(() {}); // Refresh UI jika ada update
    });
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case "Easy": return Colors.green.shade100;
      case "Medium": return Colors.orange.shade100;
      case "Hard": return Colors.red.shade100;
      default: return Colors.grey.shade100;
    }
  }
  
  Color _getDifficultyTextColor(String difficulty) {
    switch (difficulty) {
      case "Easy": return Colors.green.shade800;
      case "Medium": return Colors.orange.shade800;
      case "Hard": return Colors.red.shade800;
      default: return Colors.grey.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthLogic>().firebaseUser;
    if (user == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: AppColors.bgPurple,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text("Weekly Challenges", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ),
            
            Expanded(
              child: StreamBuilder<List<ChallengeModel>>(
                stream: _service.getChallengesStream(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final challenges = snapshot.data ?? [];

                  if (challenges.isEmpty) {
                    return const Center(child: Text("Menyiapkan challenge mingguan..."));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: challenges.length,
                    itemBuilder: (context, index) {
                      final challenge = challenges[index];
                      
                      return GestureDetector(
                        onTap: () {
                          // Ke Halaman Detail
                          context.push('/challenge-detail', extra: challenge);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.bolt, color: Colors.amber),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(challenge.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                                  
                                  // Badge Difficulty
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getDifficultyColor(challenge.difficulty),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(challenge.difficulty, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getDifficultyTextColor(challenge.difficulty))),
                                  )
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(challenge.description, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("🪙 ${challenge.reward} Koin", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                                  if (challenge.isTaken)
                                    const Row(
                                      children: [
                                        Icon(Icons.check_circle, size: 16, color: Colors.blue),
                                        SizedBox(width: 4),
                                        Text("Diambil", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                                      ],
                                    )
                                  else 
                                    const Text("Lihat Detail >", style: TextStyle(color: AppColors.brandPurple, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              )
                            ],
                          ),
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
}