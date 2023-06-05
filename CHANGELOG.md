## 1.0.0
### Breaking
* Min dart version 3.0.0

## 0.1.0
### Updated
* Dependencies

### Fixed
* Supported ios version check has been fixed for < 12
* Use compute to encrypt on platforms without direct channel support
* Cleanup code

## 0.0.8
### Updated
* Dependencies

## 0.0.7

### Breaking
* Updated the min sdk to 16 on Android
* Updated flutter_secure_file_storage

## 0.0.6

### Refactor
* Refactorred the implementation. Using flutter_file_storage for shared implementation.

## 0.0.5

### Fixed
* expose DocumentsFileStorage

## 0.0.4

### Fixed
* bug where an empty key was saved to the `flutter_secure_file_storage_keys`
* Future & await issues
### Added
* support to override the fileStorage. By default we will use DocumentsFileStorage
* locking operations per key
* locking reading & writing the `flutter_secure_file_storage_keys`
### Breaking
* custom outputpath moved to the DocumentsFileStorage

## 0.0.3

### Fixed
* bug where the `_keys` were not populated correctly (keys that were used before 0.0.3 will not be populated)
### Added
* Support for setting a custom output path

## 0.0.2

* encrypt and decrypt native on Android and iOS > 12

## 0.0.1

* encrypt and decrypt files automatically and storing the keys in secure storage
