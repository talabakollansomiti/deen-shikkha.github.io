import 'package:flutter/material.dart';
import '../data/namaz_data.dart';

class NamazScreen extends StatelessWidget {
  const NamazScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('নামাজ শিক্ষা'),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'ওয়াক্ত ও রাকাত'),
              Tab(text: 'ওযুর নিয়ম'),
              Tab(text: 'নামাজের নিয়ম'),
              Tab(text: 'দোয়া সমূহ'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _WaqtTab(),
            _StepsTab(title: 'ওযুর নিয়ম (১১ ধাপ)', steps: wuduSteps, breakers: wuduBreakers, breakerTitle: 'ওযু ভঙ্গের কারণ'),
            _StepsTab(title: 'নামাজ পড়ার নিয়ম', steps: namazSteps, breakers: namazBreakers, breakerTitle: 'নামাজ ভঙ্গের কারণ'),
            _DuaTab(),
          ],
        ),
      ),
    );
  }
}

class _WaqtTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: namazTimes.length,
      itemBuilder: (context, i) {
        final n = namazTimes[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B6FA8).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.access_time, color: Color(0xFF1B6FA8)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.name,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(n.time,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                _RakatRow('সুন্নত', n.sunnat),
                _RakatRow('ফরজ', n.farz),
                _RakatRow('নফল/বিতর', n.nafl),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RakatRow extends StatelessWidget {
  final String label;
  final String value;
  const _RakatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

class _StepsTab extends StatelessWidget {
  final String title;
  final List<String> steps;
  final List<String> breakers;
  final String breakerTitle;
  const _StepsTab(
      {required this.title,
      required this.steps,
      required this.breakers,
      required this.breakerTitle});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...steps.map((s) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(s, style: const TextStyle(fontSize: 15, height: 1.7)),
              ),
            )),
        const SizedBox(height: 12),
        Text(breakerTitle,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB23A48))),
        const SizedBox(height: 8),
        ...breakers.map((b) => Card(
              color: const Color(0xFFB23A48).withOpacity(0.06),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.warning_amber,
                    color: Color(0xFFB23A48), size: 20),
                title: Text(b, style: const TextStyle(fontSize: 14)),
              ),
            )),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _DuaTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _DuaCard(
          'সানা',
          sanaArabic,
          sanaMeaning,
        ),
        _DuaCard(
          'তাশাহহুদ (আত্তাহিয়্যাতু)',
          tashahhudArabic,
          tashahhudMeaning,
        ),
      ],
    );
  }
}

class _DuaCard extends StatelessWidget {
  final String title;
  final String arabic;
  final String meaning;
  const _DuaCard(this.title, this.arabic, this.meaning);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              arabic,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 20, height: 2.0),
            ),
            const Divider(height: 24),
            Text(meaning,
                style: const TextStyle(fontSize: 15, height: 1.8)),
          ],
        ),
      ),
    );
  }
}
