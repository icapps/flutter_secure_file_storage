import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_file_storage/src/encryption_parameters.dart';
import "package:pointycastle/pointycastle.dart";

class EncryptionUtil {
  static final Random _generator = Random.secure();
  static const platform =
      MethodChannel('com.icapps.flutter_secure_file_storage');

  static final _isSupported = AsyncMemoizer<bool>();

  static Future<bool> get isPlatformSupported =>
      _isSupported.runOnce(() async =>
          !kIsWeb &&
          (Platform.isAndroid ||
              (Platform.isIOS &&
                  (await platform.invokeMethod<bool>('isSupported')) == true)));

  static Uint8List generateSecureKey() => _fromSecureRandom(32);

  static Uint8List generateSecureIV() => _fromSecureRandom(16);

  static BlockCipher _encrypter(Uint8List key, Uint8List iv,
      {bool encryptContent = false}) {
    return BlockCipher('AES/GCM')
      ..reset()
      ..init(encryptContent,
          ParametersWithIV<KeyParameter>(KeyParameter(key), iv));
  }

  static Future<EncryptionResult?> encrypt(
      Uint8List key, Uint8List value) async {
    if (await isPlatformSupported) {
      final result = await platform.invokeMethod<Map>(
          'encrypt', EncryptionParameters(key, value).toMap());
      if (result == null) return null;
      return EncryptionResult.fromMap(Map<String, dynamic>.from(result));
    }
    return compute(_doEncrypt, EncryptionParameters(key, value));
  }

  static Future<Uint8List?> decrypt(
      Uint8List key, Uint8List iv, Uint8List encrypted) async {
    if (await isPlatformSupported) {
      return platform.invokeMethod<Uint8List>(
          'decrypt', EncryptionParameters(key, encrypted, iv: iv).toMap());
    }
    return compute(_doDecrypt, EncryptionParameters(key, encrypted, iv: iv));
  }

  static Uint8List _fromSecureRandom(int length) {
    return Uint8List.fromList(
        List.generate(length, (i) => _generator.nextInt(256)));
  }

  static FutureOr<EncryptionResult?> _doEncrypt(EncryptionParameters message) {
    final iv = generateSecureIV();
    final result = _encrypter(message.key, iv, encryptContent: true)
        .process(message.value);
    return EncryptionResult(iv, result);
  }

  static FutureOr<Uint8List?> _doDecrypt(EncryptionParameters message) {
    return _encrypter(message.key, message.iv!).process(message.value);
  }
}
