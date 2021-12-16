import 'dart:convert';

import 'package:flutter_secure_file_storage/src/encryption_util.dart';
import 'package:flutter_secure_file_storage/src/file_storage.dart';
import 'package:flutter_secure_file_storage/src/secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FlutterSecureFileStorage {
  late final SecureStorage _secureStorage;
  final _keys = <String>[];

  FlutterSecureFileStorage(FlutterSecureStorage storage) {
    _secureStorage = SecureStorage(storage);
  }

  String _filename(String key) => '${base64Encode(utf8.encode(key))}.enc';

  /// Encrypts and saves the [key] with the given [value].
  ///
  /// If the key was already in the storage, its associated value is changed.
  /// If the value is null, deletes associated value for the given [key].
  Future<void> write({
    required String key,
    required String? value,
  }) async {
    assert(key.isNotEmpty, 'key must not be empty');
    if (value == null) return delete(key: key);
    final encryptionKey = await _secureStorage.getOrGenerateKey(key);
    final encryptionIV = await _secureStorage.generateIV(key);
    final encrypted = EncryptionUtil.encrypt(encryptionKey, encryptionIV, value);
    await FileStorage.write(_filename(key), encrypted);
    _keys.add(key);
  }

  /// Decrypts and returns the value for the given [key] or null if [key] is not in the storage.
  Future<String?> read({required String key}) async {
    assert(key.isNotEmpty, 'key must not be empty');
    final encryptionKey = await _secureStorage.getKeyOrNull(key);
    final encryptionIV = await _secureStorage.getIVOrNull(key);
    if (encryptionKey == null || encryptionIV == null) return null;
    final encrypted = await FileStorage.read(_filename(key));
    if (encrypted == null) return null;
    return EncryptionUtil.decrypt(encryptionKey, encryptionIV, encrypted);
  }

  /// Returns true if the storage contains the given [key].
  Future<bool> containsKey({
    required String key,
  }) async {
    assert(key.isNotEmpty, 'key must not be empty');
    if (!_keys.contains(key)) return false;
    final encryptionKey = await _secureStorage.getKeyOrNull(key);
    final encryptionIV = await _secureStorage.getIVOrNull(key);
    if (encryptionKey == null || encryptionIV == null) return false;
    return FileStorage.exists(_filename(key));
  }

  /// Deletes associated value for the given [key].
  Future<void> delete({
    required String key,
  }) async {
    assert(key.isNotEmpty, 'key must not be empty');
    await Future.wait([
      _secureStorage.deleteKey(key),
      _secureStorage.deleteIV(key),
      FileStorage.delete(_filename(key)),
    ]);
    _keys.remove(key);
  }

  /// Decrypts and returns all keys with associated values.
  Future<Map<String, String>> readAll() async {
    final map = <String, String>{};
    for (final key in _keys) {
      final value = await read(key: key);
      if (value != null) map[key] = value;
    }
    return map;
  }

  /// Deletes all keys with associated values.
  Future<void> deleteAll() => Future.wait(_keys.map((key) => delete(key: key)));
}
