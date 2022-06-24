## 0.0.8 - 24/06/2022
### Updated
* Dependencies

## 0.0.7 - 04/04/2022

### Breaking
* Updated the min sdk to 16 on Android
* Updated flutter_secure_file_storage

## 0.0.6 - 11/01/2022

### Refactor
* Refactorred the implementation. Using flutter_file_storage for shared implementation.

## 0.0.5 - 07/01/2022

### Fixed
* expose DocumentsFileStorage

## 0.0.4 - 07/01/2022

### Fixed
* bug where an empty key was saved to the `flutter_secure_file_storage_keys`
* Future & await issues
### Added
* support to override the fileStorage. By default we will use DocumentsFileStorage
* locking operations per key
* locking reading & writing the `flutter_secure_file_storage_keys`
### Breaking
* custom outputpath moved to the DocumentsFileStorage

## 0.0.3 - 06/01/2022

### Fixed
* bug where the `_keys` were not populated correctly (keys that were used before 0.0.3 will not be populated)
### Added
* Support for setting a custom output path

## 0.0.2 - 17/12/2021

* encrypt and decrypt native on Android and iOS > 12

## 0.0.1 - 16/12/2021

* encrypt and decrypt files automatically and storing the keys in secure storage
