import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_file_storage/src/encryption_parameters.dart';
import "package:pointycastle/pointycastle.dart";

class EncryptionUtil {
  static final Random _generator = Random.secure();
  static const platform = MethodChannel('be.icapps.flutter_secure_file_storage');

  static Future<bool> get isPlaformSupported async => Platform.isAndroid || (Platform.isIOS && (await DeviceInfoPlugin().iosInfo).systemVersion?.startsWith('12.') != true);

  static Uint8List generateSecureKey() => _fromSecureRandom(32);

  static Uint8List generateSecureIV() => _fromSecureRandom(16);

  static BlockCipher _encrypter(Uint8List key, Uint8List iv, {bool encryptContent = false}) {
    return BlockCipher('AES/GCM')
      ..reset()
      ..init(encryptContent, ParametersWithIV<KeyParameter>(KeyParameter(key), iv));
  }

  static Future<EncryptionResult?> encrypt(Uint8List key, Uint8List value) async {
    if (await isPlaformSupported) {
      final result = await platform.invokeMethod('encrypt', EncryptionParameters(key, value).toMap());
      if (result == null) return null;
      return EncryptionResult.fromMap(Map<String, dynamic>.from(result));
    }
    final iv = generateSecureIV();
    final result = _encrypter(key, iv, encryptContent: true).process(value);
    return EncryptionResult(iv, result);
  }

  static Future<Uint8List?> decrypt(Uint8List key, Uint8List iv, Uint8List encrypted) async {
    if (await isPlaformSupported) {
      return platform.invokeMethod<Uint8List>('decrypt', EncryptionParameters(key, encrypted, iv: iv).toMap());
    }
    return _encrypter(key, iv).process(encrypted);
  }

  static Uint8List _fromSecureRandom(int length) {
    return Uint8List.fromList(List.generate(length, (i) => _generator.nextInt(256)));
  }
}
