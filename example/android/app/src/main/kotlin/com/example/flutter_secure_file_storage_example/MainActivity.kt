package com.example.flutter_secure_file_storage_example

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
  private val CHANNEL = "be.icapps.flutter_secure_file_storage_example"

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
      call, result -> 
      when (call.method) {
            'encrypt' -> encrypt(call, result),
            'decrypt' -> decrypt(call, result),
            else -> result.notImplemented()
      }
    }
  }
}