# Flutter secure file storage

An implementation for flutter secure file storage. For example keychain has a soft limit of 4kb. Using the file system instead we can store much larger content

AES encryption is used to encrypt the data. The keys are generated using the [encrypt](https://pub.dev/packages/encrypt) package and stored using the [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) package

## Usage

It's implemented to use the same structure as FlutterSecureStorage and therefore you can switch easily between them.

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Create storage
final storage = FlutterSecureFileStorage(FlutterSecureStorage());

// Read value
String value = await storage.read(key: key);

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