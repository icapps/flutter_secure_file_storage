import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_file_storage/src/file_storage/documents_file_storage.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_file_storage/src/encryption_util.dart';
import 'package:flutter_secure_file_storage/src/file_storage/file_storage.dart';
import 'package:flutter_secure_file_storage/src/secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:synchronized/synchronized.dart';

/// FlutterSecureFileStorage storage allows you to save, read and delete files
/// The files are saved using the fileStorage but the content is always encrypted using: AES/GCM
class FlutterSecureFileStorage {
  late final SecureStorage _secureStorage;
  late FileStorage _fileStorage;
  final _locksLock = Lock();
  final Map<String, Lock> _locks = {};
  var _keys = <String>{};

  String? _outputPath;

  /// FlutterSecureFileStorage will use
  ///   - storage to save the key, iv & encryptionKey
  ///   - fileStorage to save, read, delete the file with the encrypted content
  FlutterSecureFileStorage(FlutterSecureStorage storage,
      {FileStorage? fileStorage}) {
    _secureStorage = SecureStorage(storage);
    _fileStorage = fileStorage ?? DocumentsFileStorage();
  }

  /// Encrypts the given [value] with the encryption key associated with [key]
  ///
  /// The key itself is used to get or generate the:
  ///   IV: length: 16
  ///   encryptionKey: length 32
  /// The key is saved in flutter_secure_storage with base64 encoding.
  ///
  /// Encryption is done with: AES/GCM
  ///
  /// If the key was already in the storage, its associated value is changed.
  /// If the value is null, deletes associated value for the given [key].
  /// Supports String and Uint8List values.
  Future<void> write<T>({
    required String key,
    required T? value,
  }) async {
    assert(key.isNotEmpty, 'key must not be empty');
    await _synchronized(key, () async {
      if (value == null) return delete(key: key);
      assert(
          T == String || T == Uint8List, 'value must be String or Uint8List');
      final convertedValue = (value is String)
          ? Uint8List.fromList(utf8.encode(value))
          : value as Uint8List;
      final encryptionKey = await _secureStorage.getOrGenerateKey(key);
      final encrypted =
          await EncryptionUtil.encrypt(encryptionKey, convertedValue);
      if (encrypted == null) return delete(key: key);
      await _secureStorage.saveIV(key, encrypted.iv);
      await _fileStorage.write(_filename(key), encrypted.value);
      await _getKeys();
      _keys.add(key);
      await _updateKeys();
    });
  }

  /// Decrypts and returns the value for the given [key] or null if [key] is not in the storage.
  ///
  /// Supports String and Uint8List values.
  Future<T?> read<T>({required String key}) async {
    assert(key.isNotEmpty, 'key must not be empty');
    return _synchronized(key, () async {
      final encryptionKey = await _secureStorage.getKeyOrNull(key);
      final encryptionIV = await _secureStorage.getIVOrNull(key);
      if (encryptionKey == null || encryptionIV == null) return null;
      final encrypted = await _fileStorage.read(_filename(key));
      if (encrypted == null) return null;
      final result =
          await EncryptionUtil.decrypt(encryptionKey, encryptionIV, encrypted);
      if (result == null) return null;
      if (T == String) return utf8.decode(result) as T;
      return result as T;
    });
  }

  /// Returns true if the storage contains the given [key].
  Future<bool> containsKey({
    required String key,
  }) async {
    assert(key.isNotEmpty, 'key must not be empty');
    return _synchronized(key, () async {
      await _getKeys();
      if (!_keys.contains(key)) return false;
      final encryptionKey = await _secureStorage.getKeyOrNull(key);
      final encryptionIV = await _secureStorage.getIVOrNull(key);
      if (encryptionKey == null || encryptionIV == null) return false;
      return _fileStorage.exists(_filename(key));
    });
  }

  /// Deletes associated value for the given [key].
  ///
  /// All associated data for the given key is removed
  Future<void> delete({
    required String key,
  }) async {
    assert(key.isNotEmpty, 'key must not be empty');
    await _synchronized(key, () async {
      await Future.wait([
        _secureStorage.deleteKey(key),
        _secureStorage.deleteIV(key),
        _fileStorage.delete(_filename(key)),
      ]);
      await _getKeys();
      _keys.remove(key);
      await _updateKeys();
    });
  }

  /// Returns all keys with associated values.
  Future<Set<String>> getAllKeys() async {
    await _getKeys();
    return _keys;
  }

  /// Deletes all keys with associated values.
  Future<void> deleteAll() async {
    await _getKeys();
    await Future.wait(_keys.map((key) => delete(key: key)));
    await _getKeys();
  }

  String _filename(String key) {
    final fileName = '${base64Encode(utf8.encode(key))}.enc';
    final outputPath = _outputPath;
    if (outputPath == null) return fileName;
    return join(outputPath, fileName);
  }

  Future<void> _updateKeys() async {
    final encodedData = _keys.map((e) => base64Encode(utf8.encode(e))).toList();
    await _secureStorage.saveKeys(encodedData);
  }

  Future<void> _getKeys() async {
    final decodedData = await _secureStorage.readKeys();
    _keys = decodedData.map((e) => utf8.decode(base64Decode(e))).toSet();
  }

  Future<T> _synchronized<T>(
    String key,
    FutureOr<T> Function() computation,
  ) async {
    final lock = await _locksLock.synchronized(
        () => _locks.putIfAbsent(key, () => Lock(reentrant: true)));
    try {
      final result = await lock.synchronized(() => computation.call());
      await _locksLock.synchronized(() => _locks.remove(lock));
      return result;
    } finally {
      await _locksLock.synchronized(() => _locks.remove(lock));
    }
  }
}
