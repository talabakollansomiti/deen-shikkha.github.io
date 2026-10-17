import 'package:flutter/material.dart';

// হিজরি ক্যালেন্ডার ও কনভার্টার (গাণিতিক পদ্ধতি — চাঁদ দেখার ভিত্তিতে ১-২ দিন এদিক-ওদিক হতে পারে)
class HijriScreen extends StatefulWidget {
  const HijriScreen({super.key});

  @override
  State<HijriScreen> createState() => _HijriScreenState();
}

class _HijriScreenState extends State<HijriScreen> {
  final List<String> _months = [
    'মুহাররম', 'সফর', 'রবিউল আউয়াল', 'রবিউস সানি',
    'জুমাদাল ঊলা', 'জুমাদাস সানিয়া', 'রজব', 'শাবান',
    'রমজান', 'শাওয়াল', 'যিলকদ', 'যিলহজ্জ'
  ];
  final List<String> _bdMonths = [
    'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
    'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
  ];

  int _d = 17, _m = 10, _y = 2026;
  List<int>? _hijri;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _d = n.day;
    _m = n.month;
    _y = n.year;
    _convert();
  }

  // Gregorian -> JDN -> Hijri (tabular)
  List<int> _toHijri(int y, int m, int d) {
    final jd = ((1461 * (y + 4800 + ((m - 14) ~/ 12))) ~/ 4) +
        ((367 * (m - 2 - 12 * ((m - 14) ~/ 12))) ~/ 12) -
        ((3 * (((y + 4900 + ((m - 14) ~/ 12)) ~/ 100))) ~/ 4) +
        d -
        32075;
    var l = jd - 1948440 + 10632;
    final n = ((l - 1) ~/ 10631);
    l = l - 10631 * n + 354;
    final j = (((10985 - l) ~/ 5316)) * (((50 * l) ~/ 17719)) +
        ((l ~/ 5670)) * (((43 * l) ~/ 15238));
    l = l -
        (((30 - j) ~/ 15)) * (((17719 * j) ~/ 50)) -
        ((j ~/ 16)) * (((15238 * j) ~/ 43)) +
        29;
    final month = ((24 * l) ~/ 709);
    final day = l - ((709 * month) ~/ 24);
    final year = 30 * n + j - 30;
    return [year, month, day];
  }

  void _convert() {
    setState(() => _hijri = _toHijri(_y, _m, _d));
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayHijri = _toHijri(today.year, today.month, today.day);
    return Scaffold(
      appBar: AppBar(title: const Text('হিজরি ক্যালেন্ডার')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: const Color(0xFF0E6B3E),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  const Text('আজকের হিজরি তারিখ',
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text(
                    '${todayHijri[2]} ${_months[todayHijri[1] - 1]} ${todayHijri[0]}',
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${today.day} ${_bdMonths[today.month - 1]} ${today.year}',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('তারিখ কনভার্টার',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _numField('দিন', _d,
                      (v) => _d = v)),
              const SizedBox(width: 8),
              Expanded(
                  child: _numField('মাস', _m,
                      (v) => _m = v)),
              const SizedBox(width: 8),
              Expanded(
                  flex: 2,
                  child: _numField('বছর', _y,
                      (v) => _y = v)),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _convert,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E6B3E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('হিজরিতে দেখো',
                style: TextStyle(fontSize: 16)),
          ),
          if (_hijri != null) ...[
            const SizedBox(height: 16),
            Card(
              color: const Color(0xFFE6F4EA),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      '$_d ${_bdMonths[_m - 1]} $_y',
                      style:
                          const TextStyle(color: Colors.black54),
                    ),
                    const Icon(Icons.arrow_downward,
                        color: Color(0xFF0E6B3E)),
                    Text(
                      '${_hijri![2]} ${_months[_hijri![1] - 1]} ${_hijri![0]} হিজরি',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0E6B3E)),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Text(
            '⚠️ গাণিতিক হিসাব — চাঁদ দেখার ভিত্তিতে ১-২ দিন পার্থক্য হতে পারে।',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _numField(String label, int val, Function(int) onChanged) {
    return TextFormField(
      initialValue: '$val',
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: (v) {
        final n = int.tryParse(v);
        if (n != null) onChanged(n);
      },
    );
  }
}
