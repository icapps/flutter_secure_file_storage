import 'dart:convert';
import 'dart:typed_data';

class EncryptionParameters {
  final Uint8List key;
  final Uint8List iv;
  final String value;

  EncryptionParameters(this.key, this.iv, this.value);

  Map<String, dynamic> toMap() {
    return {
      'key': key.toList(),
      'iv': iv.toList(),
      'value': value,
    };
  }

  factory EncryptionParameters.fromMap(Map<String, dynamic> map) {
    return EncryptionParameters(
      Uint8List.fromList(map['key']),
      Uint8List.fromList(map['iv']),
      map['value'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory EncryptionParameters.fromJson(String source) => EncryptionParameters.fromMap(json.decode(source));
}
