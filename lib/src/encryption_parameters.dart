import 'dart:convert';
import 'dart:typed_data';

class EncryptionParameters {
  final Uint8List key;
  final Uint8List value;
  final Uint8List? iv;

  EncryptionParameters(this.key, this.value, {this.iv});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'key': key,
      if (iv != null) 'iv': iv,
      'value': value,
    };
  }

  factory EncryptionParameters.fromMap(Map<String, dynamic> map) {
    return EncryptionParameters(
      map['key'] as Uint8List,
      map['value'] as Uint8List,
      iv: map['iv'] as Uint8List?,
    );
  }

  String toJson() => json.encode(toMap());

  factory EncryptionParameters.fromJson(String source) =>
      EncryptionParameters.fromMap(json.decode(source) as Map<String, dynamic>);
}

class EncryptionResult {
  final Uint8List iv;
  final Uint8List value;

  EncryptionResult(this.iv, this.value);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'iv': iv,
      'value': value,
    };
  }

  factory EncryptionResult.fromMap(Map<String, dynamic> map) {
    return EncryptionResult(
      map['iv'] as Uint8List,
      map['value'] as Uint8List,
    );
  }

  String toJson() => json.encode(toMap());

  factory EncryptionResult.fromJson(String source) =>
      EncryptionResult.fromMap(json.decode(source) as Map<String, dynamic>);
}
