import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/github_api.dart';
import 'login_screen.dart';
import 'content_screen.dart';
import 'branding_screen.dart';

class PanelScreen extends StatefulWidget {
  const PanelScreen({super.key});

  @override
  State<PanelScreen> createState() => _PanelScreenState();
}

class _PanelScreenState extends State<PanelScreen> {
  bool _loading = true;
  bool _saving = false;
  String? _sha;
  String? _error;
  Map<String, dynamic>? _fullConfig;

  // app name
  final appName = TextEditingController();

  // announcement
  bool annEnabled = false;
  final annTitle = TextEditingController();
  final annMessage = TextEditingController();
  Color annColor = const Color(0xFF0E6B3E);

  // featured
  bool featEnabled = false;
  final featTitle = TextEditingController();
  final featSurah = TextEditingController();
  final featDesc = TextEditingController();

  // maintenance
  bool maintMode = false;
  final maintMsg = TextEditingController();
  final latestVer = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    appName.dispose();
    annTitle.dispose();
    annMessage.dispose();
    featTitle.dispose();
    featSurah.dispose();
    featDesc.dispose();
    maintMsg.dispose();
    latestVer.dispose();
    super.dispose();
  }

  Future<String?> _getPat() async {
    final p = await SharedPreferences.getInstance();
    return p.getString('ds_pat');
  }

  Future<void> _load() async {
    final pat = await _getPat();
    if (pat == null) {
      _goLogin();
      return;
    }
    final res = await GitHubApi(pat).loadConfig();
    if (!mounted) return;
    if (res == null) {
      setState(() {
        _loading = false;
        _error = 'লোড হয়নি — ইন্টারনেট চেক করো';
      });
      return;
    }
    final c = res['config'] as Map<String, dynamic>;
    final a = c['announcement'] as Map<String, dynamic>? ?? {};
    final f = c['featured'] as Map<String, dynamic>? ?? {};
    final i = c['app_info'] as Map<String, dynamic>? ?? {};
    setState(() {
      _sha = res['sha'] as String;
      _fullConfig = c;
      appName.text = '${c['app_name'] ?? 'দীন শিক্ষা'}';
      annEnabled = a['enabled'] == true;
      annTitle.text = '${a['title'] ?? ''}';
      annMessage.text = '${a['message'] ?? ''}';
      annColor = _parseColor('${a['color'] ?? '#0E6B3E'}');
      featEnabled = f['enabled'] == true;
      featTitle.text = '${f['title'] ?? ''}';
      featSurah.text = '${f['surah_id'] ?? ''}';
      featDesc.text = '${f['description'] ?? ''}';
      maintMode = i['maintenance_mode'] == true;
      maintMsg.text = '${i['maintenance_message'] ?? ''}';
      latestVer.text = '${i['latest_version'] ?? ''}';
      _loading = false;
    });
  }

  Color _parseColor(String hex) {
    try {
      var h = hex.replaceAll('#', '');
      if (h.length == 6) h = 'FF$h';
      return Color(int.parse(h, radix: 16));
    } catch (_) {
      return const Color(0xFF0E6B3E);
    }
  }

  String _colorHex(Color c) =>
      '#${c.value.toRadixString(16).substring(2).toUpperCase()}';

  Future<void> _save() async {
    final pat = await _getPat();
    if (pat == null || _sha == null) return;
    setState(() => _saving = true);
    final config = {
      'app_name': appName.text.trim().isEmpty
          ? 'দীন শিক্ষা'
          : appName.text.trim(),
      'branding': (_fullConfig?['branding'] as Map<String, dynamic>?) ?? {},
      'announcement': {
        'enabled': annEnabled,
        'title': annTitle.text.trim(),
        'message': annMessage.text.trim(),
        'color': _colorHex(annColor),
      },
      'featured': {
        'enabled': featEnabled,
        'title': featTitle.text.trim(),
        'surah_id': int.tryParse(featSurah.text.trim()) ?? 1,
        'description': featDesc.text.trim(),
      },
      'app_info': {
        'maintenance_mode': maintMode,
        'maintenance_message': maintMsg.text.trim(),
        'latest_version': latestVer.text.trim().isEmpty
            ? '1.0.0'
            : latestVer.text.trim(),
        'update_url': '',
      },
    };
    final ok = await GitHubApi(pat).saveConfig(config, _sha!);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? '✅ সেভ হয়েছে! ১-২ মিনিট পর app-এ দেখা যাবে।'
            : '❌ সেভ হয়নি — আবার চেষ্টা করো'),
        backgroundColor: ok ? const Color(0xFF0E6B3E) : Colors.red,
      ),
    );
    if (ok) _load(); // নতুন sha নাও
  }

  void _goLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _logout() async {
    final p = await SharedPreferences.getInstance();
    await p.remove('ds_pat');
    _goLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            tooltip: 'লোগো ও আইকন',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      const BrandingScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.library_books),
            tooltip: 'কনটেন্ট ম্যানেজ',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ContentScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
            tooltip: 'রিলোড',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'লগআউট',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: _load,
                          child: const Text('আবার চেষ্টা')),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _sectionCard(
                      '📱 অ্যাপের নাম',
                      const SizedBox.shrink(),
                      [
                        _label('হোম স্ক্রিনে দেখানো নাম'),
                        _field(appName, 'যেমন: দীন শিক্ষা'),
                      ],
                    ),
                    _sectionCard(
                      '📢 ঘোষণা ব্যানার',
                      _switchRow('ব্যানার চালু', annEnabled,
                          (v) => setState(() => annEnabled = v)),
                      [
                        _label('শিরোনাম'),
                        _field(annTitle, 'যেমন: পবিত্র রমজান মোবারক'),
                        _label('বার্তা'),
                        _field(annMessage, 'বিস্তারিত লেখো...', maxLines: 3),
                        _label('রঙ'),
                        _colorPicker(),
                      ],
                    ),
                    _sectionCard(
                      '⭐ ফিচার্ড সূরা',
                      _switchRow('হোমে দেখাও', featEnabled,
                          (v) => setState(() => featEnabled = v)),
                      [
                        _label('শিরোনাম'),
                        _field(featTitle, 'যেমন: আজকের সূরা'),
                        _label('সূরা নম্বর (১-১১৪)'),
                        _field(featSurah, 'যেমন: 36',
                            keyboard: TextInputType.number),
                        _label('বর্ণনা'),
                        _field(featDesc, 'ছোট বর্ণনা'),
                      ],
                    ),
                    _sectionCard(
                      '🔧 অ্যাপ সেটিংস',
                      _switchRow('মেইনটেন্যান্স মোড', maintMode,
                          (v) => setState(() => maintMode = v)),
                      [
                        _label('মেইনটেন্যান্স বার্তা'),
                        _field(maintMsg, 'যেমন: আপডেট চলছে...'),
                        _label('সর্বশেষ ভার্সন'),
                        _field(latestVer, '1.0.0'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5))
                          : const Icon(Icons.save),
                      label: Text(_saving ? 'সেভ হচ্ছে...' : '💾 সেভ করো'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E6B3E),
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 17),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'সেভ করার ১-২ মিনিট পর user app-এ দেখা যাবে (ইন্টারনেট লাগবে)।',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 12.5, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
    );
  }

  Widget _sectionCard(String title, Widget toggle, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0E6B3E))),
            const SizedBox(height: 8),
            toggle,
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _switchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Switch(
          value: value,
          activeColor: const Color(0xFF0E6B3E),
          onChanged: onChanged,
        ),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Text(t,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54)),
      );

  Widget _field(TextEditingController c, String hint,
      {int maxLines = 1, TextInputType? keyboard}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _colorPicker() {
    const colors = [
      Color(0xFF0E6B3E),
      Color(0xFF1B6FA8),
      Color(0xFF8A6D1B),
      Color(0xFFB23A48),
      Color(0xFF6A4FB3),
      Color(0xFF333333),
    ];
    return Wrap(
      spacing: 10,
      children: colors.map((c) {
        final selected = c.value == annColor.value;
        return GestureDetector(
          onTap: () => setState(() => annColor = c),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: selected
                  ? Border.all(color: Colors.black, width: 3)
                  : null,
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
