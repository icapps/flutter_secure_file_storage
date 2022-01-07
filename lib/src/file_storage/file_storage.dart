import 'dart:io';
import 'dart:typed_data';

abstract class FileStorage {
  Future<Uint8List?> read(String filename);

  Future<bool> exists(String filename);

  Future<File> write(String filename, Uint8List content);

  Future<void> delete(String filename);
}
