import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/encryption_service.dart';

class VaultItem {
  final String id;
  final String title;
  final String username;
  final String secret;     
  final String secretEnc; 
  final String type;
  final String? itemPin;

  VaultItem({
    required this.id,
    required this.title,
    required this.username,
    required this.secret,
    required this.secretEnc,
    required this.type,
    this.itemPin,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'username': username,
        'secret_encrypted': secretEnc,
        'type': type,
        'itemPin': itemPin,
      };

  factory VaultItem.fromMap(
    Map<String, dynamic> map,
    EncryptionService enc,
  ) {
    final encrypted = map['secret_encrypted'] as String;
    final decrypted = enc.decryptText(encrypted);

    return VaultItem(
      id: map['id'],
      title: map['title'],
      username: map['username'],
      secret: decrypted.isEmpty ? 'DECRYPT FAILED' : decrypted,
      secretEnc: encrypted,
      type: map['type'],
      itemPin: map['itemPin'],
    );
  }
}

class VaultProvider extends ChangeNotifier {
  final EncryptionService _enc = EncryptionService();

  List<VaultItem> _items = [];
  bool _initialized = false;
  bool _vaultUnlocked = false;

  List<VaultItem> get items => _vaultUnlocked ? _items : [];
  bool get isUnlocked => _vaultUnlocked;

  Future<void> init() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('vault_items') ?? [];
    _items = stored
        .map((e) {
          try {
            final map = jsonDecode(e);
            return VaultItem.fromMap(map, _enc);
          } catch (_) {
            return null;
          }
        })
        .whereType<VaultItem>()
        .toList();

    _initialized = true;
    notifyListeners();
  }
  void unlockVault() {
    _vaultUnlocked = true;
    notifyListeners();
  }

  void lockVault() {
    _vaultUnlocked = false;
    notifyListeners();
  }

  /// =========================
  /// SAVE TO STORAGE
  /// =========================
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        _items.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList('vault_items', encoded);
  }

  Future<void> addItem({
    required String id,
    required String title,
    required String username,
    required String secret,
    required String type,
    String? itemPin,
  }) async {
    await init();

    final encrypted = _enc.encryptText(secret);

    final item = VaultItem(
      id: id,
      title: title,
      username: username,
      secret: secret,       
      secretEnc: encrypted,
      type: type,
      itemPin: itemPin,
    );

    _items.add(item);
    notifyListeners();
    await _save();
  }


  Future<void> deleteItem(String id) async {
    await init();
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
    await _save();
  }

  VaultItem? getById(String id) {
    if (!_vaultUnlocked) return null;
    try {
      return _items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
