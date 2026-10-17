import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/animations.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen>
    with SingleTickerProviderStateMixin {
  int _count = 0;
  int _target = 100;
  int _total = 0;
  String _dhikr = 'সুবহানাল্লাহ';
  late AnimationController _bounceCtrl;
  late Animation<double> _bounce;

  final List<String> _adhkar = [
    'সুবহানাল্লাহ',
    'আলহামদুলিল্লাহ',
    'আল্লাহু আকবার',
    'লা ইলাহা ইল্লাল্লাহ',
    'আসতাগফিরুল্লাহ',
    'সুবহানাল্লাহি ওয়া বিহামদিহি',
    'লা হাওলা ওয়ালা কুওয়্যাতা ইল্লা বিল্লাহ',
  ];

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _bounce = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(
          parent: _bounceCtrl, curve: Curves.easeOut),
    );
    _loadTotal();
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTotal() async {
    final p = await SharedPreferences.getInstance();
    setState(() => _total = p.getInt('tasbih_total') ?? 0);
  }

  Future<void> _saveTotal() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('tasbih_total', _total);
  }

  void _tap() {
    _bounceCtrl.forward().then((_) => _bounceCtrl.reverse());
    setState(() {
      _count++;
      _total++;
    });
    _saveTotal();
    if (_count == _target) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 মাশাআল্লাহ! টার্গেট পূর্ণ হয়েছে!'),
          backgroundColor: Color(0xFF0E6B3E),
        ),
      );
    }
  }

  void _reset() => setState(() => _count = 0);

  @override
  Widget build(BuildContext context) {
    final progress = _target > 0 ? _count / _target : 0.0;
    return Scaffold(
      appBar: AppBar(title: const Text('তাসবীহ কাউন্টার')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _dhikr,
              decoration: InputDecoration(
                labelText: 'যিকির',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              items: _adhkar
                  .map((d) =>
                      DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() {
                _dhikr = v!;
                _count = 0;
              }),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('টার্গেট: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    children: [33, 100, 500, 1000].map((t) {
                      final sel = _target == t;
                      return ChoiceChip(
                        label: Text('$t'),
                        selected: sel,
                        selectedColor: const Color(0xFF0E6B3E),
                        labelStyle: TextStyle(
                            color: sel ? Colors.white : Colors.black87),
                        onSelected: (_) =>
                            setState(() => _target = t),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GestureDetector(
                onTap: _tap,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF0E6B3E), Color(0xFF0A4D2D)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0E6B3E).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _bounce,
                        child: Text(
                          '$_count',
                          style: const TextStyle(
                              fontSize: 84,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      Text(
                        '/ $_target',
                        style: const TextStyle(
                            fontSize: 20, color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: 200,
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: Colors.white24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'ট্যাপ করো',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('রিসেট'),
                ),
                Text('মোট: $_total',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
