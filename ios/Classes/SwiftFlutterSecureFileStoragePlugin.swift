import Flutter
import UIKit
import CryptoKit

@available(iOS 13.0, *)
public class SwiftFlutterSecureFileStoragePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.icapps.flutter_secure_file_storage", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterSecureFileStoragePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      if (call.method == "isSupported") {
        if #available(iOS 13.0, *) {
            result(true)
        } else {
            result(false)
        }
        return
      }
      if let args = call.arguments as? Dictionary<String, Any> {
         switch (call.method) {
         case "encrypt":
             doEncrypt(key: args["key"] as! FlutterStandardTypedData, value: args["value"] as! FlutterStandardTypedData, result: result)
             break;
         case "decrypt":
             doDecrypt(key: args["key"] as! FlutterStandardTypedData, value: args["value"] as! FlutterStandardTypedData, iv: args["iv"] as! FlutterStandardTypedData, result: result)
         default:
             result(FlutterError.init(code: "error", message: "unknown method", details: nil))
         }
      } else {
        result(FlutterError.init(code: "error", message: "data or format error", details: nil))
      }
  }
    
    private func doEncrypt(key: FlutterStandardTypedData, value: FlutterStandardTypedData, result: @escaping FlutterResult) {
        var iv = [UInt8](repeating: 0, count: 16)
        let res = SecRandomCopyBytes(kSecRandomDefault, iv.count, &iv)

        if res != errSecSuccess {
            result(FlutterError.init(code: "error", message: "failed to generate iv", details: nil))
            return
        }
        
        do {
            let encryptionResult = try AES.GCM.seal(value.data, using: SymmetricKey(data: key.data), nonce: AES.GCM.Nonce(data: iv))
            
            var cipherBytes = encryptionResult.ciphertext
            cipherBytes.append(encryptionResult.tag)
            
            result(["iv": FlutterStandardTypedData.init(bytes: Data(iv)), "value" : FlutterStandardTypedData.init(bytes: cipherBytes)])
        } catch {
            result(FlutterError.init(code: "error", message: "Encryption failed", details:nil))
        }
    }
    
    private func doDecrypt(key: FlutterStandardTypedData, value: FlutterStandardTypedData, iv: FlutterStandardTypedData, result: @escaping FlutterResult) {
        
        let actualData = value.data.subdata(in: 0..<value.data.count-16)
        let tag = value.data.subdata(in: value.data.count-16..<value.data.count)
        
        do {
            let box = try AES.GCM.SealedBox(nonce: AES.GCM.Nonce(data: iv.data), ciphertext: actualData, tag: tag)
            
            let decrypted = try AES.GCM.open(box, using: SymmetricKey(data: key.data))
            result(FlutterStandardTypedData.init(bytes: decrypted))
        } catch {
            result(FlutterError.init(code: "error", message: "Decryption failed: \(error). Tag length: \(tag.count) - \(actualData.count)", details:nil))
        }
    }
}
