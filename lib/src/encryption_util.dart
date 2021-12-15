import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import "package:pointycastle/pointycastle.dart";

class EncryptionUtil {
  static Key generateSecureKey() => Key.fromSecureRandom(32);
  static IV generateSecureIV() => IV.fromSecureRandom(16);

  static BlockCipher _encrypter(Key key, IV iv, {bool encryptContent = false}) {
    return BlockCipher('AES/GCM')
      ..reset()
      ..init(encryptContent, ParametersWithIV<KeyParameter>(KeyParameter(key.bytes), iv.bytes));
  }

  static Uint8List _toUint8List(String string) => Uint8List.fromList(string.codeUnits);

  static String encrypt(Key key, IV iv, String value) {
    return base64Encode(_encrypter(key, iv, encryptContent: true).process(_toUint8List(value)));
  }

  static String decrypt(Key key, IV iv, String encrypted) {
    return utf8.decode(_encrypter(key, iv).process(base64Decode(encrypted)));
  }
}
