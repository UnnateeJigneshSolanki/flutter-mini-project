import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {

  static const String _keyString = 'CyberShieldKey16';

  final encrypt.Key _key = encrypt.Key.fromUtf8(_keyString);

  late final encrypt.Encrypter _encrypter =
      encrypt.Encrypter(encrypt.AES(_key));

  String encryptText(String plainText) {
    final iv = encrypt.IV.fromSecureRandom(16);

    final encrypted = _encrypter.encrypt(plainText, iv: iv);

    final combined = Uint8List.fromList(
      iv.bytes + encrypted.bytes,
    );

    return encrypt.Encrypted(combined).base64;
  }

  String decryptText(String encryptedText) {
    try {
      final bytes =
          encrypt.Encrypted.fromBase64(encryptedText).bytes;

      final iv = encrypt.IV(bytes.sublist(0, 16));
      final cipherText =
          encrypt.Encrypted(bytes.sublist(16));

      return _encrypter.decrypt(cipherText, iv: iv);
    } catch (_) {
      return '';
    }
  }
}
