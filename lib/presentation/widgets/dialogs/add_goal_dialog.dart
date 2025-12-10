import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/auth_widgets.dart'; 

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
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Simulasi Logic
      await Future.delayed(const Duration(seconds: 2)); 

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context, true); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Goal berhasil dibuat!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tambah Goal Baru",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Nama Goal
                // CustomTextField diambil dari auth_widgets.dart
                CustomTextField(
                  label: "Nama Goal", 
                  hint: "Cth: Belajar Web Development", 
                  icon: Icons.flag, // Tambahkan icon dummy karena widget butuh icon
                  controller: _nameController,
                ),
                const SizedBox(height: 12),

                // Skill
                CustomTextField(
                  label: "Skill/Topik", 
                  hint: "Cth: Gitar, Coding, dll", 
                  icon: Icons.lightbulb,
                  controller: _skillController,
                ),
                const SizedBox(height: 12),

                // Deskripsi (Manual TextField karena CustomTextField mungkin tidak support multiline)
                const Text("Deskripsi (Opsional)", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: "Deskripsi goal...",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 12),

                // Dropdowns
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Durasi", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: _durationDays,
                            decoration: const InputDecoration(border: OutlineInputBorder()),
                            items: const [
                              DropdownMenuItem(value: 7, child: Text("7 Hari")),
                              DropdownMenuItem(value: 30, child: Text("30 Hari")),
                            ],
                            onChanged: (val) => setState(() => _durationDays = val!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Target Harian", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: _dailyMinutes,
                            decoration: const InputDecoration(border: OutlineInputBorder()),
                            items: const [
                              DropdownMenuItem(value: 15, child: Text("15 Menit")),
                              DropdownMenuItem(value: 30, child: Text("30 Menit")),
                              DropdownMenuItem(value: 60, child: Text("60 Menit")),
                            ],
                            onChanged: (val) => setState(() => _dailyMinutes = val!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Batal"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandPurple,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _isLoading ? null : _handleSubmit,
                        child: _isLoading 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                          : const Text("Buat Goal"),
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
}