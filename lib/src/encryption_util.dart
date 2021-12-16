import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_secure_file_storage/src/encryption_parameters.dart';
import "package:pointycastle/pointycastle.dart";

class EncryptionUtil {
  static final Random _generator = Random.secure();
  static const platform = MethodChannel('be.icapps.flutter_secure_file_storage');

  static bool get isPlaformSupported => Platform.isAndroid;

  static Uint8List generateSecureKey() => _fromSecureRandom(32);

  static Uint8List generateSecureIV() => _fromSecureRandom(16);

  static BlockCipher _encrypter(Uint8List key, Uint8List iv, {bool encryptContent = false}) {
    return BlockCipher('AES/GCM')
      ..reset()
      ..init(encryptContent, ParametersWithIV<KeyParameter>(KeyParameter(key), iv));
  }

  static Uint8List _toUint8List(String string) => Uint8List.fromList(string.codeUnits);

  static Future<EncryptionResult?> encrypt(Uint8List key, String value) async {
    if (isPlaformSupported) {
      final result = await platform.invokeMethod<Map<String, dynamic>>('encrypt', EncryptionParameters(key, value).toMap());
      if (result == null) return null;
      return EncryptionResult.fromMap(result);
    }
    final iv = generateSecureIV();
    final result = base64Encode(_encrypter(key, iv, encryptContent: true).process(_toUint8List(value)));
    return EncryptionResult(iv, result);
  }

  static Future<String?> decrypt(Uint8List key, Uint8List iv, String encrypted) async {
    if (isPlaformSupported) {
      return platform.invokeMethod<String>('decrypt', EncryptionParameters(key, encrypted).toMap());
    }
    return utf8.decode(_encrypter(key, iv).process(base64Decode(encrypted)));
  }

  static Uint8List _fromSecureRandom(int length) {
    return Uint8List.fromList(List.generate(length, (i) => _generator.nextInt(256)));
  }
}
