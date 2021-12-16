import 'package:flutter/material.dart';

import 'package:flutter_secure_file_storage/flutter_secure_file_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _content = '';
  String _loadedContent = '';
  String _key = '';
  bool _loading = false;
  late final FlutterSecureFileStorage _fileStorage;

  @override
  void initState() {
    super.initState();
    _fileStorage = FlutterSecureFileStorage(const FlutterSecureStorage());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter secure file storage app'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Key',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _key = value;
                    });
                  },
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Content',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _content = value;
                    });
                  },
                ),
                MaterialButton(
                  child: const Text('Save'),
                  onPressed: () async {
                    setState(() {
                      _loading = true;
                    });
                    await _fileStorage.write(key: _key, value: _content);
                    setState(() {
                      _loading = false;
                    });
                  },
                ),
                MaterialButton(
                  child: const Text('Load from key'),
                  onPressed: () async {
                    setState(() {
                      _loading = true;
                    });
                    final content = await _fileStorage.read<String>(key: _key);
                    setState(() {
                      _loadedContent = content ?? '';
                      _loading = false;
                    });
                  },
                ),
                if (_loading) ...[
                  const CircularProgressIndicator(),
                ] else ...[
                  Text('Content from file: $_loadedContent'),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
