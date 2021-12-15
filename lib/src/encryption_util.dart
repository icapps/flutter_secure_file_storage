import 'package:encrypt/encrypt.dart';

class EncryptionUtil {
  static Key generateSecureKey() => Key.fromSecureRandom(32);
  static IV generateSecureIV() => IV.fromSecureRandom(16);

  static _encrypter(Key key) => Encrypter(AES(key));

  static String encrypt(Key key, IV iv, String value) => _encrypter(key).encrypt(value, iv: iv).base64;

  static String decrypt(Key key, IV iv, String encrypted) => _encrypter(key).decrypt64(encrypted, iv: iv);
}
