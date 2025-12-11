import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/goals_model.dart';

class GoalService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- CREATE GOAL ---
  Future<Map<String, dynamic>> createGoal({
    required String userId,
    required String name,
    required String skill,
    required String description,
    required int durationDays,
    required int dailyMinutes,
    required List<Map<String, dynamic>> dailyPlan, // <--- 1. WAJIB: Terima Data Plan dari AI
  }) async {
    try {
      // 2. Konversi List Map (JSON) menjadi List Object DailyPlan
      List<DailyPlan> planObjects = dailyPlan.map((x) => DailyPlan.fromMap(x)).toList();

      final newGoal = GoalModel(
        id: '', // ID otomatis dari Firestore nanti
        userId: userId,
        name: name,
        skill: skill,
        description: description,
        durationDays: durationDays,
        dailyMinutes: dailyMinutes,
        completedDays: [],
        status: 'active',
        createdAt: DateTime.now(),
        dailyPlan: planObjects, // <--- 3. Masukkan ke dalam Model
      );

      await _db.collection('goals').add(newGoal.toMap());
      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // --- GET USER GOALS (STREAM) ---
  Stream<List<GoalModel>> getUserGoals(String userId) {
    return _db
        .collection('goals')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return GoalModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // --- SELESAIKAN HARI (CENTANG) ---
  Future<Map<String, dynamic>> completeGoalDay(String goalId, String userId, int dayNumber, int minutesSpent) async {
    try {
      final docRef = _db.collection('goals').doc(goalId);
      
      // Update completedDays di Goal (tambah hari ke array)
      await docRef.update({
        'completedDays': FieldValue.arrayUnion([dayNumber])
      });

      // Update Total Menit User & XP (Statistik)
      final userRef = _db.collection('users').doc(userId);
      await userRef.update({
        'totalMinutes': FieldValue.increment(minutesSpent),
        'currentXp': FieldValue.increment(minutesSpent * 10), // 1 menit = 10 XP
      });

      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // --- GET SINGLE GOAL (Realtime) ---
  Stream<GoalModel> getGoalStream(String goalId) {
    return _db.collection('goals').doc(goalId).snapshots().map((doc) {
      return GoalModel.fromMap(doc.id, doc.data()!);
    });
  }
}