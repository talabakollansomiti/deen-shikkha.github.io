import 'package:shared_preferences/shared_preferences.dart';

// আয়াত বুকমার্ক: "surahId:verseIndex" ফরম্যাটে সেভ
class BookmarkService {
  static const _key = 'quran_bookmarks';

  static Future<Set<String>> getBookmarks() async {
    final p = await SharedPreferences.getInstance();
    return (p.getStringList(_key) ?? []).toSet();
  }

  static Future<bool> isBookmarked(int surahId, int verseIdx) async {
    final b = await getBookmarks();
    return b.contains('${surahId}_$verseIdx');
  }

  static Future<void> toggle(int surahId, int verseIdx) async {
    final p = await SharedPreferences.getInstance();
    final b = (p.getStringList(_key) ?? []).toSet();
    final k = '${surahId}_$verseIdx';
    if (b.contains(k)) {
      b.remove(k);
    } else {
      b.add(k);
    }
    await p.setStringList(_key, b.toList());
  }

  static Future<void> setLastRead(int surahId, int verseIdx) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('quran_last_read', '${surahId}_$verseIdx');
  }

  static Future<Map<String, int>?> getLastRead() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString('quran_last_read');
    if (s == null) return null;
    final parts = s.split('_');
    return {
      'surahId': int.parse(parts[0]),
      'verseIdx': int.parse(parts[1])
    };
  }
}
