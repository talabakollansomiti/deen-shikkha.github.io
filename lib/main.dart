import 'package:flutter/material.dart';
import 'data/remote_config.dart';
import 'data/dynamic_content.dart';
import 'data/quran_loader.dart';
import 'data/theme_service.dart';
import 'screens/quran_screen.dart';
import 'screens/quran_search_screen.dart';
import 'screens/hadith_screen.dart';
import 'screens/dua_screen.dart';
import 'screens/namaz_screen.dart';
import 'screens/namaz_times_screen.dart';
import 'screens/namaz_tracker_screen.dart';
import 'screens/tasbih_screen.dart';
import 'screens/ramadan_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/seerah_screen.dart';
import 'screens/prophets_screen.dart';
import 'screens/hajj_screen.dart';
import 'screens/names99_screen.dart';
import 'screens/zakat_screen.dart';
import 'screens/fitra_screen.dart';
import 'screens/sadaqah_screen.dart';
import 'screens/hijri_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.init();
  runApp(const DeenShikkhaApp());
}

class DeenShikkhaApp extends StatelessWidget {
  const DeenShikkhaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.mode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'দীন শিক্ষা',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0E6B3E),
              primary: const Color(0xFF4CAF7D),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0A4D2D),
              foregroundColor: Colors.white,
              centerTitle: true,
              elevation: 0,
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              color: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
          home: const _BootScreen(),
        );
      },
    );
  }
}

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
    final results = await Future.wait([
      RemoteConfig.fetch(),
      DynamicContent.fetch().then((_) => null),
    ]);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (_) =>
              HomeScreen(config: results[0] as RemoteConfig)),
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

class _MenuItem {
  final String key;
  final String title;
  final String emoji;
  final Color color;
  final Widget screen;
  const _MenuItem(
      this.key, this.title, this.emoji, this.color, this.screen);
}

class _Category {
  final String title;
  final String emoji;
  final List<_MenuItem> items;
  const _Category(this.title, this.emoji, this.items);
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

  List<_Category> _categories() => [
        _Category('📖 কুরআন ও হাদিস', '', [
          _MenuItem('quran', 'পবিত্র কুরআন', '📖',
              const Color(0xFF0E6B3E), const QuranScreen()),
          _MenuItem('quran_search', 'কুরআন সার্চ', '🔍',
              const Color(0xFF2E7D5B),
              const QuranSearchScreen()),
          _MenuItem('hadith', 'হাদিস', '💬',
              const Color(0xFF8A6D1B), const HadithScreen()),
          _MenuItem('names99', '৯৯ নাম', '🌟',
              const Color(0xFFB8860B), const Names99Screen()),
        ]),
        _Category('🕌 ইবাদত', '', [
          _MenuItem('namaz_guide', 'নামাজ শিক্ষা', '🕌',
              const Color(0xFF1B6FA8), const NamazScreen()),
          _MenuItem('namaz_times', 'নামাজের সময়', '🕐',
              const Color(0xFF1565C0),
              const NamazTimesScreen()),
          _MenuItem('namaz_tracker', 'নামাজ ট্র্যাকার', '✅',
              const Color(0xFF2E7D32),
              const NamazTrackerScreen()),
          _MenuItem('tasbih', 'তাসবীহ', '📿',
              const Color(0xFF6A1B9A), const TasbihScreen()),
          _MenuItem('ramadan', 'রমজান প্ল্যানার', '🌙',
              const Color(0xFF1B2A4A),
              const RamadanScreen()),
        ]),
        _Category('🤲 দোয়া ও যিকির', '', [
          _MenuItem('dua', 'দোয়া ও যিকির', '🤲',
              const Color(0xFFB23A48), const DuaScreen()),
        ]),
        _Category('📚 জ্ঞান', '', [
          _MenuItem('quiz', 'ইসলামিক কুইজ', '❓',
              const Color(0xFF6A4FB3), const QuizScreen()),
          _MenuItem('seerah', 'সীরাত', '📜',
              const Color(0xFF3E7C4F), const SeerahScreen()),
          _MenuItem('prophets', 'নবীদের কাহিনী', '📚',
              const Color(0xFF5D4037),
              const ProphetsScreen()),
          _MenuItem('hajj', 'হজ্জ-উমরাহ', '🕋',
              const Color(0xFF00695C), const HajjScreen()),
        ]),
        _Category('🧮 হিসাব', '', [
          _MenuItem('zakat', 'যাকাত', '🧮',
              const Color(0xFFEF6C00), const ZakatScreen()),
          _MenuItem('fitra', 'ফিতরা', '💵',
              const Color(0xFFF9A825), const FitraScreen()),
          _MenuItem('sadaqah', 'সদকা ট্র্যাকার', '💝',
              const Color(0xFFAD1457),
              const SadaqahScreen()),
        ]),
        _Category('📅 অন্যান্য', '', [
          _MenuItem('hijri', 'হিজরি ক্যালেন্ডার', '📅',
              const Color(0xFF4E342E), const HijriScreen()),
        ]),
      ];

