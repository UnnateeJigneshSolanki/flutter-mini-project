import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../services/settings_service.dart';
import '../services/auth_service.dart';
import 'login_register_screen.dart';

const Color cyberPurple = Color(0xFF9B00FF);
const Color cyberPink = Color(0xFFFF00FF);
const Color cyberBlue = Color(0xFF00FFFF);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen> {
  bool _pinLockEnabled = true;
  bool _autoLockEnabled = true;
  bool _isDarkMode = true;
  String _username = 'User';
  static const String _appVersion = 'v1.0.0';
  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadUser();
  }

  Future<void> _loadSettings() async {
    final pinLock = await SettingsService.pinLockEnabled;
    final autoLock = await SettingsService.autoLockEnabled;

    final themeProvider = context.read<ThemeProvider>();

    if (!mounted) return;
    setState(() {
      _pinLockEnabled = pinLock;
      _autoLockEnabled = autoLock;
      _isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    });
  }

  Future<void> _loadUser() async {
    final name = await AuthService().currentUser();
    if (!mounted) return;
    setState(() => _username = name ?? 'User');
  }

  Widget _sectionCard(String title, List<Widget> children) {
    final theme = Theme.of(context);

    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cyberBlue.withOpacity(0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: cyberPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: cyberBlue)),
          ),
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
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionCard(
            'Account',
            [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person, color: cyberBlue),
                title: const Text('Logged in as'),
                subtitle: Text(
                  _username,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: cyberPink,
                  ),
                ),
              ),
            ],
          ),

          _sectionCard(
            'Security',
            [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('PIN Lock'),
                subtitle: const Text('Require PIN for vault'),
                value: _pinLockEnabled,
                activeColor: cyberBlue,
                onChanged: (v) async {
                  setState(() => _pinLockEnabled = v);
                  await SettingsService.setPinLockEnabled(v);
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Auto-lock'),
                subtitle: const Text('Lock after inactivity'),
                value: _autoLockEnabled,
                activeColor: cyberBlue,
                onChanged: (v) async {
                  setState(() => _autoLockEnabled = v);
                  await SettingsService.setAutoLockEnabled(v);
                },
              ),
            ],
          ),

          _sectionCard(
            'Appearance',
            [
              RadioListTile<bool>(
                contentPadding: EdgeInsets.zero,
                title: const Text('Dark Mode'),
                value: true,
                groupValue: _isDarkMode,
                activeColor: cyberPurple,
                onChanged: (_) {
                  setState(() => _isDarkMode = true);
                  context.read<ThemeProvider>().toggleTheme(true);
                },
              ),
              RadioListTile<bool>(
                contentPadding: EdgeInsets.zero,
                title: const Text('Light Mode'),
                value: false,
                groupValue: _isDarkMode,
                activeColor: cyberPurple,
                onChanged: (_) {
                  setState(() => _isDarkMode = false);
                  context.read<ThemeProvider>().toggleTheme(false);
                },
              ),
            ],
          ),

          _sectionCard(
            'About',
            [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.info_outline, color: cyberBlue),
                title: const Text('App Version'),
                subtitle: Text('CyberShield $_appVersion'),
                onTap: () {
                  _showInfoDialog(
                    'CyberShield',
                    'Version: $_appVersion\n\nCyber-security focused vault app.',
                  );
                },
              ),
            ],
          ),

          _sectionCard(
            'Session',
            [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('Logout'),
                subtitle: const Text('Sign out from this device'),
                onTap: () async {
                  await AuthService().logout();
                  if (!mounted) return;

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginRegisterScreen()),
                    (_) => false,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
