import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FileStorage {
  String? outputPath;

  FileStorage();

  Future<String> get documentsPath async => (await getApplicationDocumentsDirectory()).path;

  Future<File> _localFile(String filename) async {
    final outputPath = this.outputPath;
    if (outputPath == null) return File(join(await documentsPath, filename));
    return File(join(await documentsPath, outputPath, filename));
  }

  Future<Uint8List?> read(String filename) async {
    try {
      final file = await _localFile(filename);
      return file.readAsBytes();
    } catch (e) {
      return null;
    }
  }

  Future<bool> exists(String filename) async {
    try {
      final file = await _localFile(filename);
      return file.existsSync();
    } catch (e) {
      return false;
    }
  }

  Future<File> write(String filename, Uint8List content) async {
    final file = await _localFile(filename);
    if (!file.existsSync()) {
      await file.create(recursive: true);
    }
    return file.writeAsBytes(content);
  }

  Future<void> delete(String filename) async {
    final file = await _localFile(filename);
    if (!file.existsSync()) return;
    await file.delete();
  }
}
