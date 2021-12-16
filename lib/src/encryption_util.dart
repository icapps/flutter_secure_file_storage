import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import "package:pointycastle/pointycastle.dart";

class EncryptionUtil {
  static final Random _generator = Random.secure();

  static Uint8List generateSecureKey() => _fromSecureRandom(32);
  static Uint8List generateSecureIV() => _fromSecureRandom(16);

  static BlockCipher _encrypter(Uint8List key, Uint8List iv, {bool encryptContent = false}) {
    return BlockCipher('AES/GCM')
      ..reset()
      ..init(encryptContent, ParametersWithIV<KeyParameter>(KeyParameter(key), iv));
  }

  static Uint8List _toUint8List(String string) => Uint8List.fromList(string.codeUnits);

  static String encrypt(Uint8List key, Uint8List iv, String value) {
    return base64Encode(_encrypter(key, iv, encryptContent: true).process(_toUint8List(value)));
  }

  static String decrypt(Uint8List key, Uint8List iv, String encrypted) {
    return utf8.decode(_encrypter(key, iv).process(base64Decode(encrypted)));
  }

  static Uint8List _fromSecureRandom(int length) {
    return Uint8List.fromList(List.generate(length, (i) => _generator.nextInt(256)));
  }
}
