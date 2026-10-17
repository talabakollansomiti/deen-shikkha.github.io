import 'dart:convert';
import 'package:http/http.dart' as http;
import 'quiz_data.dart';
import 'dua_data.dart';
import 'hadith_data.dart';

export 'quiz_data.dart';
export 'dua_data.dart';
export 'hadith_data.dart';

// Admin থেকে যোগ করা কনটেন্ট (GitHub Pages থেকে)
class DynamicContent {
  static const _base =
      'https://talabakollansomiti.github.io/deen-shikkha.github.io/content';

  static List<QuizQuestion> extraQuiz = [];
  static List<Dua> extraDuas = [];
  static List<Hadith> extraHadiths = [];

  static Future<void> fetch() async {
    try {
      final results = await Future.wait([
        http
            .get(Uri.parse('$_base/quiz.json'))
            .timeout(const Duration(seconds: 8)),
        http
            .get(Uri.parse('$_base/duas.json'))
            .timeout(const Duration(seconds: 8)),
        http
            .get(Uri.parse('$_base/hadiths.json'))
            .timeout(const Duration(seconds: 8)),
      ]);
      if (results[0].statusCode == 200) {
        final l = json.decode(results[0].body) as List;
        extraQuiz = l
            .map((e) => QuizQuestion(
                  question: '${e['q']}',
                  options: (e['options'] as List)
                      .map((o) => '$o')
                      .toList(),
                  correctIndex: (e['correct'] as int?) ?? 0,
                ))
            .toList();
      }
      if (results[1].statusCode == 200) {
        final l = json.decode(results[1].body) as List;
        extraDuas = l
            .map((e) => Dua(
                  title: '${e['title']}',
                  arabic: '${e['arabic']}',
                  transliteration:
                      '${e['transliteration'] ?? ''}',
                  meaning: '${e['meaning']}',
                  virtue: '${e['virtue'] ?? ''}',
                ))
            .toList();
      }
      if (results[2].statusCode == 200) {
        final l = json.decode(results[2].body) as List;
        extraHadiths = l
            .map((e) => Hadith(
                  arabic: '${e['arabic']}',
                  bangla: '${e['bangla']}',
                  source: '${e['source']}',
                  topic: '${e['topic'] ?? 'সাধারণ'}',
                ))
            .toList();
      }
    } catch (_) {
      // offline — bundled content-ই চলবে
    }
  }

  static List<QuizQuestion> get allQuiz =>
      [...quizQuestions, ...extraQuiz];
  static List<Dua> get allDuas => [...duas, ...extraDuas];
  static List<Hadith> get allHadiths =>
      [...hadiths, ...extraHadiths];
}
