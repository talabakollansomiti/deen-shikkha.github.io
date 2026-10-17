import 'package:flutter/material.dart';
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
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuItem('পবিত্র কুরআন', 'নির্বাচিত সূরা — আরবি, উচ্চারণ ও অর্থসহ', Icons.menu_book, const Color(0xFF0E6B3E), const QuranScreen()),
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
