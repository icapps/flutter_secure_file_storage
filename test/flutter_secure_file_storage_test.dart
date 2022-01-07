import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_secure_file_storage/flutter_secure_file_storage.dart';
import 'package:flutter_secure_file_storage/src/file_storage/file_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'flutter_secure_file_storage_test.mocks.dart';

@GenerateMocks([
  FlutterSecureStorage,
  FileStorage,
])
void main() {
  group('Test the FlutterSecureFileStorage', () {
    test('Single write', () async {
      final mockSecureStorage = MockFlutterSecureStorage();
      final mockFileStorage = MockFileStorage();
      when(mockSecureStorage.write(
              key: 'flutter_secure_file_storage_keys', value: 'dGVzdA=='))
          .thenAnswer((realInvocation) => Future.value());
      when(mockSecureStorage.read(key: 'test-key')).thenAnswer(
          (realInvocation) async => 'test-key123456789123456789123456');
      when(mockSecureStorage.read(key: 'test-iv'))
          .thenAnswer((realInvocation) async => 'test-iv123456789');
      when(mockSecureStorage.read(key: 'flutter_secure_file_storage_keys'))
          .thenAnswer((realInvocation) async => null);
      when(mockFileStorage.write(
        'dGVzdA==.enc',
        any, //because of a random generated keys
      )).thenAnswer((realInvocation) async => File('test_path'));
      final flutterSecureStorage = FlutterSecureFileStorage(mockSecureStorage,
          fileStorage: mockFileStorage);
      await flutterSecureStorage.write(key: 'test', value: 'content');
      verify(mockSecureStorage.write(key: 'test-iv', value: anyNamed('value')))
          .called(1);
      verify(mockSecureStorage.write(
              key: 'flutter_secure_file_storage_keys', value: 'dGVzdA=='))
          .called(1);
      verify(mockSecureStorage.read(key: 'test-key')).called(1);
      verify(mockSecureStorage.read(key: 'flutter_secure_file_storage_keys'))
          .called(1);
      verifyNoMoreInteractions(mockSecureStorage);

      verify(mockFileStorage.write('dGVzdA==.enc', any)).called(1);
      verifyNoMoreInteractions(mockFileStorage);
    });
    test('2 writes', () async {
      final mockSecureStorage = MockFlutterSecureStorage();
      final mockFileStorage = MockFileStorage();
      when(mockSecureStorage.write(
              key: 'flutter_secure_file_storage_keys', value: ''))
          .thenAnswer((realInvocation) => Future.value());
      when(mockSecureStorage.read(key: 'test-key')).thenAnswer(
          (realInvocation) async => 'test-key123456789123456789123456');
      when(mockSecureStorage.read(key: 'test-iv'))
          .thenAnswer((realInvocation) async => 'test-iv123456789');
      when(mockSecureStorage.read(key: 'flutter_secure_file_storage_keys'))
          .thenAnswer((realInvocation) async => null);
      when(mockFileStorage.write(
        'dGVzdA==.enc',
        any, //because of a random generated keys
      )).thenAnswer((realInvocation) async => File('test_path'));
      final flutterSecureFileStorage = FlutterSecureFileStorage(
          mockSecureStorage,
          fileStorage: mockFileStorage);
      await flutterSecureFileStorage.write(key: 'test', value: 'content');
      verify(mockSecureStorage.write(key: 'test-iv', value: anyNamed('value')))
          .called(1);
      reset(mockFileStorage);
      reset(mockSecureStorage);

      when(mockSecureStorage.write(
              key: 'flutter_secure_file_storage_keys', value: ''))
          .thenAnswer((realInvocation) => Future.value());
      when(mockSecureStorage.read(key: 'test2-key')).thenAnswer(
          (realInvocation) async => 'test2-key12345678912345678912345');
      when(mockSecureStorage.read(key: 'test2-iv'))
          .thenAnswer((realInvocation) async => 'test2-iv12345678');
      when(mockSecureStorage.read(key: 'flutter_secure_file_storage_keys'))
          .thenAnswer((realInvocation) async => 'dGVzdA==');
      when(mockFileStorage.write(
        'dGVzdDI=.enc',
        any, //because of a random generated keys
      )).thenAnswer((realInvocation) async => File('test_path'));

      await flutterSecureFileStorage.write(key: 'test2', value: 'content');
      verify(mockSecureStorage.write(key: 'test2-iv', value: anyNamed('value')))
          .called(1);
      verify(mockSecureStorage.write(
              key: 'flutter_secure_file_storage_keys',
              value: 'dGVzdA==,dGVzdDI='))
          .called(1);
      verify(mockSecureStorage.read(key: 'flutter_secure_file_storage_keys'))
          .called(1);
      verify(mockSecureStorage.read(key: 'test2-key')).called(1);
      verifyNoMoreInteractions(mockSecureStorage);

      verify(mockFileStorage.write('dGVzdDI=.enc', any)).called(1);
      verifyNoMoreInteractions(mockFileStorage);
    });
  });
}
