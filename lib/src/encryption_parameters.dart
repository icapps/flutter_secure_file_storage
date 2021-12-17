import 'dart:convert';
import 'dart:typed_data';

class EncryptionParameters {
  final Uint8List key;
  final Uint8List? iv;
  final Uint8List value;

  EncryptionParameters(this.key, this.value, {this.iv});

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      if (iv != null) 'iv': iv,
      'value': value,
    };
  }

  factory EncryptionParameters.fromMap(Map<String, dynamic> map) {
    return EncryptionParameters(
      map['key'],
      map['value'],
      iv: map['iv'],
    );
  }

  String toJson() => json.encode(toMap());

  factory EncryptionParameters.fromJson(String source) =>
      EncryptionParameters.fromMap(json.decode(source));
}

class EncryptionResult {
  final Uint8List iv;
  final Uint8List value;

  EncryptionResult(this.iv, this.value);

  Map<String, dynamic> toMap() {
    return {
      'iv': iv,
      'value': value,
    };
  }

  factory EncryptionResult.fromMap(Map<String, dynamic> map) {
    return EncryptionResult(
      map['iv'],
      map['value'],
    );
  }

  String toJson() => json.encode(toMap());

  factory EncryptionResult.fromJson(String source) =>
      EncryptionResult.fromMap(json.decode(source));
}
