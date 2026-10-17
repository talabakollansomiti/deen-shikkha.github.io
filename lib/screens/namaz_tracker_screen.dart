import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NamazTrackerScreen extends StatefulWidget {
  const NamazTrackerScreen({super.key});

  @override
  State<NamazTrackerScreen> createState() => _NamazTrackerScreenState();
}

class _NamazTrackerScreenState extends State<NamazTrackerScreen> {
  final List<String> _waqts = ['ফজর', 'যোহর', 'আসর', 'মাগরিব', 'এশা'];
  Map<String, bool> _done = {};
  int _streak = 0;
  bool _loading = true;

  String get _todayKey {
    final n = DateTime.now();
    return 'namaz_${n.year}_${n.month}_${n.day}';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final done = <String, bool>{};
    for (final w in _waqts) {
      done[w] = p.getBool('${_todayKey}_$w') ?? false;
    }
    // streak হিসাব
    int streak = 0;
    var d = DateTime.now();
    // আজ সব পড়া হলে আজ থেকেই গুনো, নইলে গতকাল থেকে
    bool todayFull = done.values.every((v) => v);
    if (!todayFull) d = d.subtract(const Duration(days: 1));
    while (true) {
      final key =
          'namaz_${d.year}_${d.month}_${d.day}';
      bool full = true;
      for (final w in _waqts) {
        if (!(p.getBool('${key}_$w') ?? false)) {
          full = false;
          break;
        }
      }
      if (full) {
        streak++;
        d = d.subtract(const Duration(days: 1));
      } else {
        break;
      }
      if (streak > 365) break;
    }
    setState(() {
      _done = done;
      _streak = streak;
      _loading = false;
    });
  }

  Future<void> _toggle(String w) async {
    final p = await SharedPreferences.getInstance();
    final v = !(_done[w] ?? false);
    await p.setBool('${_todayKey}_$w', v);
    setState(() => _done[w] = v);
    if (_done.values.every((e) => e)) _load(); // streak আপডেট
  }

  @override
  Widget build(BuildContext context) {
    final completed = _done.values.where((v) => v).length;
    return Scaffold(
      appBar: AppBar(title: const Text('নামাজ ট্র্যাকার')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: const Color(0xFF0E6B3E),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 44)),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_streak দিন',
                              style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            const Text(
                              'ধারাবাহিক streak',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          '$completed/5',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: completed / 5,
                  backgroundColor: Colors.black12,
                  color: const Color(0xFF0E6B3E),
                  minHeight: 8,
                ),
                const SizedBox(height: 16),
                const Text('আজকের নামাজ',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._waqts.map((w) {
                  final v = _done[w] ?? false;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: v
                        ? const Color(0xFF0E6B3E).withOpacity(0.08)
                        : null,
                    child: CheckboxListTile(
                      title: Text(w,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              decoration: v
                                  ? TextDecoration.lineThrough
                                  : null)),
                      secondary: Icon(
                        v
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: v
                            ? const Color(0xFF0E6B3E)
                            : Colors.grey,
                        size: 30,
                      ),
                      value: v,
                      activeColor: const Color(0xFF0E6B3E),
                      onChanged: (_) => _toggle(w),
                    ),
                  );
                }),
                if (completed == 5)
                  const Card(
                    color: Color(0xFFE6F4EA),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        '🎉 মাশাআল্লাহ! আজকের ৫ ওয়াক্ত সম্পূর্ণ!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0E6B3E)),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
