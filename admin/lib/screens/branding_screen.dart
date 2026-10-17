import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/github_api.dart';

// লোগো ও আইকন ম্যানেজমেন্ট
class BrandingScreen extends StatefulWidget {
  const BrandingScreen({super.key});

  @override
  State<BrandingScreen> createState() => _BrandingScreenState();
}

class _BrandingScreenState extends State<BrandingScreen> {
  bool _loading = true;
  bool _saving = false;
  String? _sha;
  Map<String, dynamic>? _fullConfig;

  final logoCtrl = TextEditingController();
  final taglineCtrl = TextEditingController();
  bool showLogo = true;
  bool animateLogo = true;

  // মেনু আইটেম: key -> বাংলা নাম
  final Map<String, String> menuItems = {
    'quran': 'পবিত্র কুরআন',
    'quran_search': 'কুরআন সার্চ',
    'hadith': 'হাদিস',
    'names99': '৯৯ নাম',
    'namaz_guide': 'নামাজ শিক্ষা',
    'namaz_times': 'নামাজের সময়',
    'namaz_tracker': 'নামাজ ট্র্যাকার',
    'tasbih': 'তাসবীহ',
    'ramadan': 'রমজান প্ল্যানার',
    'dua': 'দোয়া ও যিকির',
    'quiz': 'ইসলামিক কুইজ',
    'seerah': 'সীরাত',
    'prophets': 'নবীদের কাহিনী',
    'hajj': 'হজ্জ-উমরাহ',
    'zakat': 'যাকাত',
    'fitra': 'ফিতরা',
    'sadaqah': 'সদকা ট্র্যাকার',
    'hijri': 'হিজরি ক্যালেন্ডার',
  };
  final Map<String, TextEditingController> iconCtrls = {};

  @override
  void initState() {
    super.initState();
    for (final k in menuItems.keys) {
      iconCtrls[k] = TextEditingController();
    }
    _load();
  }

  @override
  void dispose() {
    logoCtrl.dispose();
    taglineCtrl.dispose();
    for (final c in iconCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final pat = p.getString('ds_pat');
    if (pat == null) return;
    final res = await GitHubApi(pat).loadConfig();
    if (!mounted) return;
    if (res != null) {
      final c = res['config'] as Map<String, dynamic>;
      final b = c['branding'] as Map<String, dynamic>? ?? {};
      final mi = b['menu_icons'] as Map<String, dynamic>? ?? {};
      setState(() {
        _sha = res['sha'] as String;
        _fullConfig = c;
        logoCtrl.text = '${b['logo'] ?? '🕌'}';
        taglineCtrl.text =
            '${b['tagline'] ?? 'ইসলামিক জ্ঞানের ভান্ডার'}';
        showLogo = b['show_logo'] != false;
        animateLogo = b['animate_logo'] != false;
        for (final k in menuItems.keys) {
          iconCtrls[k]!.text = '${mi[k] ?? ''}';
        }
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    final pat = p.getString('ds_pat');
    if (pat == null || _sha == null || _fullConfig == null) return;
    setState(() => _saving = true);
    final icons = <String, String>{};
    for (final k in menuItems.keys) {
      icons[k] = iconCtrls[k]!.text.trim();
    }
    final config = Map<String, dynamic>.from(_fullConfig!);
    config['branding'] = {
      'logo': logoCtrl.text.trim().isEmpty
          ? '🕌'
          : logoCtrl.text.trim(),
      'show_logo': showLogo,
      'animate_logo': animateLogo,
      'tagline': taglineCtrl.text.trim(),
      'menu_icons': icons,
    };
    final ok =
        await GitHubApi(pat).saveConfig(config, _sha!);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            ok ? '✅ সেভ হয়েছে!' : '❌ সেভ হয়নি'),
        backgroundColor:
            ok ? const Color(0xFF0E6B3E) : Colors.red,
      ),
    );
    if (ok) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎨 লোগো ও আইকন')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text('🕌 মূল লোগো',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0E6B3E))),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Switch(
                              value: showLogo,
                              activeColor:
                                  const Color(0xFF0E6B3E),
                              onChanged: (v) => setState(
                                  () => showLogo = v),
                            ),
                            const Text('লোগো দেখাও',
                                style: TextStyle(
                                    fontWeight:
                                        FontWeight.w600)),
                          ],
                        ),
                        Row(
                          children: [
                            Switch(
                              value: animateLogo,
                              activeColor:
                                  const Color(0xFF0E6B3E),
                              onChanged: (v) => setState(
                                  () => animateLogo = v),
                            ),
                            const Text('অ্যানিমেশন চালু',
                                style: TextStyle(
                                    fontWeight:
                                        FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('লোগো (emoji)',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: logoCtrl,
                          style:
                              const TextStyle(fontSize: 28),
                          decoration: InputDecoration(
                            hintText: '🕌',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        10)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('ট্যাগলাইন',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: taglineCtrl,
                          decoration: InputDecoration(
                            hintText: 'ইসলামিক জ্ঞানের ভান্ডার',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'মেনু আইকন (খালি রাখলে আইকন লুকাবে)',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                ...menuItems.entries.map((e) => Card(
                      margin:
                          const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(e.value,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight:
                                          FontWeight.w500)),
                            ),
                            SizedBox(
                              width: 80,
                              child: TextField(
                                controller: iconCtrls[e.key],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 24),
                                decoration: InputDecoration(
                                  hintText: '📖',
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                              10)),
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          vertical: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5))
                      : const Icon(Icons.save),
                  label: Text(
                      _saving ? 'সেভ হচ্ছে...' : '💾 সেভ করো'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF0E6B3E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16),
                    textStyle:
                        const TextStyle(fontSize: 17),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}
