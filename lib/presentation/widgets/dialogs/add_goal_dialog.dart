import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/goal_services.dart';
import '../../../core/services/ai_services.dart';
import '../../../logic/auth_logic.dart';
import '../../widgets/auth_widgets.dart'; // GradientButton

class AddGoalDialog extends StatefulWidget {
  const AddGoalDialog({super.key});

  @override
  State<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skillController = TextEditingController();
  final _descController = TextEditingController();
  
  int _durationDays = 30;
  int _dailyMinutes = 30;
  bool _isLoading = false;

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = context.read<AuthLogic>().firebaseUser;
    if (user == null) return;

    // 1. GENERATE PLAN DENGAN AI
    final aiService = AIService();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sedang menyusun kurikulum belajar dengan AI... 🤖")),
    );

    // Panggil Gemini
    final generatedPlan = await aiService.generateLearningPlan(
      goalName: _nameController.text.trim(),
      skill: _skillController.text.trim(),
      description: _descController.text.trim(),
      duration: _durationDays,
      dailyMinutes: _dailyMinutes,
    );

    // Cek jika AI gagal (list kosong)
    if (generatedPlan.isEmpty) {
      if (mounted) {
         setState(() => _isLoading = false);
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menghubungi AI atau API Key salah."), backgroundColor: Colors.red),
        );
      }
      return;
    }

    // 2. SIMPAN KE DATABASE (Sertakan dailyPlan)
    final goalService = GoalService();
    
    final result = await goalService.createGoal(
      userId: user.uid,
      name: _nameController.text.trim(),
      skill: _skillController.text.trim(),
      description: _descController.text.trim(),
      durationDays: _durationDays,
      dailyMinutes: _dailyMinutes,
      dailyPlan: generatedPlan, // <--- KIRIM DATA AI DISINI (Solusi Error)
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        Navigator.pop(context); // Tutup dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Goal berhasil dibuat dengan Kurikulum AI!"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error']), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Tambah Goal Baru", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                _buildLabel("Nama Goal"),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecor("Belajar Web Dev"),
                  validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                ),
                const SizedBox(height: 16),

                _buildLabel("Skill/Topik"),
                TextFormField(
                  controller: _skillController,
                  decoration: _inputDecor("React, Flutter, Gitar"),
                  validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                ),
                const SizedBox(height: 16),

                _buildLabel("Deskripsi (Opsional)"),
                TextFormField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: _inputDecor("Catatan tambahan..."),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Durasi"),
                          DropdownButtonFormField<int>(
                            value: _durationDays,
                            decoration: _inputDecor(""),
                            items: [7, 14, 21, 30].map((e) => DropdownMenuItem(value: e, child: Text("$e Hari"))).toList(),
                            onChanged: (val) => setState(() => _durationDays = val!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Target Harian"),
                          DropdownButtonFormField<int>(
                            value: _dailyMinutes,
                            decoration: _inputDecor(""),
                            items: [15, 30, 45, 60].map((e) => DropdownMenuItem(value: e, child: Text("$e Menit"))).toList(),
                            onChanged: (val) => setState(() => _dailyMinutes = val!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("Batal", style: TextStyle(color: AppColors.textPrimary)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        text: "Buat (AI)",
                        isLoading: _isLoading,
                        onPressed: _handleSubmit,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)));
  
  InputDecoration _inputDecor(String hint) => InputDecoration(
    hintText: hint,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
  );
}