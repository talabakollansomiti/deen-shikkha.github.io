import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/alarm_service.dart';
import 'hijri_screen.dart';

// বাংলা সংখ্যায় রূপান্তর
String bn(String s) {
  const en = '0123456789';
  const b = '০১২৩৪৫৬৭৮৯';
  var r = s;
  for (int i = 0; i < 10; i++) {
    r = r.replaceAll(en[i], b[i]);
  }
  return r;
}

const List<Map<String, dynamic>> bdCities = [
  {'name': 'ঢাকা', 'lat': 23.8103, 'lng': 90.4125},
  {'name': 'চট্টগ্রাম', 'lat': 22.3569, 'lng': 91.7832},
  {'name': 'সিলেট', 'lat': 24.8949, 'lng': 91.8692},
  {'name': 'রাজশাহী', 'lat': 24.3745, 'lng': 88.6042},
  {'name': 'খুলনা', 'lat': 22.8456, 'lng': 89.5403},
  {'name': 'বরিশাল', 'lat': 22.7010, 'lng': 90.3535},
  {'name': 'রংপুর', 'lat': 25.7439, 'lng': 89.2752},
  {'name': 'ময়মনসিংহ', 'lat': 24.7471, 'lng': 90.4203},
  {'name': 'সিরাজগঞ্জ', 'lat': 24.4534, 'lng': 89.7005},
  {'name': 'কুমিল্লা', 'lat': 23.4607, 'lng': 91.1809},
  {'name': 'কক্সবাজার', 'lat': 21.4272, 'lng': 92.0058},
  {'name': 'দিনাজপুর', 'lat': 25.6217, 'lng': 88.6355},
  {'name': 'বগুড়া', 'lat': 24.8466, 'lng': 89.3776},
  {'name': 'যশোর', 'lat': 23.1697, 'lng': 89.2137},
];

class PrayerInfo {
  final String name;
  final String emoji;
  final int startMin; // দিনের শুরু থেকে মিনিট
  final int endMin;
  PrayerInfo(this.name, this.emoji, this.startMin, this.endMin);
}

class NamazTimesScreen extends StatefulWidget {
  const NamazTimesScreen({super.key});

  @override
  State<NamazTimesScreen> createState() =>
      _NamazTimesScreenState();
}

