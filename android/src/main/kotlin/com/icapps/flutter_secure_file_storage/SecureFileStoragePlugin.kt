package com.icapps.flutter_secure_file_storage

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import javax.crypto.Cipher
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.SecretKeySpec

class SecureFileStoragePlugin : MethodCallHandler, FlutterPlugin {

    private var methodChannel: MethodChannel? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(binding.binaryMessenger, "be.icapps.flutter_secure_file_storage").also {
            it.setMethodCallHandler(this)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        try {
            when (call.method) {
                "encrypt" -> encryptToFile(
                    call.argument<ByteArray>("key")!!,
                    call.argument<ByteArray>("value")!!,
                    result,
                )
                "decrypt" -> decryptFile(
                    call.argument<ByteArray>("key")!!,
                    call.argument<ByteArray>("iv")!!,
                    call.argument<ByteArray>("value")!!,
                    result,
                )
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            result.error("500", e.message, e.stackTraceToString())
        }
    }

    private fun encryptToFile(
        key: ByteArray,
        data: ByteArray,
        result: Result,
    ) {
        Thread {
            try {
                val aesKey = SecretKeySpec(key, "AES")

                val cipher = Cipher.getInstance("AES/GCM/NoPadding")
                cipher.init(Cipher.ENCRYPT_MODE, aesKey)
                val iv = cipher.iv.copyOf()

                val rawData = cipher.doFinal(data)

                mainHandler.post {
                    result.success(mapOf("iv" to iv, "value" to rawData))
                }
            } catch (error: Throwable) {
                mainHandler.post {
                    result.error("500", error.message, error.stackTraceToString())
                }
            }
        }.start()
    }

    private fun decryptFile(
        key: ByteArray,
        iv: ByteArray,
        data: ByteArray,
        result: Result
    ) {
        Thread {
            try {
                val aesKey = SecretKeySpec(key, "AES")

                val cipher = Cipher.getInstance("AES/GCM/NoPadding")
                cipher.init(Cipher.DECRYPT_MODE, aesKey, GCMParameterSpec(128, iv))

                val output = cipher.doFinal(data)

                mainHandler.post {
                    result.success(output)
                }
            } catch (error: Throwable) {
                mainHandler.post {
                    result.error("500", error.message, error.stackTraceToString())
                }
            }
        }.start()
    }

}