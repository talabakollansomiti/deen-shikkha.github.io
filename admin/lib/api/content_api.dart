import 'dart:convert';
import 'package:http/http.dart' as http;

// content/*.json ফাইল ম্যানেজমেন্ট
class ContentApi {
  static const _base = 'https://api.github.com';
  static const _owner = 'talabakollansomiti';
  static const _repo = 'deen-shikkha.github.io';

  final String token;
  ContentApi(this.token);

  Map<String, String> get _h => {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github+json',
      };

  Future<Map<String, dynamic>?> load(String name) async {
    try {
      final r = await http
          .get(
              Uri.parse(
                  '$_base/repos/$_owner/$_repo/contents/content/$name.json'),
              headers: _h)
          .timeout(const Duration(seconds: 12));
      if (r.statusCode != 200) return null;
      final d = json.decode(r.body) as Map<String, dynamic>;
      final content = utf8.decode(
          base64.decode((d['content'] as String).replaceAll('\n', '')));
      return {
        'sha': d['sha'] as String,
        'items': json.decode(content) as List,
      };
    } catch (_) {
      return null;
    }
  }

  Future<bool> save(
      String name, List<Map<String, dynamic>> items, String sha) async {
    try {
      final content =
          base64.encode(utf8.encode(json.encode(items)));
      final r = await http
          .put(
            Uri.parse(
                '$_base/repos/$_owner/$_repo/contents/content/$name.json'),
            headers: {..._h, 'Content-Type': 'application/json'},
            body: json.encode({
              'message': 'Admin: update $name',
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
}
