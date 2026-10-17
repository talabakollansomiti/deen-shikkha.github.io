import 'dart:convert';
import 'package:flutter/services.dart';

// quran.com API থেকে নেওয়া পুরো কুরআন (আরবি + বাংলা অনুবাদ) লোডার
class QuranVerse {
  final String arabic;
  final String bangla;
  const QuranVerse({required this.arabic, required this.bangla});

  factory QuranVerse.fromJson(List<dynamic> j) =>
      QuranVerse(arabic: j[0] as String, bangla: j[1] as String);
}

class QuranSurah {
  final int id;
  final String arName;
  final String bnName;
  final String meaning;
  final String place; // মাক্কী / মাদানী
  final List<QuranVerse> verses;
  const QuranSurah({
    required this.id,
    required this.arName,
    required this.bnName,
    required this.meaning,
    required this.place,
    required this.verses,
  });

  factory QuranSurah.fromJson(Map<String, dynamic> j) => QuranSurah(
        id: j['id'] as int,
        arName: j['ar_name'] as String,
        bnName: j['bn_name'] as String,
        meaning: j['meaning'] as String,
        place: j['place'] as String,
        verses: (j['verses'] as List).map((v) => QuranVerse.fromJson(v)).toList(),
      );
}

class QuranLoader {
  static List<QuranSurah>? _cache;

  static Future<List<QuranSurah>> load() async {
    if (_cache != null) return _cache!;
    final jsonStr = await rootBundle.loadString('assets/quran.json');
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    _cache = (data['surahs'] as List)
        .map((s) => QuranSurah.fromJson(s as Map<String, dynamic>))
        .toList();
    return _cache!;
  }
}