class _NamazTimesScreenState
    extends State<NamazTimesScreen> {
  Map<String, dynamic> _city = bdCities[0];
  List<PrayerInfo> _prayers = [];
  String? _hijriDate;
  String? _bnDate;
  String _sunrise = '';
  String _sunset = '';
  bool _loading = true;
  String? _error;
  Timer? _timer;
  Map<String, bool> _alarms = {};
  Duration _remaining = Duration.zero;
  String _statusLabel = '';
  PrayerInfo? _current;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _init();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (_) {
      _tick();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    final p = await SharedPreferences.getInstance();
    final saved = p.getString('prayer_city');
    if (saved != null) {
      final f = bdCities.where((c) => c['name'] == saved);
      if (f.isNotEmpty) _city = f.first;
    }
    for (final pr in ['ফজর', 'যোহর', 'আসর', 'মাগরিব', 'এশা']) {
      _alarms[pr] = p.getBool('alarm_$pr') ?? false;
    }
    _fetch();
  }

  int _toMin(String t) {
    final p = t.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  String _fmtMin(int m) {
    m = m % 1440;
    final h = (m ~/ 60).toString().padLeft(2, '0');
    final mm = (m % 60).toString().padLeft(2, '0');
    return '$h:$mm';
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
      String fmt(String k) =>
          (t[k] as String).substring(0, 5);

      final fajr = _toMin(fmt('Fajr'));
      final sunrise = _toMin(fmt('Sunrise'));
      final dhuhr = _toMin(fmt('Dhuhr'));
      final asr = _toMin(fmt('Asr'));
      final maghrib = _toMin(fmt('Maghrib'));
      final isha = _toMin(fmt('Isha'));

      _prayers = [
        PrayerInfo('ফজর', '🌅', fajr, sunrise),
        PrayerInfo('যোহর', '☀️', dhuhr, asr),
        PrayerInfo('আসর', '🌤️', asr, maghrib),
        PrayerInfo('মাগরিব', '🌇', maghrib, maghrib + 75),
        PrayerInfo('এশা', '🌙', isha, fajr + 1440),
      ];
      _sunrise = fmt('Sunrise');
      _sunset = fmt('Sunset');

      final h = d['date']['hijri'];
      const hjMonths = [
        'মুহাররম', 'সফর', 'রবিউল আউয়াল', 'রবিউস সানি',
        'জুমাদাল ঊলা', 'জুমাদাস সানিয়া', 'রজব', 'শাবান',
        'রমজান', 'শাওয়াল', 'যিলকদ', 'যিলহজ্জ'
      ];
      final hm = int.tryParse('${h['month']['number']}') ?? 1;
      _hijriDate =
          '${h['day']} ${hjMonths[hm - 1]} ${h['year']}';

      const bdMonths = [
        'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল',
        'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর',
        'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
      ];
      const bdDays = [
        'সোম', 'মঙ্গল', 'বুধ', 'বৃহস্পতি',
        'শুক্র', 'শনি', 'রবি'
      ];
      _bnDate =
          '${bdDays[now.weekday - 1]}, ${now.day} ${bdMonths[now.month - 1]}';

      // অ্যালার্ম রি-শিডিউল
      final p = await SharedPreferences.getInstance();
      for (final pr in _prayers) {
        if (p.getBool('alarm_${pr.name}') ?? false) {
          await AlarmService().setAlarm(pr.name,
              pr.startMin ~/ 60, pr.startMin % 60);
        }
      }

      setState(() => _loading = false);
      _tick();
      await p.setString(
          'prayer_city', _city['name'] as String);
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'সময় আনতে সমস্যা — ইন্টারনেট চেক করো';
      });
    }
  }

  void _tick() {
    if (_prayers.isEmpty || !mounted) return;
    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;
    final nowSec = nowMin * 60 + now.second;

    PrayerInfo? current;
    PrayerInfo? next;
    String label;
    int targetSec;

    for (int i = 0; i < _prayers.length; i++) {
      final pr = _prayers[i];
      if (nowMin >= pr.startMin && nowMin < pr.endMin) {
        current = pr;
        break;
      }
    }

    if (current != null) {
      // ওয়াক্ত চলছে — শেষ হতে বাকি
      label = 'শেষ হতে বাকি';
      targetSec = current.endMin * 60;
      final total = (current.endMin - current.startMin) * 60;
      final elapsed = nowSec - current.startMin * 60;
      _progress = (elapsed / total).clamp(0.0, 1.0);
      _current = current;
    } else {
      // পরের ওয়াক্ত খুঁজো
      for (final pr in _prayers) {
        if (pr.startMin > nowMin) {
          next = pr;
          break;
        }
      }
      next ??= _prayers[0]; // আগামীকাল ফজর
      label = 'শুরু হতে বাকি';
      var startSec = next.startMin * 60;
      if (startSec <= nowSec) startSec += 24 * 3600;
      targetSec = startSec;
      _progress = 0;
      _current = next;
    }

    var diff = targetSec - nowSec;
    if (diff < 0) diff += 24 * 3600;
    setState(() {
      _remaining = Duration(seconds: diff);
      _statusLabel = label;
    });
  }

  String _fmtDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m =
        (d.inMinutes % 60).toString().padLeft(2, '0');
    final s =
        (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Future<void> _toggleAlarm(PrayerInfo pr) async {
    final p = await SharedPreferences.getInstance();
    final v = !(_alarms[pr.name] ?? false);
    setState(() => _alarms[pr.name] = v);
    await p.setBool('alarm_${pr.name}', v);
    if (v) {
      await AlarmService()
          .setAlarm(pr.name, pr.startMin ~/ 60, pr.startMin % 60);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '🔔 ${pr.name}-এর অ্যালার্ম চালু (${bn(_fmtMin(pr.startMin))})'),
              backgroundColor: const Color(0xFF0E6B3E)),
        );
      }
    } else {
      await AlarmService().cancelAlarm(pr.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5EF),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: _fetch,
                          child:
                              const Text('আবার চেষ্টা')),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFFFF9DB),
                              Color(0xFFDDF3D5)
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft:
                                Radius.circular(28),
                            bottomRight:
                                Radius.circular(28),
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                20, 12, 20, 24),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                        Icons.calendar_month,
                                        size: 28),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                          bn(_hijriDate ??
                                              ''),
                                          style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight:
                                                  FontWeight
                                                      .bold),
                                        ),
                                        Text(
                                          bn(_bnDate ?? ''),
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors
                                                  .black54),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(
                                          Icons.refresh),
                                      onPressed: _fetch,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // আর্ক + কাউন্টডাউন
                                SizedBox(
                                  width: 230,
                                  height: 190,
                                  child: CustomPaint(
                                    painter: _ArcPainter(
                                        _progress),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                        children: [
                                          Text(
                                            _current?.name ??
                                                '',
                                            style: const TextStyle(
                                                fontSize: 26,
                                                fontWeight:
                                                    FontWeight
                                                        .bold),
                                          ),
                                          Text(
                                            _statusLabel,
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors
                                                    .black54),
                                          ),
                                          const SizedBox(
                                              height: 4),
                                          Text(
                                            bn(_fmtDuration(
                                                _remaining)),
                                            style: const TextStyle(
                                                fontSize: 30,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                                fontFeatures: [
                                                  FontFeature
                                                      .tabularFigures()
                                                ]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  children: [
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withOpacity(
                                                0.7),
                                        borderRadius:
                                            BorderRadius.circular(
                                                20),
                                      ),
                                      child: DropdownButton<
                                          Map<String,
                                              dynamic>>(
                                        value: _city,
                                        underline:
                                            const SizedBox
                                                .shrink(),
                                        isDense: true,
                                        icon: const Icon(
                                            Icons
                                                .keyboard_arrow_down,
                                            size: 18),
                                        items: bdCities
                                            .map((c) =>
                                                DropdownMenuItem(
                                                  value: c,
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize
                                                            .min,
                                                    children: [
                                                      const Icon(
                                                          Icons
                                                              .location_on,
                                                          size:
                                                              16,
                                                          color: Color(
                                                              0xFF0E6B3E)),
                                                      const SizedBox(
                                                          width:
                                                              4),
                                                      Text(c['name']
                                                          as String),
                                                    ],
                                                  ),
                                                ))
                                            .toList(),
                                        onChanged: (v) {
                                          if (v !=
                                              null) {
                                            setState(() =>
                                                _city =
                                                    v);
                                            _fetch();
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withOpacity(
                                                0.7),
                                        borderRadius:
                                            BorderRadius.circular(
                                                20),
                                      ),
                                      child: Text(
                                        '🌅 ${bn(_sunrise)}  |  🌇 ${bn(_sunset)}',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight:
                                                FontWeight
                                                    .w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(14),
                      sliver: SliverList(
                        delegate:
                            SliverChildBuilderDelegate(
                          (context, i) {
                            final pr = _prayers[i];
                            final isCur =
                                _current?.name ==
                                    pr.name;
                            final alarmOn =
                                _alarms[pr.name] ??
                                    false;
                            return Card(
                              color: isCur
                                  ? const Color(
                                          0xFF0E6B3E)
                                      .withOpacity(0.08)
                                  : null,
                              margin:
                                  const EdgeInsets.only(
                                      bottom: 8),
                              child: ListTile(
                                leading: Text(pr.emoji,
                                    style:
                                        const TextStyle(
                                            fontSize:
                                                28)),
                                title: Text(
                                  pr.name,
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                          FontWeight.bold,
                                      color: isCur
                                          ? const Color(
                                              0xFF0E6B3E)
                                          : null),
                                ),
                                subtitle: Text(
                                  '${bn(_fmtMin(pr.startMin))} - ${bn(_fmtMin(pr.endMin))}',
                                  style:
                                      const TextStyle(
                                          fontSize: 15),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    alarmOn
                                        ? Icons.alarm_on
                                        : Icons.alarm,
                                    color: alarmOn
                                        ? const Color(
                                            0xFF0E6B3E)
                                        : Colors.grey,
                                  ),
                                  tooltip: alarmOn
                                      ? 'অ্যালার্ম বন্ধ করো'
                                      : 'অ্যালার্ম চালু করো',
                                  onPressed: () =>
                                      _toggleAlarm(pr),
                                ),
                              ),
                            );
                          },
                          childCount: _prayers.length,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(
                                16, 0, 16, 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(
                                          context)
                                      .showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            '🔔 প্রতিটি নামাজের পাশে ঘণ্টা আইকনে ট্যাপ করে অ্যালার্ম চালু করো')),
                                  );
                                },
                                icon: const Icon(
                                    Icons.alarm),
                                label: const Text(
                                    'অ্যালার্ম'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const HijriScreen()),
                                ),
                                icon: const Icon(Icons
                                    .calendar_month),
                                label: const Text(
                                    'ক্যালেন্ডার'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

// বৃত্তাকার প্রোগ্রেস আর্ক
class _ArcPainter extends CustomPainter {
  final double progress;
  _ArcPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center =
        Offset(size.width / 2, size.height / 2 + 10);
    final radius = size.width / 2 - 10;
    final bgPaint = Paint()
      ..color = const Color(0xFF1B2A22)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fgPaint = Paint()
      ..color = const Color(0xFF0E6B3E)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 270° আর্ক (নিচে ফাঁকা)
    const startAngle = math.pi * 0.75;
    const sweep = math.pi * 1.5;
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        bgPaint);
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep * progress.clamp(0.0, 1.0),
        false,
        fgPaint);
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress;
}
