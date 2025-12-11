import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/auth_widgets.dart'; // Pastikan import GradientButton benar

class GoalTimerDialog extends StatefulWidget {
  final int targetMinutes;
  final String dayTitle;
  final Function(int) onComplete;

  const GoalTimerDialog({
    super.key,
    required this.targetMinutes,
    required this.dayTitle,
    required this.onComplete,
  });

  @override
  State<GoalTimerDialog> createState() => _GoalTimerDialogState();
}

class _GoalTimerDialogState extends State<GoalTimerDialog> {
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isRunning = false;
  bool _isCompleted = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    setState(() {
      _isRunning = !_isRunning;
    });

    if (_isRunning) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _secondsElapsed++;
          
          // Cek apakah target tercapai (konversi menit ke detik)
          if (_secondsElapsed >= widget.targetMinutes * 60) {
            _isCompleted = true;
            _isRunning = false;
            _timer?.cancel();
          }
        });
      });
    } else {
      _timer?.cancel();
    }
  }

  String _formatTime(int totalSeconds) {
    final m = (totalSeconds / 60).floor();
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final minutesElapsed = (_secondsElapsed / 60).floor();
    // Hitung progress (0.0 - 1.0)
    final progress = (_secondsElapsed / (widget.targetMinutes * 60)).clamp(0.0, 1.0);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(widget.dayTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text("Target: ${widget.targetMinutes} Menit", style: const TextStyle(color: AppColors.textMuted)),
            
            const SizedBox(height: 32),
            
            // Timer Display
            Text(
              _formatTime(_secondsElapsed),
              style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: AppColors.brandPurple),
            ),
            
            const SizedBox(height: 16),
            
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                color: _isCompleted ? Colors.green : AppColors.brandPurple,
                minHeight: 10,
              ),
            ),
            
            const SizedBox(height: 8),
            Text("$minutesElapsed / ${widget.targetMinutes} menit", style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),

            const SizedBox(height: 32),

            // Controls
            if (_isCompleted) ...[
              // Tampilan Saat Selesai
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Column(
                  children: [
                    Text("🎉 Target Tercapai!", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
                    SizedBox(height: 4),
                    Text("Hebat! Kamu konsisten.", style: TextStyle(color: Colors.green, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GradientButton(
                text: "Simpan Progress",
                onPressed: () {
                  widget.onComplete(minutesElapsed);
                  Navigator.pop(context);
                },
              )
            ] else ...[
              // Tombol Play/Pause/Batal
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: const Text("Batal", style: TextStyle(color: AppColors.textPrimary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _toggleTimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                      label: Text(_isRunning ? "Pause" : "Start"),
                    ),
                  ),
                ],
              ),
              
              // Opsi Selesai Lebih Awal (jika sudah berjalan minimal 1 menit)
              if (minutesElapsed > 0) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    widget.onComplete(minutesElapsed);
                    Navigator.pop(context);
                  },
                  child: Text("Selesai Sekarang ($minutesElapsed menit)", style: const TextStyle(color: AppColors.textMuted)),
                )
              ]
            ]
          ],
        ),
      ),
    );
  }
}