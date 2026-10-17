import 'package:flutter/material.dart';
import '../data/names99.dart';

class Names99Screen extends StatelessWidget {
  const Names99Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('আল্লাহর ৯৯ নাম')),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.05,
        ),
        itemCount: names99.length,
        itemBuilder: (context, i) {
          final n = names99[i];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${i + 1}',
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black45),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    n.arabic,
                    style: const TextStyle(
                        fontSize: 21, color: Color(0xFF0E6B3E)),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.transliteration,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    n.meaning,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
