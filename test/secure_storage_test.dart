import 'package:flutter_secure_file_storage/src/secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'secure_storage_test.mocks.dart';

@GenerateMocks([
  FlutterSecureStorage,
])
void main() {
  group('Test the write keys', () {
    test('Write empty list', () async {
      final mockSecureStorage = MockFlutterSecureStorage();
      when(mockSecureStorage.write(
              key: 'flutter_secure_file_storage_keys', value: ''))
          .thenAnswer((realInvocation) => Future.value());
      when(mockSecureStorage.read(key: 'flutter_secure_file_storage_keys'))
          .thenAnswer((realInvocation) async => '');
      final secureStorage = SecureStorage(mockSecureStorage);
      await secureStorage.saveKeys([]);
      verify(mockSecureStorage.delete(key: 'flutter_secure_file_storage_keys'))
          .called(1);
      verifyNoMoreInteractions(mockSecureStorage);
    });
    test('Empty text', () async {
      final mockSecureStorage = MockFlutterSecureStorage();
      when(mockSecureStorage.write(
              key: 'flutter_secure_file_storage_keys', value: ''))
          .thenAnswer((realInvocation) => Future.value());
      final secureStorage = SecureStorage(mockSecureStorage);
      await secureStorage.saveKeys(['']);
      verify(mockSecureStorage.write(
              key: 'flutter_secure_file_storage_keys', value: ''))
          .called(1);
      verifyNoMoreInteractions(mockSecureStorage);
    });
    test('1 value', () async {
      final mockSecureStorage = MockFlutterSecureStorage();
      when(mockSecureStorage.write(
              key: 'flutter_secure_file_storage_keys', value: 'test'))
          .thenAnswer((realInvocation) => Future.value());
      final secureStorage = SecureStorage(mockSecureStorage);
      await secureStorage.saveKeys(['test']);
      verify(mockSecureStorage.write(
              key: 'flutter_secure_file_storage_keys', value: 'test'))
          .called(1);
      verifyNoMoreInteractions(mockSecureStorage);
    });
    test('2 values', () async {
      final mockSecureStorage = MockFlutterSecureStorage();
      when(mockSecureStorage.write(
              key: 'flutter_secure_file_storage_keys', value: 'test,test2'))
          .thenAnswer((realInvocation) => Future.value());
      final secureStorage = SecureStorage(mockSecureStorage);
      await secureStorage.saveKeys(['test', 'test2']);
      verify(mockSecureStorage.write(
              key: 'flutter_secure_file_storage_keys', value: 'test,test2'))
          .called(1);
      verifyNoMoreInteractions(mockSecureStorage);
    });
  });
  group('Test the read keys', () {
    test('Null value', () async {
      final mockSecureStorage = MockFlutterSecureStorage();
      when(mockSecureStorage.read(key: 'flutter_secure_file_storage_keys'))
          .thenAnswer((realInvocation) async => null);
      final secureStorage = SecureStorage(mockSecureStorage);
      final data = await secureStorage.readKeys();
      expect(data, <String>[]);
      verify(mockSecureStorage.read(key: 'flutter_secure_file_storage_keys'))
          .called(1);
      verifyNoMoreInteractions(mockSecureStorage);
    });
    test('Empty text', () async {
      final mockSecureStorage = MockFlutterSecureStorage();
      when(mockSecureStorage.read(key: 'flutter_secure_file_storage_keys'))
          .thenAnswer((realInvocation) async => '');
      final secureStorage = SecureStorage(mockSecureStorage);
      final data = await secureStorage.readKeys();
      expect(data, ['']);
      verify(mockSecureStorage.read(key: 'flutter_secure_file_storage_keys'))
          .called(1);
      verifyNoMoreInteractions(mockSecureStorage);
    });
    test('1 value', () async {
      final mockSecureStorage = MockFlutterSecureStorage();
      when(mockSecureStorage.read(key: 'flutter_secure_file_storage_keys'))
          .thenAnswer((realInvocation) async => 'test');
      final secureStorage = SecureStorage(mockSecureStorage);
      final data = await secureStorage.readKeys();
      expect(data, ['test']);
      verify(mockSecureStorage.read(key: 'flutter_secure_file_storage_keys'))
          .called(1);
      verifyNoMoreInteractions(mockSecureStorage);
    });
    test('2 values', () async {
      final mockSecureStorage = MockFlutterSecureStorage();
      when(mockSecureStorage.read(key: 'flutter_secure_file_storage_keys'))
          .thenAnswer(
              (realInvocation) async => 'sdalkjfia3924e,sdajlkfjal390u2');
      final secureStorage = SecureStorage(mockSecureStorage);
      final data = await secureStorage.readKeys();
      expect(data, ['sdalkjfia3924e', 'sdajlkfjal390u2']);
      verify(mockSecureStorage.read(key: 'flutter_secure_file_storage_keys'))
          .called(1);
      verifyNoMoreInteractions(mockSecureStorage);
    });
  });
}
