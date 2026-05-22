import 'dart:convert';
import 'package:http/http.dart' as http;

class SecurityArticle {
  final String title;
  final String source;
  final String url;

  SecurityArticle({
    required this.title,
    required this.source,
    required this.url,
  });
}

class SecurityNewsService {
  static const _apiKey = 'YOUR_NEWSAPI_KEY'; 
  static const _endpoint = 'https://newsapi.org/v2/everything';

  Future<List<SecurityArticle>> fetchLatest() async {
    final uri = Uri.parse(_endpoint).replace(queryParameters: {
      'q': 'cybersecurity OR "cyber attack" OR hacking',
      'language': 'en',
      'pageSize': '20',     
      'sortBy': 'publishedAt',
      'apiKey': _apiKey,
    });

    final resp = await http.get(uri);
    if (resp.statusCode != 200) return [];

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final articles = data['articles'] as List<dynamic>? ?? [];

    return articles.map((a) {
      final m = a as Map<String, dynamic>;
      return SecurityArticle(
        title: m['title'] ?? 'Security update',
        source: (m['source']?['name'] ?? '') as String,
        url: m['url'] ?? '',
      );
    }).toList();
  }
}