import 'package:flutter/material.dart';
import '../data/dynamic_content.dart';

class DuaScreen extends StatelessWidget {
  const DuaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final allDuas = DynamicContent.allDuas;
    return Scaffold(
      appBar: AppBar(title: const Text('দোয়া ও যিকির')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: allDuas.length,
        itemBuilder: (context, i) {
          final d = allDuas[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ExpansionTile(
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFB23A48).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.favorite,
                    color: Color(0xFFB23A48), size: 22),
              ),
              title: Text(d.title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('ফজিলত: ${d.virtue}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12)),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        d.arabic,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 22, height: 2.0),
                      ),
                      const SizedBox(height: 8),
                      if (d.transliteration != '—')
                        Text(
                          d.transliteration,
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              fontStyle: FontStyle.italic,
                              height: 1.7),
                        ),
                      const Divider(height: 24),
                      const Text('অর্থ:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(d.meaning,
                          style: const TextStyle(fontSize: 15, height: 1.8)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0E6B3E).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star,
                                size: 18, color: Color(0xFF0E6B3E)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                d.virtue,
                                style: const TextStyle(
                                    fontSize: 13, color: Color(0xFF0E6B3E)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
