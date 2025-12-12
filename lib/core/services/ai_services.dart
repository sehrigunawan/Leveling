import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  // Gunakan API Key yang sudah terbukti valid (berakhiran ...QVI)
  static const String _apiKey = 'AIzaSyDVOw4jcyhUCaj8nAWyPCgRH_us4ld_ljE';

  Future<List<Map<String, dynamic>>> generateLearningPlan({
    required String goalName,
    required String skill,
    required String description,
    required int duration,
    required int dailyMinutes,
  }) async {
    try {
      // --- GUNAKAN MODEL TERBARU YANG VALID ---
      // 'gemini-1.5-flash' adalah standar gratis saat ini.
      final model = GenerativeModel(
        model: 'gemini-2.5-flash-lite', 
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      final prompt = '''
      Saya ingin belajar "$skill" dengan tujuan membuat "$goalName".
      Detail tambahan: "$description".
      
      Tolong buatkan rencana belajar harian selama $duration hari.
      Saya hanya punya waktu $dailyMinutes menit per hari.

      Output WAJIB berupa JSON Array murni.
      
      Struktur per item WAJIB seperti ini:
      {
        "day": 1,
        "topic": "Judul Materi",
        "description": "Penjelasan singkat (maks 2 kalimat)",
        "references": [
           "Judul Video / Keyword Pencarian YouTube",
           "Link/Nama Dokumentasi Resmi",
           "Keyword Google Search yang spesifik"
        ]
      }
      
      Pastikan "references" berisi 2-3 sumber belajar yang valid dan spesifik untuk topik hari tersebut.
      ''';

      print("🤖 Mengirim request ke AI (gemini-1.5-flash)...");
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      final jsonString = response.text;

      if (jsonString == null) throw Exception("AI tidak memberikan respon.");

      print("📦 Respon AI diterima");

      // Bersihkan jika ada markdown ```json ... ```
      final cleanJson = jsonString
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final List<dynamic> decoded = jsonDecode(cleanJson);
      return decoded.map((e) => e as Map<String, dynamic>).toList();

    } 
    catch (e) {
      print("🔥 AI Error: $e");
      // Jika gemini-1.5-flash gagal, return list kosong agar app tidak crash
      return []; 
    }
  }
  Future<List<Map<String, dynamic>>> generateWeeklyChallenges() async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash', 
        apiKey: _apiKey,
        generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      );

      final prompt = '''
      Buatkan 3 Tantangan (Challenge) mingguan untuk pengembangan diri/belajar.
      
      Kriteria Wajib:
      1. Challenge 1: Difficulty "Easy", Durasi 1 Hari, Reward 5-10 Koin.
      2. Challenge 2: Difficulty "Medium", Durasi 3-5 Hari, Reward 20-50 Koin.
      3. Challenge 3: Difficulty "Hard", Durasi 7 Hari, Reward 50-100 Koin.
      
      Output WAJIB JSON Array murni berisi 3 objek. Struktur per objek:
      {
        "name": "Nama Challenge yang Keren",
        "description": "Deskripsi singkat menarik",
        "difficulty": "Easy" | "Medium" | "Hard",
        "duration": 1, // dalam hari
        "reward": 10, // dalam koin
        "requirements": ["Syarat 1", "Syarat 2"],
        "tips": ["Tips 1", "Tips 2"]
      }
      ''';

      print("🤖 Mengirim request Weekly Challenges ke AI...");
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      final jsonString = response.text;
      if (jsonString == null) throw Exception("AI No Response");

      // Bersihkan Markdown
      String cleanJson = jsonString.replaceAll('```json', '').replaceAll('```', '').trim();
      
      final List<dynamic> decoded = jsonDecode(cleanJson);
      return decoded.map((e) => e as Map<String, dynamic>).toList();

    } catch (e) {
      print("🔥 AI Error (Challenges): $e");
      return []; 
    }
  }
}