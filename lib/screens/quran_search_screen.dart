import 'package:flutter/material.dart';
import '../data/quran_loader.dart';
import 'quran_screen.dart' show SurahReaderScreen;

class QuranSearchScreen extends StatefulWidget {
  const QuranSearchScreen({super.key});

  @override
  State<QuranSearchScreen> createState() => _QuranSearchScreenState();
}

class _QuranSearchScreenState extends State<QuranSearchScreen> {
  final _ctrl = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _searched = false;
  List<QuranSurah>? _surahs;

  @override
  void initState() {
    super.initState();
    QuranLoader.load().then((s) => setState(() => _surahs = s));
  }

  void _search() {
    final q = _ctrl.text.trim();
    if (q.length < 2 || _surahs == null) return;
    final res = <Map<String, dynamic>>[];
    for (final s in _surahs!) {
      for (int i = 0; i < s.verses.length; i++) {
        final v = s.verses[i];
        if (v.arabic.contains(q) || v.bangla.contains(q)) {
          res.add({'surah': s, 'index': i, 'verse': v});
          if (res.length >= 100) break;
        }
      }
      if (res.length >= 100) break;
    }
    setState(() {
      _results = res;
      _searched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('কুরআনে খুঁজুন')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: InputDecoration(
                      hintText: 'আরবি বা বাংলা লিখুন...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _search,
                  icon: const Icon(Icons.search),
                  style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF0E6B3E)),
                ),
              ],
            ),
          ),
          if (_surahs == null)
            const Expanded(
                child: Center(child: CircularProgressIndicator()))
          else if (!_searched)
            const Expanded(
              child: Center(
                child: Text('কমপক্ষে ২ অক্ষর লিখে খুঁজুন',
                    style: TextStyle(color: Colors.black54)),
              ),
            )
          else if (_results.isEmpty)
            const Expanded(
              child: Center(child: Text('কিছু পাওয়া যায়নি')),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _results.length,
                itemBuilder: (context, i) {
                  final r = _results[i];
                  final s = r['surah'] as QuranSurah;
                  final v = r['verse'] as QuranVerse;
                  final idx = r['index'] as int;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(v.arabic,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 17)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '${s.bnName} : আয়াত ${idx + 1}\n${v.bangla}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      isThreeLine: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                SurahReaderScreen(surah: s)),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
