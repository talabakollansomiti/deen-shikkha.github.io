import 'package:flutter/material.dart';
import '../data/hajj_guide.dart';

class HajjScreen extends StatelessWidget {
  const HajjScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('হজ্জ-উমরাহ গাইড'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'হজ্জ'),
              Tab(text: 'উমরাহ'),
              Tab(text: 'তালবিয়া'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _stepsList(hajjSteps),
            _stepsList(umrahSteps),
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('তালবিয়া',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(talbiyahArabic,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 22, height: 2.0)),
                        const Divider(height: 28),
                        Text(talbiyahMeaning,
                            style: const TextStyle(
                                fontSize: 15, height: 1.8)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('ইহরামে নিষিদ্ধ কাজ',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...ihramProhibitions.map((p) => Card(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: ListTile(
                        leading: const Icon(Icons.block,
                            color: Color(0xFFB23A48)),
                        title: Text(p,
                            style: const TextStyle(fontSize: 14)),
                      ),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepsList(List<HajjStep> steps) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: steps.length,
      itemBuilder: (context, i) {
        final s = steps[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF0E6B3E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(s.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0E6B3E),
                          fontSize: 15)),
                ),
                const SizedBox(height: 10),
                Text(s.description,
                    style: const TextStyle(
                        fontSize: 15, height: 1.9)),
              ],
            ),
          ),
        );
      },
    );
  }
}
