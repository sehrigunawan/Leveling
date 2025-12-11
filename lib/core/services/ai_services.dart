import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static const String _apiKey = 'AIzaSyA2gHaXgs9DAnTOJAxURzsoTWpk9eMewek';

  Future<List<Map<String, dynamic>>> generateLearningPlan({
    required String goalName,
    required String skill,
    required String description,
    required int duration,
    required int dailyMinutes,
  }) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash', 
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      final prompt = '''
      Saya ingin belajar "$skill" dengan tujuan membuat "$goalName".
      Detail tambahan: "$description".
      
      Tolong buatkan rencana belajar harian selama $duration hari.
      Saya hanya punya waktu $dailyMinutes menit per hari, jadi buat materinya padat dan spesifik.

      Output WAJIB berupa JSON Array murni tanpa markdown, dengan struktur:
      {
        "day": 1,
        "topic": "Judul Materi",
        "description": "Penjelasan singkat (maks 2 kalimat)"
      }
      ''';

      final response = await model.generateContent([
        Content.text(prompt)
      ]);

      final jsonString = response.text;

      if (jsonString == null) throw Exception("AI tidak memberikan respon.");

      final List<dynamic> decoded = jsonDecode(jsonString);

      return decoded.map((e) => e as Map<String, dynamic>).toList();

    } catch (e) {
      print("AI Error: $e");
      return [];
    }
  }
}
