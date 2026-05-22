import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
const Color neonCyan = Color(0xFF00FFFF);
const Color neonPurple = Color(0xFF9B00FF);
const Color neonGreen = Color(0xFF00FF7F);

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Security Tools')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Protection'),
          _toolCard(
            context,
            icon: auth.vaultUnlocked ? Icons.lock_open : Icons.lock,
            title: 'Vault Status',
            subtitle: auth.vaultUnlocked
                ? 'Vault is unlocked'
                : 'Vault is locked',
            color: neonCyan,
            trailing: auth.vaultUnlocked
                ? IconButton(
                    icon: const Icon(Icons.lock),
                    tooltip: 'Lock Vault',
                    onPressed: () {
                      context.read<AuthProvider>().lockVault();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vault locked')),
                      );
                    },
                  )
                : const Icon(Icons.verified_user, color: Colors.grey),
            isDark: isDark,
          ),

          _sectionTitle('Security Actions'),
          _toolCard(
            context,
            icon: Icons.security,
            title: 'Password Analyzer',
            subtitle: 'Entropy & pattern-based analysis',
            color: neonPurple,
            onTap: () => _showPasswordAnalyzer(context),
            isDark: isDark,
          ),
          _toolCard(
            context,
            icon: Icons.vpn_key,
            title: 'Generate Secure Password',
            subtitle: 'Cryptographically random',
            color: neonGreen,
            onTap: () => _showGeneratedPassword(context),
            isDark: isDark,
          ),

          _sectionTitle('Utilities'),

          _toolCard(
            context,
            icon: Icons.info_outline,
            title: 'Security Tips',
            subtitle: 'Live-safe best practices',
            color: neonCyan,
            onTap: () => _showTips(context),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 24),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );

  Widget _toolCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    Widget? trailing,
    VoidCallback? onTap,
    required bool isDark,
  }) {
    return Card(
      elevation: isDark ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isDark ? BorderSide(color: color, width: 1.2) : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing,
      ),
    );
  }
  void _showPasswordAnalyzer(BuildContext context) {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Password Analyzer'),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Enter password'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final result = _analyzePassword(ctrl.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result)),
              );
            },
            child: const Text('Analyze'),
          ),
        ],
      ),
    );
  }

  String _analyzePassword(String pwd) {
    if (pwd.isEmpty) return 'Empty password';

    int score = 0;
    if (pwd.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(pwd)) score++;
    if (RegExp(r'[a-z]').hasMatch(pwd)) score++;
    if (RegExp(r'[0-9]').hasMatch(pwd)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(pwd)) score++;

    switch (score) {
      case 5:
        return 'Very Strong 🔥';
      case 4:
        return 'Strong';
      case 3:
        return 'Moderate';
      default:
        return 'Weak ❌';
    }
  }

  void _showGeneratedPassword(BuildContext context) {
    final password = _generateSecurePassword();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Secure Password'),
        content: SelectableText(
          password,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _generateSecurePassword({int length = 16}) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()-_=+';
    final rand = Random.secure();

    return List.generate(
      length,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  void _showTips(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Security Tips'),
        content: const Text(
          '• Use a password manager\n'
          '• Enable PIN / biometrics\n'
          '• Lock vault when idle\n'
          '• Avoid reused passwords',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
