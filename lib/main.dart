import 'package:flutter/material.dart';
import 'data/remote_config.dart';
import 'data/quran_loader.dart';
import 'screens/quran_screen.dart';
import 'screens/hadith_screen.dart';
import 'screens/dua_screen.dart';
import 'screens/namaz_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/seerah_screen.dart';

void main() {
  runApp(const DeenShikkhaApp());
}

class DeenShikkhaApp extends StatelessWidget {
  const DeenShikkhaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'দীন শিক্ষা',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0E6B3E),
          primary: const Color(0xFF0E6B3E),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F5EF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0E6B3E),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: const _BootScreen(),
    );
  }
}

// Remote config লোড হওয়া পর্যন্ত splash
class _BootScreen extends StatefulWidget {
  const _BootScreen();

  @override
  State<_BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<_BootScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final cfg = await RemoteConfig.fetch();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(config: cfg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0E6B3E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🕌', style: TextStyle(fontSize: 72)),
            SizedBox(height: 16),
            Text('দীন শিক্ষা',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final RemoteConfig config;
  const HomeScreen({super.key, required this.config});

  Color _parseColor(String hex) {
    try {
      var h = hex.replaceAll('#', '');
      if (h.length == 6) h = 'FF$h';
      return Color(int.parse(h, radix: 16));
    } catch (_) {
      return const Color(0xFF0E6B3E);
    }
  }

  @override
  Widget build(BuildContext context) {
    // মেইনটেন্যান্স মোড
    if (config.maintMode) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🔧', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                const Text('মেইনটেন্যান্স চলছে',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  config.maintMsg.isNotEmpty
                      ? config.maintMsg
                      : 'শীঘ্রই ফিরে আসছি ইনশাআল্লাহ।',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final items = [
      _MenuItem('পবিত্র কুরআন', 'সম্পূর্ণ কুরআন — আরবি ও বাংলা অর্থসহ', Icons.menu_book, const Color(0xFF0E6B3E), const QuranScreen()),
      _MenuItem('হাদিস', 'সহীহ হাদিস সংকলন', Icons.format_quote, const Color(0xFF8A6D1B), const HadithScreen()),
      _MenuItem('নামাজ শিক্ষা', 'ওয়াক্ত, ওযু ও নামাজের নিয়ম', Icons.access_time, const Color(0xFF1B6FA8), const NamazScreen()),
      _MenuItem('দোয়া ও যিকির', 'দৈনন্দিন দোয়া ও ফজিলত', Icons.favorite, const Color(0xFFB23A48), const DuaScreen()),
      _MenuItem('ইসলামিক কুইজ', 'জ্ঞান যাচাই করুন', Icons.quiz, const Color(0xFF6A4FB3), const QuizScreen()),
      _MenuItem('সীরাত', 'রাসূল (সা.)-এর জীবনী', Icons.history, const Color(0xFF3E7C4F), const SeerahScreen()),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF0E6B3E),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0E6B3E), Color(0xFF0A4D2D)],
                  ),
                ),
                child: const SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🕌', style: TextStyle(fontSize: 56)),
                      SizedBox(height: 8),
                      Text(
                        'দীন শিক্ষা',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'ইসলামিক জ্ঞানের ভান্ডার',
                        style: TextStyle(fontSize: 15, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // ঘোষণা ব্যানার (admin থেকে)
          if (config.annEnabled &&
              (config.annTitle.isNotEmpty || config.annMessage.isNotEmpty))
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _parseColor(config.annColor),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.campaign,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            config.annTitle,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    if (config.annMessage.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        config.annMessage,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14, height: 1.6),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          // ফিচার্ড সূরা (admin থেকে)
          if (config.featEnabled)
            SliverToBoxAdapter(
              child: _FeaturedCard(config: config),
            ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.92,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => _MenuCard(item: items[i]),
                childCount: items.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 28),
              child: Text(
                'رَبِّ زِدْنِي عِلْمًا\n"হে আমার প্রতিপালক! আমার জ্ঞান বৃদ্ধি করুন।" — সূরা ত্বহা: ১১৪',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final RemoteConfig config;
  const _FeaturedCard({required this.config});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QuranSurah>>(
      future: QuranLoader.load(),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final surahs = snap.data!;
        final s = surahs.firstWhere(
          (e) => e.id == config.featSurahId,
          orElse: () => surahs[0],
        );
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Card(
            color: const Color(0xFF0E6B3E),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => SurahReaderScreen(surah: s)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 36)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            config.featTitle.isNotEmpty
                                ? config.featTitle
                                : 'ফিচার্ড সূরা',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'সূরা ${s.bnName}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          if (config.featDesc.isNotEmpty)
                            Text(
                              config.featDesc,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        color: Colors.white70, size: 18),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget screen;
  const _MenuItem(this.title, this.subtitle, this.icon, this.color, this.screen);
}

class _MenuCard extends StatelessWidget {
  final _MenuItem item;
  const _MenuCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => item.screen),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(item.icon, size: 30, color: item.color),
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
