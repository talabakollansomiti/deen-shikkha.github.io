import 'package:flutter/material.dart';
import '../data/dynamic_content.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  String _topic = 'সব';

  @override
  Widget build(BuildContext context) {
    final allHadiths = DynamicContent.allHadiths;
    final topics = ['সব', ...{for (var h in allHadiths) h.topic}];
    final filtered = _topic == 'সব'
        ? allHadiths
        : allHadiths.where((h) => h.topic == _topic).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('হাদিস সংকলন')),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: topics.length,
              itemBuilder: (context, i) {
                final t = topics[i];
                final selected = t == _topic;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(t),
                    selected: selected,
                    selectedColor: const Color(0xFF0E6B3E),
                    labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black87),
                    onSelected: (_) => setState(() => _topic = t),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final h = filtered[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8A6D1B).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            h.topic,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8A6D1B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          h.arabic,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 20, height: 1.9),
                        ),
                        const Divider(height: 24),
                        Text(
                          h.bangla,
                          style: const TextStyle(
                              fontSize: 15, height: 1.8, color: Colors.black87),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '— ${h.source}',
                            style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
