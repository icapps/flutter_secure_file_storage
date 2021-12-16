import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class FileStorage {
  static Future<String> get _localPath async => (await getApplicationDocumentsDirectory()).path;

  static Future<File> _localFile(String filename) async => File('${await _localPath}/$filename');

  static Future<Uint8List?> read(String filename) async {
    try {
      final file = await _localFile(filename);
      return file.readAsBytes();
    } catch (e) {
      return null;
    }
  }

  static Future<bool> exists(String filename) async {
    try {
      final file = await _localFile(filename);
      return file.exists();
    } catch (e) {
      return false;
    }
  }

  static Future<File> write(String filename, Uint8List content) async {
    final file = await _localFile(filename);
    return file.writeAsBytes(content);
  }

  static Future<void> delete(String filename) async {
    final file = await _localFile(filename);
    if (!await file.exists()) return;
    await file.delete();
  }
}
