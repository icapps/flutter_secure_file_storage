import 'dart:async';

import 'package:flutter_key_value_file_storage/flutter_key_value_file_storage.dart';
import 'package:flutter_secure_file_storage/src/manager/flutter_secure_file_storage_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// FlutterSecureFileStorage storage allows you to save, read and delete files
/// The files are saved using the fileStorage but the content is always encrypted using: AES/GCM
class FlutterSecureFileStorage {
  late final FileStorageManager fileStorageManager;

  /// FlutterSecureFileStorage will use
  ///   - storage to save the key, iv & encryptionKey
  ///   - fileStorage to save, read, delete the file with the encrypted content
  FlutterSecureFileStorage(FlutterSecureStorage storage,
      {FileStorage? fileStorage}) {
    fileStorageManager = SecureFileStorageManager(
      storage,
      fileStorage: fileStorage,
    );
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
  }) async =>
      fileStorageManager.write<T>(key: key, value: value);

  /// Decrypts and returns the value for the given [key] or null if [key] is not in the storage.
  ///
  /// Supports String and Uint8List values.
  Future<T?> read<T>({required String key}) async =>
      fileStorageManager.read<T>(key: key);

  /// Returns true if the storage contains the given [key].
  Future<bool> containsKey({
    required String key,
  }) async =>
      fileStorageManager.containsKey(key: key);

  /// Deletes associated value for the given [key].
  ///
  /// All associated data for the given key is removed
  Future<void> delete({
    required String key,
  }) async =>
      fileStorageManager.delete(key: key);

  /// Returns all keys with associated values.
  Future<Set<String>> getAllKeys() async => fileStorageManager.getAllKeys();

  /// Deletes all keys with associated values.
  Future<void> deleteAll() async => fileStorageManager.deleteAll();
}
