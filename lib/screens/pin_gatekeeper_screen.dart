import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/vault_provider.dart';
import '../services/pin_lock_service.dart';

const Color neonMagenta = Color(0xFFFF00FF);
const Color neonCyan = Color(0xFF00FFFF);
const Color neonPurple = Color(0xFF9B00FF);

class PinGatekeeperScreen extends StatefulWidget {
  const PinGatekeeperScreen({super.key});

  @override
  State<PinGatekeeperScreen> createState() => _PinGatekeeperScreenState();
}

class _PinGatekeeperScreenState extends State<PinGatekeeperScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSetting = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final svc = PinLockService();
    final hasPin = await svc.hasPin();
    if (!mounted) return;

    context.read<AuthProvider>().setPinSet(hasPin);

    setState(() {
      _isSetting = !hasPin;
      _loading = false;
    });
  }

  Future<void> _handleSubmit() async {
    final pin = _controller.text.trim();

    if (pin.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN must be at least 4 digits')),
      );
      return;
    }

    final svc = PinLockService();

    if (_isSetting) {
      await svc.setPin(pin);

      context.read<AuthProvider>()
        ..setPinSet(true)
        ..unlockVaultAfterAuth(); 
      context.read<VaultProvider>().unlockVault();
    } else {
      final ok = await svc.verifyPin(pin);
      if (ok) {
        context.read<AuthProvider>().unlockVaultAfterAuth();
        context.read<VaultProvider>().unlockVault();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect PIN')),
        );
      }
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_loading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final pinSet = context.watch<AuthProvider>().pinSet;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shield_outlined,
                size: 64,
                color: isDark ? neonMagenta : theme.colorScheme.primary,
                shadows: isDark
                    ? [
                        Shadow(
                          color: neonMagenta.withOpacity(0.7),
                          blurRadius: 14,
                        )
                      ]
                    : [],
              ),
              const SizedBox(height: 18),
              Text(
                pinSet ? 'Enter Vault PIN' : 'Create Vault PIN',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? neonCyan : null,
                  shadows: isDark
                      ? [
                          Shadow(
                            color: neonCyan.withOpacity(0.6),
                            blurRadius: 12,
                          )
                        ]
                      : [],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your vault is protected with local encryption.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: 160,
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '••••',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark ? neonPurple : theme.dividerColor,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark ? neonMagenta : theme.colorScheme.primary,
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? neonPurple : theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: isDark ? 6 : 0,
                  shadowColor: isDark ? neonPurple.withOpacity(0.6) : null,
                ),
                child: Text(
                  pinSet ? 'Unlock Vault' : 'Set PIN',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
