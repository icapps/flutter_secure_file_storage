import 'dart:convert';
import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:flutter_secure_file_storage/src/encryption_util.dart';
import 'package:flutter_secure_file_storage/src/file_storage.dart';
import 'package:flutter_secure_file_storage/src/secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FlutterSecureFileStorage {
  late final SecureStorage _secureStorage;
  final _fileStorage = FileStorage();
  var _keys = <String>[];

  String? _outputPath;

  FlutterSecureFileStorage(FlutterSecureStorage storage) {
    _secureStorage = SecureStorage(storage);
  }

  /// Set a custom output path, So not all files are generated at the same location.
  ///
  /// Default location is under the app documents folder
  void setCustomOutputPath(String outputPath) {
    _fileStorage.outputPath = outputPath;
  }

  /// Encrypts and saves the [key] with the given [value].
  ///
  /// If the key was already in the storage, its associated value is changed.
  /// If the value is null, deletes associated value for the given [key].
  /// Supports String and Uint8List values.
  Future<void> write<T>({
    required String key,
    required T? value,
  }) async {
    assert(key.isNotEmpty, 'key must not be empty');
    if (value == null) return delete(key: key);
    assert(T == String || T == Uint8List, 'value must be String or Uint8List');
    final convertedValue = (value is String)
        ? Uint8List.fromList(utf8.encode(value))
        : value as Uint8List;
    final encryptionKey = await _secureStorage.getOrGenerateKey(key);
    final encrypted =
        await EncryptionUtil.encrypt(encryptionKey, convertedValue);
    if (encrypted == null) return delete(key: key);
    await _secureStorage.saveIV(key, encrypted.iv);
    await _fileStorage.write(_filename(key), encrypted.value);
    _keys.add(key);
    _updateKeys();
  }

  /// Decrypts and returns the value for the given [key] or null if [key] is not in the storage.
  /// Supports String and Uint8List values.
  Future<T?> read<T>({required String key}) async {
    assert(key.isNotEmpty, 'key must not be empty');
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
  }

  /// Returns true if the storage contains the given [key].
  Future<bool> containsKey({
    required String key,
  }) async {
    assert(key.isNotEmpty, 'key must not be empty');
    await _getKeys();
    if (!_keys.contains(key)) return false;
    final encryptionKey = await _secureStorage.getKeyOrNull(key);
    final encryptionIV = await _secureStorage.getIVOrNull(key);
    if (encryptionKey == null || encryptionIV == null) return false;
    return _fileStorage.exists(_filename(key));
  }

  /// Deletes associated value for the given [key].
  Future<void> delete({
    required String key,
  }) async {
    assert(key.isNotEmpty, 'key must not be empty');
    await Future.wait([
      _secureStorage.deleteKey(key),
      _secureStorage.deleteIV(key),
      _fileStorage.delete(_filename(key)),
    ]);
    _keys.remove(key);
    _updateKeys();
  }

  /// Decrypts and returns all keys with associated values.
  Future<Map<String, String>> readAll() async {
    await _getKeys();
    final map = <String, String>{};
    for (final key in _keys) {
      final value = await read(key: key);
      if (value != null) map[key] = value;
    }
    return map;
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

  Future<void> _updateKeys() async => _secureStorage.saveKeys(_keys);

  Future<void> _getKeys() async => _keys = await _secureStorage.readKeys();
}
