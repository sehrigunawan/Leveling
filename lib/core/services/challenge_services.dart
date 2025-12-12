import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/challenge_model.dart';
import 'ai_services.dart';

class ChallengeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AIService _aiService = AIService();

  // --- LOGIKA UTAMA: CEK DAN GENERATE MINGGUAN ---
  Future<void> checkAndGenerateWeeklyChallenges() async {
    final now = DateTime.now();
    // Cari hari Senin minggu ini (jam 00:00)
    final mondayThisWeek = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    
    // Cek apakah sudah ada challenge untuk minggu ini
    final query = await _db.collection('challenges')
        .where('weekStart', isGreaterThanOrEqualTo: Timestamp.fromDate(mondayThisWeek))
        .limit(1)
        .get();

    // Jika KOSONG (belum ada challenge minggu ini), Generate baru!
    if (query.docs.isEmpty) {
      await _generateNewChallenges(mondayThisWeek);
    }
  }

  Future<void> _generateNewChallenges(DateTime weekStart) async {
    try {
      // 1. Panggil AI
      final challengesData = await _aiService.generateWeeklyChallenges();
      
      if (challengesData.isEmpty) return;

      // 2. Hapus challenge lama (Opsional, atau biarkan menumpuk tapi filter by date)
      // Agar hemat storage, kita hapus challenge minggu lalu
      final oldDocs = await _db.collection('challenges').get();
      for (var doc in oldDocs.docs) {
        await doc.reference.delete();
      }

      // 3. Simpan challenge baru
      final batch = _db.batch();
      for (var data in challengesData) {
        final docRef = _db.collection('challenges').doc(); // Auto ID
        data['weekStart'] = Timestamp.fromDate(weekStart); // Tambah timestamp senin
        batch.set(docRef, data);
      }
      await batch.commit();
      
    } catch (e) {
      print("Error generating challenges: $e");
    }
  }

  // --- AMBIL CHALLENGE + STATUS USER ---
  Stream<List<ChallengeModel>> getChallengesStream(String userId) {
    // 1. Ambil Data Challenge Umum
    return _db.collection('challenges')
        .orderBy('difficulty') // Sort Easy -> Hard
        .snapshots()
        .asyncMap((snapshot) async {
          List<ChallengeModel> challenges = [];
          
          for (var doc in snapshot.docs) {
            final data = doc.data();
            
            // 2. Cek apakah user sudah mengambil challenge ini
            final userProgressDoc = await _db
                .collection('users')
                .doc(userId)
                .collection('my_challenges')
                .doc(doc.id)
                .get();

            bool isTaken = userProgressDoc.exists;
            List<int> completedDays = [];
            
            if (isTaken) {
              completedDays = List<int>.from(userProgressDoc.data()?['completedDays'] ?? []);
            }

            // Gabungkan data
            final challenge = ChallengeModel.fromMap(doc.id, data);
            
            // Return model baru dengan status user
            challenges.add(ChallengeModel(
              id: challenge.id,
              name: challenge.name,
              description: challenge.description,
              difficulty: challenge.difficulty,
              duration: challenge.duration,
              reward: challenge.reward,
              requirements: challenge.requirements,
              tips: challenge.tips,
              weekStart: challenge.weekStart,
              isTaken: isTaken,
              completedDays: completedDays,
            ));
          }
          
          // Sort ulang manual karena Easy/Medium/Hard string (opsional)
          // challenges.sort(...) 
          
          return challenges;
        });
  }

  // --- AMBIL CHALLENGE (JOIN) ---
  Future<void> joinChallenge(String userId, String challengeId) async {
    await _db.collection('users').doc(userId)
        .collection('my_challenges').doc(challengeId).set({
      'joinedAt': FieldValue.serverTimestamp(),
      'completedDays': [],
      'status': 'active'
    });
  }

  // --- SELESAIKAN HARI CHALLENGE ---
  Future<void> completeChallengeDay(String userId, String challengeId, int day, int reward) async {
    final userRef = _db.collection('users').doc(userId);
    final challengeRef = userRef.collection('my_challenges').doc(challengeId);

    await _db.runTransaction((transaction) async {
      final challengeDoc = await transaction.get(challengeRef);
      if (!challengeDoc.exists) return;

      // Update Hari
      transaction.update(challengeRef, {
        'completedDays': FieldValue.arrayUnion([day])
      });

      // (Opsional) Cek jika sudah semua hari selesai, kasih Reward Koin
      // Ini butuh logic tambahan untuk cek total durasi, kita keep simple dulu:
      // Kita kasih reward kecil per hari atau reward besar di akhir? 
      // Sesuai UI React: Reward didapat di akhir. 
      // Kita simpan logic reward full di UI atau Function terpisah.
    });
  }
  
  // Claim Reward Akhir
  Future<void> claimReward(String userId, int amount) async {
     await _db.collection('users').doc(userId).update({
       'coins': FieldValue.increment(amount),
       'currentXp': FieldValue.increment(amount * 2), // XP Bonus
     });
  }
}