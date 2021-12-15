import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileStorage {
  static Future<String> get _localPath async => (await getApplicationDocumentsDirectory()).path;

  static Future<File> _localFile(String filename) async => File('${await _localPath}/$filename');

  static Future<String?> read(String filename) async {
    try {
      final file = await _localFile(filename);
      return file.readAsString();
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

  static Future<File> write(String filename, String content) async {
    final file = await _localFile(filename);
    return file.writeAsString(content);
  }

  static Future<void> delete(String filename) async {
    final file = await _localFile(filename);
    if (!await file.exists()) return;
    await file.delete();
  }
}