  @override
  Widget build(BuildContext context) {
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
                ),
              ],
            ),
          ),
        ),
      );
    }

    final cats = _categories();
    final isDark = ThemeService.mode.value == ThemeMode.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF0E6B3E),
            actions: [
              IconButton(
                icon: Icon(isDark
                    ? Icons.light_mode
                    : Icons.dark_mode),
                tooltip: isDark ? 'লাইট মোড' : 'ডার্ক মোড',
                onPressed: () => ThemeService.toggle(),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0E6B3E), Color(0xFF0A4D2D)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (config.showLogo)
                        _AnimatedLogo(
                          logo: config.logo,
                          animate: config.animateLogo,
                        ),
                      const SizedBox(height: 6),
                      Text(
                        config.appName,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        config.tagline,
                        style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (config.annEnabled &&
              (config.annTitle.isNotEmpty ||
                  config.annMessage.isNotEmpty))
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
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.6),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          if (config.featEnabled)
            SliverToBoxAdapter(
              child: _FeaturedCard(config: config),
            ),
          for (final cat in cats) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 18, 16, 8),
                child: Text(
                  cat.title,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.78,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final item = cat.items[i];
                    final emoji =
                        config.menuIcons[item.key] ??
                            item.emoji;
                    return _MenuCard(
                        item: item, iconEmoji: emoji);
                  },
                  childCount: cat.items.length,
                ),
              ),
            ),
          ],
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 28),
              child: Text(
                'رَبِّ زِدْنِي عِلْمًا\n"হে আমার প্রতিপালক! আমার জ্ঞান বৃদ্ধি করুন।" — সূরা ত্বহা: ১১৪',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, height: 1.7),
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
                    builder: (_) =>
                        SurahReaderScreen(surah: s)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Text('⭐',
                        style: TextStyle(fontSize: 36)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            config.featTitle.isNotEmpty
                                ? config.featTitle
                                : 'ফিচার্ড সূরা',
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13),
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
                                  color: Colors.white70,
                                  fontSize: 13),
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

// অ্যানিমেটেড লোগো (pulse)
class _AnimatedLogo extends StatefulWidget {
  final String logo;
  final bool animate;
  const _AnimatedLogo(
      {required this.logo, required this.animate});

  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _anim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.animate) _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return Text(widget.logo,
          style: const TextStyle(fontSize: 48));
    }
    return ScaleTransition(
      scale: _anim,
      child: Text(widget.logo,
          style: const TextStyle(fontSize: 48)),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final _MenuItem item;
  final String iconEmoji;
  const _MenuCard({required this.item, required this.iconEmoji});

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
          padding: const EdgeInsets.symmetric(
              vertical: 12, horizontal: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconEmoji.isNotEmpty)
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(iconEmoji,
                        style:
                            const TextStyle(fontSize: 24)),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                item.title,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600),
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
