import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_secure_file_storage/flutter_secure_file_storage.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DocumentsFileStorage extends FileStorage {
  String? _outputPath;

  Future<String> get documentsPath async =>
      (await getApplicationDocumentsDirectory()).path;

  /// By default the files are saved under the root of your app documents folder.
  /// You could use a custom output path to save the file somewhere else in your app documents folder.
  void setCustomOutputPath(String outputPath) {
    _outputPath = outputPath;
  }

  Future<File> _localFile(String filename) async {
    final outputPath = _outputPath;
    if (outputPath == null) return File(join(await documentsPath, filename));
    return File(join(await documentsPath, outputPath, filename));
  }

  @override
  Future<Uint8List?> read(String filename) async {
    try {
      final file = await _localFile(filename);
      return file.readAsBytes();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> exists(String filename) async {
    try {
      final file = await _localFile(filename);
      return file.existsSync();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<File> write(String filename, Uint8List content) async {
    final file = await _localFile(filename);
    if (!file.existsSync()) {
      await file.create(recursive: true);
    }
    return file.writeAsBytes(content);
  }

  @override
  Future<void> delete(String filename) async {
    final file = await _localFile(filename);
    if (!file.existsSync()) return;
    await file.delete();
  }
}
