import 'package:flutter/material.dart';
import '../data/quran_loader.dart';
import '../data/bookmark_service.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('পবিত্র কুরআন'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            tooltip: 'বুকমার্ক',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const BookmarksScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'সূরা খুঁজুন...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          FutureBuilder<Map<String, int>?>(
            future: BookmarkService.getLastRead(),
            builder: (context, snap) {
              if (!snap.hasData || snap.data == null) {
                return const SizedBox.shrink();
              }
              return FutureBuilder<List<QuranSurah>>(
                future: QuranLoader.load(),
                builder: (context, s2) {
                  if (!s2.hasData) return const SizedBox.shrink();
                  final lr = snap.data!;
                  final surah = s2.data!.firstWhere(
                    (e) => e.id == lr['surahId'],
                    orElse: () => s2.data![0],
                  );
                  return Container(
                    margin:
                        const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: Card(
                      color: const Color(0xFF0E6B3E),
                      child: ListTile(
                        leading: const Icon(Icons.history,
                            color: Colors.white),
                        title: const Text('শেষ পড়া',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12)),
                        subtitle: Text(
                          '${surah.bnName} : আয়াত ${lr['verseIdx']! + 1}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white70,
                            size: 18),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  SurahReaderScreen(surah: surah)),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Expanded(
            child: FutureBuilder<List<QuranSurah>>(
              future: QuranLoader.load(),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                if (snap.hasError || !snap.hasData) {
                  return const Center(
                      child: Text('লোড করতে সমস্যা হয়েছে'));
                }
                var surahs = snap.data!;
                if (_query.isNotEmpty) {
                  surahs = surahs
                      .where((s) =>
                          s.bnName.contains(_query) ||
                          s.meaning.contains(_query) ||
                          s.id.toString() == _query)
                      .toList();
                }
                return ListView.builder(
                  itemCount: surahs.length,
                  itemBuilder: (context, i) {
                    final s = surahs[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      child: ListTile(
                        leading: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E6B3E)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '${s.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0E6B3E),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          s.bnName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        subtitle: Text(
                            '${s.meaning} • ${s.place} • ${s.verses.length} আয়াত'),
                        trailing: Text(
                          s.arName,
                          style: const TextStyle(
                              fontSize: 20,
                              color: Color(0xFF0E6B3E)),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  SurahReaderScreen(surah: s)),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SurahReaderScreen extends StatefulWidget {
  final QuranSurah surah;
  const SurahReaderScreen({super.key, required this.surah});

  @override
  State<SurahReaderScreen> createState() =>
      _SurahReaderScreenState();
}

class _SurahReaderScreenState extends State<SurahReaderScreen> {
  Set<String> _bookmarks = {};

  @override
  void initState() {
    super.initState();
    BookmarkService.getBookmarks()
        .then((b) => setState(() => _bookmarks = b));
  }

  Future<void> _toggleBookmark(int idx) async {
    await BookmarkService.toggle(widget.surah.id, idx);
    await BookmarkService.setLastRead(widget.surah.id, idx);
    final b = await BookmarkService.getBookmarks();
    setState(() => _bookmarks = b);
  }

  @override
  Widget build(BuildContext context) {
    final surah = widget.surah;
    final showBismillah = surah.id != 1 && surah.id != 9;

    return Scaffold(
      appBar: AppBar(title: Text(surah.bnName)),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            color: const Color(0xFF0E6B3E),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Text(
                    surah.arName,
                    style: const TextStyle(
                        fontSize: 30, color: Colors.white),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    surah.bnName,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${surah.meaning} • ${surah.place} • ${surah.verses.length} আয়াত',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          if (showBismillah)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                    fontSize: 22, color: Color(0xFF0E6B3E)),
              ),
            ),
          ...List.generate(surah.verses.length, (i) {
            final v = surah.verses[i];
            final marked =
                _bookmarks.contains('${surah.id}_$i');
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E6B3E)
                                .withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Text(
                            'আয়াত ${i + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0E6B3E),
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            marked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: marked
                                ? const Color(0xFF0E6B3E)
                                : Colors.grey,
                          ),
                          onPressed: () =>
                              _toggleBookmark(i),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      v.arabic,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 22, height: 2.0),
                    ),
                    const Divider(height: 24),
                    Text(
                      v.bangla,
                      style: const TextStyle(
                          fontSize: 15,
                          height: 1.8,
                          color: Colors.black87),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('বুকমার্ক')),
      body: FutureBuilder<Set<String>>(
        future: BookmarkService.getBookmarks(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(
                child: CircularProgressIndicator());
          }
          final marks = snap.data!.toList();
          if (marks.isEmpty) {
            return const Center(
              child: Text(
                  'কোনো বুকমার্ক নেই\nআয়াতে বুকমার্ক আইকনে ট্যাপ করো',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54)),
            );
          }
          return FutureBuilder<List<QuranSurah>>(
            future: QuranLoader.load(),
            builder: (context, s2) {
              if (!s2.hasData) {
                return const Center(
                    child: CircularProgressIndicator());
              }
              final surahs = {
                for (var s in s2.data!) s.id: s
              };
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: marks.length,
                itemBuilder: (context, i) {
                  final parts = marks[i].split('_');
                  final sid = int.parse(parts[0]);
                  final vidx = int.parse(parts[1]);
                  final s = surahs[sid];
                  if (s == null || vidx >= s.verses.length) {
                    return const SizedBox.shrink();
                  }
                  final v = s.verses[vidx];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.bookmark,
                          color: Color(0xFF0E6B3E)),
                      title: Text(
                          '${s.bnName} : আয়াত ${vidx + 1}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                      subtitle: Text(v.bangla,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red),
                        onPressed: () async {
                          await BookmarkService.toggle(
                              sid, vidx);
                          setState(() {});
                        },
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                SurahReaderScreen(surah: s)),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
