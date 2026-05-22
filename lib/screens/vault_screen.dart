import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/vault_provider.dart';
import 'pin_gatekeeper_screen.dart';
import 'add_vault_item_screen.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  late Future<void> _vaultInit;

  @override
  void initState() {
    super.initState();
    _vaultInit = context.read<VaultProvider>().init();
  }

  Future<void> _openItem(BuildContext context, VaultItem item) async {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;

    if (item.itemPin != null && item.itemPin!.isNotEmpty) {
      final pinCtrl = TextEditingController();
      final ok = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: theme.cardColor,
              title: Text('Unlock "${item.title}"', style: TextStyle(color: accent)),
              content: TextField(
                controller: pinCtrl,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'Item PIN',
                  counterText: '',
                  labelStyle: theme.textTheme.bodyMedium,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: accent),
                  ),
                ),
                style: theme.textTheme.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text('Unlock', style: TextStyle(color: accent)),
                ),
              ],
            ),
          ) ??
          false;

      if (!ok) return;
      if (pinCtrl.text.trim() != item.itemPin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect item PIN')),
        );
        return;
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text(item.title, style: TextStyle(color: accent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.username.isNotEmpty)
              Text('User: ${item.username}', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(
              item.type == 'password' ? 'Password: ${item.secret}' : 'Note: ${item.secret}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Close', style: TextStyle(color: accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = context.watch<AuthProvider>().vaultUnlocked;
    if (!unlocked) return const PinGatekeeperScreen();

    final vault = context.watch<VaultProvider>();
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text('Encrypted Vault', style: TextStyle(color: accent)),
      ),
      body: FutureBuilder(
        future: _vaultInit,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator(color: accent));
          }

          if (vault.items.isEmpty) {
            return Center(child: Text('No items yet', style: theme.textTheme.bodyMedium));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vault.items.length,
            itemBuilder: (context, index) {
              final item = vault.items[index];

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accent, width: 1.5),
                  boxShadow: [
                    BoxShadow(color: accent.withOpacity(0.3), blurRadius: 6, spreadRadius: 1),
                  ],
                ),
                child: ListTile(
                  title: Text(item.title, style: theme.textTheme.bodyMedium),
                  subtitle: Text(
                    item.username.isEmpty
                        ? (item.type == 'password' ? 'Password' : 'Secure note')
                        : item.username,
                    style: theme.textTheme.bodySmall,
                  ),
                  leading: Icon(
                    item.itemPin != null && item.itemPin!.isNotEmpty ? Icons.lock : Icons.lock_open,
                    color: accent,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: theme.cardColor,
                              title: Text('Delete item', style: TextStyle(color: Colors.redAccent)),
                              content: Text(
                                'Remove "${item.title}" from your vault? This cannot be undone.',
                                style: theme.textTheme.bodyMedium,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: Text('Cancel', style: theme.textTheme.bodyMedium),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                ),
                              ],
                            ),
                          ) ??
                          false;

                      if (!confirm) return;
                      await context.read<VaultProvider>().deleteItem(item.id);
                    },
                  ),
                  onTap: () => _openItem(context, item),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accent,
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const AddVaultItemScreen()))
              .then((_) {
            setState(() {}); // 🔄 Rebuild after coming back from AddVaultItemScreen
          });
        },
        child: Icon(Icons.add, color: theme.scaffoldBackgroundColor),
      ),
    );
  }
}
