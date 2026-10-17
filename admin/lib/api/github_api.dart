import 'dart:convert';
import 'package:http/http.dart' as http;

// GitHub API দিয়ে config.json পড়া/লেখা
class GitHubApi {
  static const owner = 'talabakollansomiti';
  static const repo = 'deen-shikkha.github.io';
  static const file = 'config.json';
  static const _base = 'https://api.github.com';

  final String token;
  GitHubApi(this.token);

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github+json',
      };

  Future<Map<String, dynamic>?> loadConfig() async {
    try {
      final r = await http
          .get(Uri.parse('$_base/repos/$owner/$repo/contents/$file'),
              headers: _headers)
          .timeout(const Duration(seconds: 12));
      if (r.statusCode != 200) return null;
      final d = json.decode(r.body) as Map<String, dynamic>;
      final content = utf8.decode(
          base64.decode((d['content'] as String).replaceAll('\n', '')));
      return {
        'sha': d['sha'] as String,
        'config': json.decode(content) as Map<String, dynamic>,
      };
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveConfig(Map<String, dynamic> config, String sha) async {
    try {
      final content =
          base64.encode(utf8.encode(json.encode(config)));
      final r = await http
          .put(
            Uri.parse('$_base/repos/$owner/$repo/contents/$file'),
            headers: {..._headers, 'Content-Type': 'application/json'},
            body: json.encode({
              'message': 'Admin app update',
              'content': content,
              'sha': sha,
            }),
          )
          .timeout(const Duration(seconds: 15));
      return r.statusCode == 200 || r.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> validate() async {
    try {
      final r = await http
          .get(Uri.parse('$_base/repos/$owner/$repo'),
              headers: _headers)
          .timeout(const Duration(seconds: 10));
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
