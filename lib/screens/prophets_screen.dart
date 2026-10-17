import 'package:flutter/material.dart';
import '../data/prophets.dart';

class ProphetsScreen extends StatelessWidget {
  const ProphetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('নবীদের কাহিনী')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: prophets.length,
        itemBuilder: (context, i) {
          final p = prophets[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ExpansionTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF0E6B3E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text('${i + 1}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0E6B3E))),
                ),
              ),
              title: Text(p.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(p.title,
                  style:
                      const TextStyle(fontSize: 12, color: Colors.black54)),
              trailing: Text(p.arabic,
                  style: const TextStyle(
                      fontSize: 20, color: Color(0xFF0E6B3E))),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(p.story,
                      style:
                          const TextStyle(fontSize: 15, height: 1.9)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
