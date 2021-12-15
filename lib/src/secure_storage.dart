import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_file_storage/src/encryption_util.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;

  const SecureStorage(this._storage);

  String _ivKey(String key) => '$key-iv';
  String _keyKey(String key) => '$key-key';

  Future<void> deleteIV(String key) async => _storage.delete(key: _ivKey(key));

  Future<void> deleteKey(String key) async => _storage.delete(key: _keyKey(key));

  Future<IV?> getIVOrNull(String key) async {
    final storageKey = _ivKey(key);
    final encryptionIVString = await _storage.read(key: storageKey);
    if (encryptionIVString != null) {
      return IV.fromBase64(encryptionIVString);
    }
  }

  Future<Key?> getKeyOrNull(String key) async {
    final storageKey = _keyKey(key);
    final encryptionKeyString = await _storage.read(key: storageKey);
    if (encryptionKeyString != null) {
      return Key.fromBase64(encryptionKeyString);
    }
  }

  Future<IV> getOrGenerateIV(String key) async {
    final iv = await getIVOrNull(key);
    if (iv != null) {
      return iv;
    }
    final generated = EncryptionUtil.generateSecureIV();
    await _storage.write(key: _ivKey(key), value: generated.base64);
    return generated;
  }

  Future<Key> getOrGenerateKey(String key) async {
    final savedKey = await getKeyOrNull(key);
    if (savedKey != null) {
      return savedKey;
    }
    final generated = EncryptionUtil.generateSecureKey();
    await _storage.write(key: _keyKey(key), value: generated.base64);
    return generated;
  }
}
