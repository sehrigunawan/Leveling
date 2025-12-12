import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengeModel {
  final String id;
  final String name;
  final String description;
  final String difficulty; // Easy, Medium, Hard
  final int duration; // Hari
  final int reward; // Koin
  final List<String> requirements;
  final List<String> tips;
  final DateTime weekStart; // Penanda minggu kapan challenge ini dibuat

  // Field khusus untuk tracking user (opsional, diisi saat fetch user data)
  final bool isTaken;
  final List<int> completedDays; // [1, 2, 3]

  ChallengeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.duration,
    required this.reward,
    required this.requirements,
    required this.tips,
    required this.weekStart,
    this.isTaken = false,
    this.completedDays = const [],
  });

  factory ChallengeModel.fromMap(String id, Map<String, dynamic> map) {
    return ChallengeModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      difficulty: map['difficulty'] ?? 'Easy',
      duration: map['duration'] ?? 1,
      reward: map['reward'] ?? 0,
      requirements: List<String>.from(map['requirements'] ?? []),
      tips: List<String>.from(map['tips'] ?? []),
      weekStart: map['weekStart'] != null 
          ? (map['weekStart'] as Timestamp).toDate() 
          : DateTime.now(),
      // User specific fields (default false/empty jika ambil dari public collection)
      isTaken: map['isTaken'] ?? false,
      completedDays: List<int>.from(map['completedDays'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'difficulty': difficulty,
      'duration': duration,
      'reward': reward,
      'requirements': requirements,
      'tips': tips,
      'weekStart': Timestamp.fromDate(weekStart),
    };
  }
}