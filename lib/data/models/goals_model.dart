// 1. Class Kecil untuk Rencana Harian
class DailyPlan {
  final int day;
  final String topic;
  final String description;
  final bool isCompleted;
  // --- FIELD BARU ---
  final List<String> references; 

  DailyPlan({
    required this.day,
    required this.topic,
    required this.description,
    this.isCompleted = false,
    this.references = const [], // Default kosong
  });

  factory DailyPlan.fromMap(Map<String, dynamic> map) {
    return DailyPlan(
      day: map['day'] ?? 0,
      topic: map['topic'] ?? '',
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      // --- AMBIL LIST REFERENSI DARI JSON ---
      references: List<String>.from(map['references'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'topic': topic,
      'description': description,
      'isCompleted': isCompleted,
      // --- SIMPAN KE DATABASE ---
      'references': references,
    };
  }
}

// ... (Class GoalModel di bawahnya biarkan tetap sama)

// 2. Class Utama GoalModel
class GoalModel {
  final String id;
  final String userId;
  final String name;
  final String skill;
  final String description;
  final int durationDays;
  final int dailyMinutes;
  final List<int> completedDays; // Array hari yang selesai (e.g. [1, 2, 5])
  final String status; // 'active', 'completed', 'dropped'
  final DateTime createdAt;
  
  // FIELD BARU: List Rencana Harian dari AI
  final List<DailyPlan> dailyPlan; 

  GoalModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.skill,
    required this.description,
    required this.durationDays,
    required this.dailyMinutes,
    required this.completedDays,
    required this.status,
    required this.createdAt,
    required this.dailyPlan, // <--- Wajib ada
  });

  // Dari Firestore ke Dart
  factory GoalModel.fromMap(String id, Map<String, dynamic> data) {
    return GoalModel(
      id: id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      skill: data['skill'] ?? '',
      description: data['description'] ?? '',
      durationDays: data['durationDays'] ?? 30,
      dailyMinutes: data['dailyMinutes'] ?? 30,
      completedDays: List<int>.from(data['completedDays'] ?? []),
      status: data['status'] ?? 'active',
      createdAt: data['createdAt'] != null 
          ? DateTime.parse(data['createdAt']) 
          : DateTime.now(),
      
      // LOGIKA PARSING DAILY PLAN (PENTING)
      dailyPlan: (data['dailyPlan'] as List<dynamic>?)
          ?.map((x) => DailyPlan.fromMap(x as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  // Dari Dart ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'skill': skill,
      'description': description,
      'durationDays': durationDays,
      'dailyMinutes': dailyMinutes,
      'completedDays': completedDays,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      
      // LOGIKA SIMPAN DAILY PLAN
      'dailyPlan': dailyPlan.map((x) => x.toMap()).toList(),
    };
  }
}