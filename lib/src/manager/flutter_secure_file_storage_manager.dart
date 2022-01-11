import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_key_value_file_storage/flutter_key_value_file_storage.dart';
import 'package:flutter_secure_file_storage/src/encryption_util.dart';
import 'package:flutter_secure_file_storage/src/secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureFileStorageManager extends FileStorageManager {
  static const _keysStorageKeyDefault = 'flutter_secure_file_storage_keys';

  late final SecureStorage _secureStorage;

  SecureFileStorageManager(
    FlutterSecureStorage storage, {
    FileStorage? fileStorage,
    String? keysStorageKey,
  }) : super(
          storage,
          fileStorage: fileStorage,
          keysStorageKey: keysStorageKey ?? _keysStorageKeyDefault,
        ) {
    _secureStorage = SecureStorage(storage);
  }

  @override
  Future<void> performWrite(
      {required String key, required Uint8List value}) async {
    final encryptionKey = await _secureStorage.getOrGenerateKey(key);
    final encrypted = await EncryptionUtil.encrypt(encryptionKey, value);
    if (encrypted == null) return delete(key: key);
    await _secureStorage.saveIV(key, encrypted.iv);
    await fileStorage.write(_filename(key), encrypted.value);
  }

  @override
  Future<Uint8List?> performRead({required String key}) async {
    final encryptionKey = await _secureStorage.getKeyOrNull(key);
    final encryptionIV = await _secureStorage.getIVOrNull(key);
    if (encryptionKey == null || encryptionIV == null) return null;
    final encrypted = await fileStorage.read(_filename(key));
    if (encrypted == null) return null;
    return EncryptionUtil.decrypt(encryptionKey, encryptionIV, encrypted);
  }

  @override
  Future<bool> performContainsKey({required String key}) async {
    final encryptionKey = await _secureStorage.getKeyOrNull(key);
    final encryptionIV = await _secureStorage.getIVOrNull(key);
    if (encryptionKey == null || encryptionIV == null) return false;
    return fileStorage.exists(_filename(key));
  }

  @override
  Future<void> performDelete({required String key}) async {
    await Future.wait([
      _secureStorage.deleteKey(key),
      _secureStorage.deleteIV(key),
      fileStorage.delete(_filename(key)),
    ]);
  }

  String _filename(String key) => '${base64Encode(utf8.encode(key))}.enc';
}
