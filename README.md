# Flutter secure file storage

[![pub package](https://img.shields.io/pub/v/flutter_secure_file_storage.svg)](https://pub.dartlang.org/packages/flutter_secure_file_storage)

An implementation for flutter secure file storage. For example keychain has a soft limit of 4kb. Using the file system instead we can store much larger content.

AES/GCM/NoPadding encryption is used to encrypt the data. The keys are generated using `Random.secure`and stored using the [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) package, the values are encrypted by the [pointycastle](https://pub.dev/packages/pointycastle) package or native for Android

## Usage

It's implemented to use the same structure as FlutterSecureStorage and therefore you can switch easily between them. But we also support Uint8List as input/output 

```dart
import 'package:flutter_secure_file_storage/flutter_secure_file_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Create storage
final storage = FlutterSecureFileStorage(FlutterSecureStorage());

// Read value
final value = await storage.read<String>(key: key);

// Read all values
Map<String, String> allValues = await storage.readAll();

// Delete value
await storage.delete(key: key);

// Delete all
await storage.deleteAll();

// Write value
await storage.write(key: key, value: value);
```

### Configure Android version 
In [project]/android/app/build.gradle set minSdkVersion to >= 18.

```
android {
    ...

    defaultConfig {
        ...
        minSdkVersion 18
        ...
    }

}
```
