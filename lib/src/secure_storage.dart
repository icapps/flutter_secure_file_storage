import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_file_storage/src/encryption_util.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;

  const SecureStorage(this._storage);

  String _ivKey(String key) => '$key-iv';
  String _keyKey(String key) => '$key-key';

  Future<void> deleteIV(String key) async => _storage.delete(key: _ivKey(key));

  Future<void> deleteKey(String key) async => _storage.delete(key: _keyKey(key));

  Future<Uint8List?> getIVOrNull(String key) async {
    final storageKey = _ivKey(key);
    final encryptionIVString = await _storage.read(key: storageKey);
    if (encryptionIVString != null) {
      return base64Decode(encryptionIVString);
    }
  }

  Future<Uint8List?> getKeyOrNull(String key) async {
    final storageKey = _keyKey(key);
    final encryptionKeyString = await _storage.read(key: storageKey);
    if (encryptionKeyString != null) {
      return base64Decode(encryptionKeyString);
    }
  }

  Future<Uint8List> generateIV(String key) async {
    final generated = EncryptionUtil.generateSecureIV();
    await saveIV(key, generated);
    return generated;
  }

  Future<void> saveIV(String key, Uint8List iv) async {
    await _storage.write(key: _ivKey(key), value: base64Encode(iv));
  }

  Future<Uint8List> getOrGenerateKey(String key) async {
    final savedKey = await getKeyOrNull(key);
    if (savedKey != null) {
      return savedKey;
    }
    final generated = EncryptionUtil.generateSecureKey();
    await _storage.write(key: _keyKey(key), value: base64Encode(generated));
    return generated;
  }
}
