import 'dart:convert';
import 'package:http/http.dart' as http;

// Admin panel (control.html) থেকে remote config পড়া
class RemoteConfig {
  final String appName;
  final String logo;
  final bool showLogo;
  final bool animateLogo;
  final String tagline;
  final Map<String, String> menuIcons;
  final bool annEnabled;
  final String annTitle;
  final String annMessage;
  final String annColor;
  final bool featEnabled;
  final String featTitle;
  final int featSurahId;
  final String featDesc;
  final bool maintMode;
  final String maintMsg;
  final String latestVersion;

  const RemoteConfig({
    this.appName = 'দীন শিক্ষা',
    this.logo = '🕌',
    this.showLogo = true,
    this.animateLogo = true,
    this.tagline = 'ইসলামিক জ্ঞানের ভান্ডার',
    this.menuIcons = const {},
    this.annEnabled = false,
    this.annTitle = '',
    this.annMessage = '',
    this.annColor = '#0E6B3E',
    this.featEnabled = false,
    this.featTitle = '',
    this.featSurahId = 1,
    this.featDesc = '',
    this.maintMode = false,
    this.maintMsg = '',
    this.latestVersion = '1.0.0',
  });

  static const _url =
      'https://talabakollansomiti.github.io/deen-shikkha.github.io/config.json';

  static Future<RemoteConfig> fetch() async {
    try {
      final res = await http.get(Uri.parse(_url)).timeout(
            const Duration(seconds: 8),
          );
      if (res.statusCode != 200) return const RemoteConfig();
      final d = json.decode(res.body) as Map<String, dynamic>;
      final b = d['branding'] as Map<String, dynamic>? ?? {};
      final mi = b['menu_icons'] as Map<String, dynamic>? ?? {};
      final a = d['announcement'] as Map<String, dynamic>? ?? {};
      final f = d['featured'] as Map<String, dynamic>? ?? {};
      final i = d['app_info'] as Map<String, dynamic>? ?? {};
      return RemoteConfig(
        appName: (d['app_name'] ?? 'দীন শিক্ষা').toString(),
        logo: (b['logo'] ?? '🕌').toString(),
        showLogo: b['show_logo'] != false,
        animateLogo: b['animate_logo'] != false,
        tagline: (b['tagline'] ?? 'ইসলামিক জ্ঞানের ভান্ডার')
            .toString(),
        menuIcons: mi.map((k, v) =>
            MapEntry(k.toString(), v.toString())),
        annEnabled: a['enabled'] == true,
        annTitle: (a['title'] ?? '').toString(),
        annMessage: (a['message'] ?? '').toString(),
        annColor: (a['color'] ?? '#0E6B3E').toString(),
        featEnabled: f['enabled'] == true,
        featTitle: (f['title'] ?? '').toString(),
        featSurahId: (f['surah_id'] is int)
            ? f['surah_id'] as int
            : int.tryParse('${f['surah_id']}') ?? 1,
        featDesc: (f['description'] ?? '').toString(),
        maintMode: i['maintenance_mode'] == true,
        maintMsg: (i['maintenance_message'] ?? '').toString(),
        latestVersion: (i['latest_version'] ?? '1.0.0').toString(),
      );
    } catch (_) {
      return const RemoteConfig(); // offline হলে ডিফল্ট
    }
  }
}
