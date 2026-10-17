import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// রমজান প্ল্যানার: রোজা, তারাবি, কুরআন তিলাওয়াত ট্র্যাকার
class RamadanScreen extends StatefulWidget {
  const RamadanScreen({super.key});

  @override
  State<RamadanScreen> createState() => _RamadanScreenState();
}

class _RamadanScreenState extends State<RamadanScreen> {
  int _day = 1;
  final Map<String, bool> _tasks = {};
  final List<Map<String, String>> _taskDefs = [
    {'key': 'roza', 'label': 'রোজা রেখেছি', 'icon': '🌙'},
    {'key': 'sehri', 'label': 'সেহরি খেয়েছি', 'icon': '🍽️'},
    {'key': 'iftar', 'label': 'ইফতার করেছি', 'icon': '🤲'},
    {'key': 'tarabi', 'label': 'তারাবি পড়েছি', 'icon': '🕌'},
    {'key': 'quran', 'label': 'কুরআন তিলাওয়াত', 'icon': '📖'},
    {'key': 'tahajjud', 'label': 'তাহাজ্জুদ', 'icon': '🌌'},
  ];
  int _totalRoza = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String get _key => 'ramadan_day$_day';

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final tasks = <String, bool>{};
    for (final t in _taskDefs) {
      tasks[t['key']!] = p.getBool('${_key}_${t['key']}') ?? false;
    }
    int total = 0;
    for (int d = 1; d <= 30; d++) {
      if (p.getBool('ramadan_day${d}_roza') ?? false) total++;
    }
    setState(() {
      _tasks.addAll(tasks);
      _totalRoza = total;
    });
  }

  Future<void> _toggle(String k) async {
    final p = await SharedPreferences.getInstance();
    final v = !(_tasks[k] ?? false);
    await p.setBool('${_key}_$k', v);
    setState(() => _tasks[k] = v);
    if (k == 'roza') _load();
  }

  @override
  Widget build(BuildContext context) {
    final done = _tasks.values.where((v) => v).length;
    return Scaffold(
      appBar: AppBar(title: const Text('রমজান প্ল্যানার')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: const Color(0xFF1B2A4A),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('🌙', style: TextStyle(fontSize: 44)),
                  const SizedBox(height: 8),
                  const Text('পবিত্র রমজান',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('মোট রোজা: $_totalRoza',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 15)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('দিন নির্বাচন:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _day,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                  items: List.generate(
                      30,
                      (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text('রমজান ${i + 1}'))),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _day = v);
                      _load();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: done / _taskDefs.length,
            backgroundColor: Colors.black12,
            color: const Color(0xFF0E6B3E),
            minHeight: 8,
          ),
          const SizedBox(height: 4),
          Text('$done/${_taskDefs.length} সম্পূর্ণ',
              style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 12),
          ..._taskDefs.map((t) {
            final v = _tasks[t['key']] ?? false;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: CheckboxListTile(
                title: Text('${t['icon']}  ${t['label']}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                value: v,
                activeColor: const Color(0xFF0E6B3E),
                onChanged: (_) => _toggle(t['key']!),
              ),
            );
          }),
          const SizedBox(height: 8),
          const Card(
            color: Color(0xFFE6F4EA),
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                '💡 টিপস: প্রতিদিন অন্তত ১ পারা তিলাওয়াত করলে রমজানে খতম হবে ইনশাআল্লাহ।',
                style: TextStyle(fontSize: 14, height: 1.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
