import 'package:flutter/material.dart';
import '../data/seerah_data.dart';

class SeerahScreen extends StatelessWidget {
  const SeerahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('সীরাত'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'জীবনী'),
              Tab(text: 'পরিবার'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: seerahEvents.length,
              itemBuilder: (context, i) {
                final e = seerahEvents[i];
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Color(0xFF3E7C4F),
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (i < seerahEvents.length - 1)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: const Color(0xFF3E7C4F)
                                    .withOpacity(0.3),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3E7C4F)
                                        .withOpacity(0.12),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    e.year,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3E7C4F),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  e.title,
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  e.description,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.8,
                                      color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: prophetFamily.length,
              itemBuilder: (context, i) {
                final f = prophetFamily[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.person,
                        color: Color(0xFF3E7C4F)),
                    title: Text(f['name']!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    subtitle: Text(f['value']!,
                        style: const TextStyle(fontSize: 14)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
