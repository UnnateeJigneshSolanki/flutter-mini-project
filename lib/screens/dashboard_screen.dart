import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../services/device_info_service.dart';
import '../services/network_service.dart';

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
const Color neonPurple = Color(0xFF9B00FF);
const Color neonPink = Color(0xFFFF00FF);
const Color neonBlue = Color(0xFF00FFFF);
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}
class _DashboardScreenState extends State<DashboardScreen> {
  final _deviceSvc = DeviceInfoService();
  final _networkSvc = NetworkService();
  String _device = 'Loading...';
  String _os = 'Loading...';
  String _connection = 'Checking...';
  String _ip = '...';
  List<SecurityArticle> _articles = [];
  bool _loadingNews = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final model = await _deviceSvc.deviceModel();
    final os = await _deviceSvc.osVersion();
    final net = await _networkSvc.snapshot();
    final articles = await _fetchSecurityNews();

    if (!mounted) return;
    setState(() {
      _device = model;
      _os = os;
      _connection = net.connection;
      _ip = net.publicIp ?? 'Unavailable';
      _articles = articles;
      _loadingNews = false;
    });
  }

  Future<List<SecurityArticle>> _fetchSecurityNews() async {
    try {
      final resp = await http.get(
        Uri.parse('https://feeds.feedburner.com/TheHackersNews?format=xml'),
      );
      if (resp.statusCode != 200) return [];

      final body = resp.body;
      List<SecurityArticle> articles = [];

      final titleRegex = RegExp(r'<title>([^<]+)</title>');
      final matches = titleRegex.allMatches(body).toList();

      for (int i = 1; i < matches.length && i < 20; i++) {
        final title = matches[i].group(1) ?? 'Security News';
        articles.add(
          SecurityArticle(
            title: title,
            source: 'Cyber News',
            url: 'https://thehackernews.com',
          ),
        );
      }
      return articles;
    } catch (e) {
      print('News error: $e');
      return [];
    }
  }

  Color _getAccentColor(int index) {
    final colors = [neonPurple, neonBlue, neonPink];
    return colors[index % colors.length];
  }

  Widget _sectionCard(String title, List<Widget> children, Color accentColor) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.3),
            blurRadius: 8,
        
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: accentColor,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'CyberShield Dashboard',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.appBarTheme.foregroundColor,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: neonBlue,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
      
            _sectionCard(
              'Hardware Audit',
              [
                Text('Device: $_device', style: theme.textTheme.bodyMedium),
                Text('OS: $_os', style: theme.textTheme.bodyMedium),
              ],
              neonPurple,
            ),

         
            _sectionCard(
              'Network Intel',
              [
                Text('Connection: $_connection', style: theme.textTheme.bodyMedium),
                Text('Public IP: $_ip', style: theme.textTheme.bodyMedium),
              ],
              neonBlue,
            ),

            _sectionCard(
              'Security Feed (Live)',
              _loadingNews
                  ? [Center(child: CircularProgressIndicator(color: neonPink))]
                  : _articles.isEmpty
                      ? [Center(child: Text('No security news available.', style: theme.textTheme.bodyMedium))]
                      : _articles.asMap().entries.map((entry) {
                          final i = entry.key;
                          final article = entry.value;
                          final accent = _getAccentColor(i);

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: accent, width: 1.5),
                              boxShadow: [BoxShadow(color: accent.withOpacity(0.3), blurRadius: 4)],
                            ),
                            child: ListTile(
                              leading: Icon(Icons.shield, color: accent),
                              title: Text(article.title, style: theme.textTheme.bodyMedium),
                              subtitle: Text(article.source, style: theme.textTheme.bodySmall?.copyWith(color: accent.withOpacity(0.7))),
                              trailing: Icon(Icons.arrow_forward_ios, color: accent, size: 16),
                              onTap: () async {
                                final url = article.url;
                                if (url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'))) {
                                  try {
                                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                  } catch (e) {
                                    print('Failed to open URL: $e');
                                  }
                                }
                              },
                            ),
                          );
                        }).toList(),
              neonPink,
            ),
          ],
        ),
      ),
    );
  }
}
