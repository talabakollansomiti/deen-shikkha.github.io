import 'package:flutter/material.dart';
import '../data/quran_loader.dart';

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
      appBar: AppBar(title: const Text('পবিত্র কুরআন')),
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
          Expanded(
            child: FutureBuilder<List<QuranSurah>>(
              future: QuranLoader.load(),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError || !snap.hasData) {
                  return const Center(child: Text('লোড করতে সমস্যা হয়েছে'));
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
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      child: ListTile(
                        leading: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E6B3E).withOpacity(0.1),
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
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text('${s.meaning} • ${s.place} • ${s.verses.length} আয়াত'),
                        trailing: Text(
                          s.arName,
                          style: const TextStyle(fontSize: 20, color: Color(0xFF0E6B3E)),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SurahReaderScreen(surah: s)),
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

class SurahReaderScreen extends StatelessWidget {
  final QuranSurah surah;
  const SurahReaderScreen({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    // সূরা ফাতিহা (১) ও তাওবা (৯) ছাড়া সব সূরার শুরুতে বিসমিল্লাহ
    final showBismillah = surah.id != 1 && surah.id != 9;

    return Scaffold(
      appBar: AppBar(
        title: Text(surah.bnName),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // হেডার
          Card(
            color: const Color(0xFF0E6B3E),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Text(
                    surah.arName,
                    style: const TextStyle(fontSize: 30, color: Colors.white),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    surah.bnName,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${surah.meaning} • ${surah.place} • ${surah.verses.length} আয়াত',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
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
                style: TextStyle(fontSize: 22, color: Color(0xFF0E6B3E)),
              ),
            ),
          // আয়াতসমূহ
          ...List.generate(surah.verses.length, (i) {
            final v = surah.verses[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E6B3E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
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
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      v.arabic,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 22, height: 2.0),
                    ),
                    const Divider(height: 24),
                    Text(
                      v.bangla,
                      style: const TextStyle(fontSize: 15, height: 1.8, color: Colors.black87),
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
