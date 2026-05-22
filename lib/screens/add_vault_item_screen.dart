import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vault_provider.dart';

class AddVaultItemScreen extends StatefulWidget {
  const AddVaultItemScreen({super.key});

  @override
  State<AddVaultItemScreen> createState() => _AddVaultItemScreenState();
}

class _AddVaultItemScreenState extends State<AddVaultItemScreen> {
  final _titleCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _secretCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();

  String _type = 'password';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text('Add Vault Item', style: TextStyle(color: accent)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _themeTextField(controller: _titleCtrl, label: 'Title', context: context),
            const SizedBox(height: 12),
            _themeTextField(controller: _userCtrl, label: 'Username / label (optional)', context: context),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _type,
              items: const [
                DropdownMenuItem(value: 'password', child: Text('Password')),
                DropdownMenuItem(value: 'note', child: Text('Secure note')),
              ],
              onChanged: (v) => setState(() => _type = v ?? 'password'),
              decoration: InputDecoration(
                labelText: 'Type',
                labelStyle: TextStyle(color: accent),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: accent),
                ),
              ),
              dropdownColor: theme.cardColor,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            _themeTextField(
              controller: _secretCtrl,
              label: _type == 'password' ? 'Password' : 'Note',
              obscure: _type == 'password',
              maxLines: _type == 'password' ? 1 : 4,
              context: context,
            ),
            const SizedBox(height: 12),
            _themeTextField(
              controller: _pinCtrl,
              label: 'Optional item PIN',
              keyboardType: TextInputType.number,
              obscure: true,
              maxLength: 6,
              context: context,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: accent),
              child: Text('Save', style: TextStyle(color: theme.scaffoldBackgroundColor)),
              onPressed: () async {
  final title = _titleCtrl.text.trim();
  final secret = _secretCtrl.text.trim();

  if (title.isEmpty || secret.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Title and secret required')),
    );
    return;
  }

  await context.read<VaultProvider>().addItem(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: title,
    username: _userCtrl.text.trim(),
    secret: secret,
    type: _type,
    itemPin: _pinCtrl.text.trim().isEmpty ? null : _pinCtrl.text.trim(),
  );

  if (mounted) Navigator.pop(context);
},

            ),
          ],
        ),
      ),
    );
  }

  Widget _themeTextField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;

    return TextField(
      controller: controller,
      obscureText: obscure,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        labelStyle: TextStyle(color: accent),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accent),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accent, width: 2),
        ),
      ),
    );
  }
}
