import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// বাংলাদেশের প্রধান শহর + coordinates
const List<Map<String, dynamic>> bdCities = [
  {'name': 'ঢাকা', 'lat': 23.8103, 'lng': 90.4125},
  {'name': 'চট্টগ্রাম', 'lat': 22.3569, 'lng': 91.7832},
  {'name': 'সিলেট', 'lat': 24.8949, 'lng': 91.8692},
  {'name': 'রাজশাহী', 'lat': 24.3745, 'lng': 88.6042},
  {'name': 'খুলনা', 'lat': 22.8456, 'lng': 89.5403},
  {'name': 'বরিশাল', 'lat': 22.7010, 'lng': 90.3535},
  {'name': 'রংপুর', 'lat': 25.7439, 'lng': 89.2752},
  {'name': 'ময়মনসিংহ', 'lat': 24.7471, 'lng': 90.4203},
  {'name': 'কুমিল্লা', 'lat': 23.4607, 'lng': 91.1809},
  {'name': 'কক্সবাজার', 'lat': 21.4272, 'lng': 92.0058},
];

class NamazTimesScreen extends StatefulWidget {
  const NamazTimesScreen({super.key});

  @override
  State<NamazTimesScreen> createState() => _NamazTimesScreenState();
}

class _NamazTimesScreenState extends State<NamazTimesScreen> {
  Map<String, dynamic> _city = bdCities[0];
  Map<String, String>? _times;
  String? _hijriDate;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final p = await SharedPreferences.getInstance();
    final saved = p.getString('prayer_city');
    if (saved != null) {
      final f = bdCities.where((c) => c['name'] == saved);
      if (f.isNotEmpty) _city = f.first;
    }
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final now = DateTime.now();
      final date =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
      final url =
          'https://api.aladhan.com/v1/timings/$date?latitude=${_city['lat']}&longitude=${_city['lng']}&method=2';
      final r = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 12));
      if (r.statusCode != 200) throw Exception();
      final d = json.decode(r.body)['data'];
      final t = d['timings'] as Map<String, dynamic>;
      String fmt(String k) => (t[k] as String).substring(0, 5);
      setState(() {
        _times = {
          'ফজর': fmt('Fajr'),
          'সূর্যোদয়': fmt('Sunrise'),
          'যোহর': fmt('Dhuhr'),
          'আসর': fmt('Asr'),
          'মাগরিব': fmt('Maghrib'),
          'এশা': fmt('Isha'),
          'সেহরি শেষ': fmt('Imsak'),
        };
        final h = d['date']['hijri'];
        _hijriDate = '${h['day']} ${h['month']['en']} ${h['year']} হিজরি';
        _loading = false;
      });
      final p = await SharedPreferences.getInstance();
      await p.setString('prayer_city', _city['name'] as String);
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'সময় আনতে সমস্যা — ইন্টারনেট চেক করো';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final icons = {
      'ফজর': Icons.wb_twilight,
      'সূর্যোদয়': Icons.wb_sunny,
      'যোহর': Icons.light_mode,
      'আসর': Icons.wb_cloudy,
      'মাগরিব': Icons.nights_stay,
      'এশা': Icons.dark_mode,
      'সেহরি শেষ': Icons.restaurant,
    };
    return Scaffold(
      appBar: AppBar(title: const Text('নামাজের সময়সূচী')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF0E6B3E)),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<Map<String, dynamic>>(
                    value: _city,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                    items: bdCities
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c['name'] as String),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _city = v);
                        _fetch();
                      }
                    },
                  ),
                ),
                IconButton(
                    onPressed: _fetch, icon: const Icon(Icons.refresh)),
              ],
            ),
          ),
          if (_hijriDate != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_hijriDate!,
                  style: const TextStyle(
                      color: Color(0xFF0E6B3E),
                      fontWeight: FontWeight.w600)),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!),
                            const SizedBox(height: 12),
                            ElevatedButton(
                                onPressed: _fetch,
                                child: const Text('আবার চেষ্টা')),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(12, 4, 12, 16),
                        itemCount: _times!.length,
                        itemBuilder: (context, i) {
                          final k = _times!.keys.elementAt(i);
                          final isNext = _isNext(k, _times!);
                          return Card(
                            color: isNext
                                ? const Color(0xFF0E6B3E)
                                : null,
                            margin:
                                const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Icon(
                                icons[k] ?? Icons.access_time,
                                color: isNext
                                    ? Colors.white
                                    : const Color(0xFF0E6B3E),
                                size: 28,
                              ),
                              title: Text(k,
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: isNext
                                          ? Colors.white
                                          : null)),
                              trailing: Text(
                                _times![k]!,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isNext
                                        ? Colors.white
                                        : const Color(0xFF0E6B3E)),
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

  bool _isNext(String key, Map<String, String> times) {
    // পরবর্তী ওয়াক্ত হাইলাইট
    const order = ['ফজর', 'সূর্যোদয়', 'যোহর', 'আসর', 'মাগরিব', 'এশা'];
    if (!order.contains(key)) return false;
    final now = TimeOfDay.now();
    final nowMin = now.hour * 60 + now.minute;
    for (final k in order) {
      final parts = times[k]!.split(':');
      final m = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      if (m > nowMin) return k == key;
    }
    return key == 'ফজর'; // রাত হলে পরের ফজর
  }
}
