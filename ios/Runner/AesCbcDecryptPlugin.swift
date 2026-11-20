import Flutter
import Foundation
import CommonCrypto

/// Native AES-256-CBC file decrypt (Node-compatible: zero IV, PKCS7).
/// Runs on a background queue and reports progress via EventChannel.
final class AesCbcDecryptPlugin: NSObject, FlutterStreamHandler {
  static let methodChannelName = "poortak/aes_cbc_decrypt"
  static let progressChannelName = "poortak/aes_cbc_decrypt/progress"

  private static let aesBlockSize = 16
  private static let readChunkSize = 256 * 1024
  private static let progressUpdateInterval = 50

  private var eventSink: FlutterEventSink?
  private let workQueue = DispatchQueue(label: "poortak.aes_cbc_decrypt", qos: .userInitiated)

  @discardableResult
  static func register(with messenger: FlutterBinaryMessenger) -> AesCbcDecryptPlugin {
    let instance = AesCbcDecryptPlugin()
    let methodChannel = FlutterMethodChannel(
      name: methodChannelName,
      binaryMessenger: messenger
    )
    methodChannel.setMethodCallHandler(instance.handle)
    let eventChannel = FlutterEventChannel(
      name: progressChannelName,
      binaryMessenger: messenger
    )
    eventChannel.setStreamHandler(instance)
    return instance
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "decryptFile" else {
      result(FlutterMethodNotImplemented)
      return
    }

    guard
      let args = call.arguments as? [String: Any],
      let inputPath = args["inputPath"] as? String,
      let outputPath = args["outputPath"] as? String,
      let keyBase64 = args["keyBase64"] as? String,
      !inputPath.isEmpty,
      !outputPath.isEmpty,
      !keyBase64.isEmpty
    else {
      result(
        FlutterError(
          code: "INVALID_ARGS",
          message: "inputPath, outputPath, and keyBase64 are required",
          details: nil
        )
      )
      return
    }

    workQueue.async { [weak self] in
      do {
        try self?.decryptFile(
          inputPath: inputPath,
          outputPath: outputPath,
          keyBase64: keyBase64
        )
        DispatchQueue.main.async {
          self?.emitProgress(1.0)
          result(outputPath)
        }
      } catch {
        try? FileManager.default.removeItem(atPath: outputPath)
        DispatchQueue.main.async {
          result(
            FlutterError(
              code: "DECRYPT_FAILED",
              message: error.localizedDescription,
              details: nil
            )
          )
        }
      }
    }
  }

  private func decryptFile(inputPath: String, outputPath: String, keyBase64: String) throws {
    let inputURL = URL(fileURLWithPath: inputPath)
    let outputURL = URL(fileURLWithPath: outputPath)

    guard FileManager.default.fileExists(atPath: inputPath) else {
      throw AesCbcDecryptError.fileNotFound(inputPath)
    }

    let attrs = try FileManager.default.attributesOfItem(atPath: inputPath)
    let fileSize = (attrs[.size] as? NSNumber)?.int64Value ?? 0
    guard fileSize > 0 else {
      throw AesCbcDecryptError.emptyFile
    }
    guard fileSize % Int64(Self.aesBlockSize) == 0 else {
      throw AesCbcDecryptError.invalidCiphertextLength
    }

    guard let keyData = Data(base64Encoded: keyBase64), keyData.count >= 32 else {
      throw AesCbcDecryptError.invalidKey
    }
    let keyBytes = [UInt8](keyData.prefix(32))
    var iv = [UInt8](repeating: 0, count: Self.aesBlockSize)

    var cryptor: CCCryptorRef?
    let createStatus = keyBytes.withUnsafeBytes { keyPtr in
      iv.withUnsafeMutableBytes { ivPtr in
        CCCryptorCreate(
          CCOperation(kCCDecrypt),
          CCAlgorithm(kCCAlgorithmAES),
          CCOptions(kCCOptionPKCS7Padding),
          keyPtr.baseAddress,
          keyBytes.count,
          ivPtr.baseAddress,
          &cryptor
        )
      }
    }
    guard createStatus == kCCSuccess, let cryptor else {
      throw AesCbcDecryptError.cryptorCreateFailed(createStatus)
    }
    defer { CCCryptorRelease(cryptor) }

    guard let inputHandle = try? FileHandle(forReadingFrom: inputURL) else {
      throw AesCbcDecryptError.cannotOpenInput
    }
    defer { try? inputHandle.close() }

    FileManager.default.createFile(atPath: outputPath, contents: nil)
    guard let outputHandle = try? FileHandle(forWritingTo: outputURL) else {
      throw AesCbcDecryptError.cannotOpenOutput
    }
    defer { try? outputHandle.close() }

    var processed: Int64 = 0
    var chunkCount = 0
    let outBufferSize = Self.readChunkSize + Self.aesBlockSize
    var outBuffer = [UInt8](repeating: 0, count: outBufferSize)

    while true {
      let chunk = inputHandle.readData(ofLength: Self.readChunkSize)
      if chunk.isEmpty { break }

      var dataOutMoved = 0
      let status = chunk.withUnsafeBytes { inPtr -> CCCryptorStatus in
        outBuffer.withUnsafeMutableBytes { outPtr in
          CCCryptorUpdate(
            cryptor,
            inPtr.baseAddress,
            chunk.count,
            outPtr.baseAddress,
            outBufferSize,
            &dataOutMoved
          )
        }
      }
      guard status == kCCSuccess else {
        throw AesCbcDecryptError.cryptorUpdateFailed(status)
      }
      if dataOutMoved > 0 {
        outputHandle.write(Data(outBuffer.prefix(dataOutMoved)))
      }

      processed += Int64(chunk.count)
      chunkCount += 1
      if chunkCount % Self.progressUpdateInterval == 0 {
        let progress = min(0.95, Double(processed) / Double(fileSize))
        DispatchQueue.main.async { [weak self] in
          self?.emitProgress(progress)
        }
      }
    }

    var finalMoved = 0
    let finalStatus = outBuffer.withUnsafeMutableBytes { outPtr in
      CCCryptorFinal(
        cryptor,
        outPtr.baseAddress,
        outBufferSize,
        &finalMoved
      )
    }
    guard finalStatus == kCCSuccess else {
      throw AesCbcDecryptError.cryptorFinalFailed(finalStatus)
    }
    if finalMoved > 0 {
      outputHandle.write(Data(outBuffer.prefix(finalMoved)))
    }
  }

  private func emitProgress(_ progress: Double) {
    eventSink?(progress)
  }
}

private enum AesCbcDecryptError: LocalizedError {
  case fileNotFound(String)
  case emptyFile
  case invalidCiphertextLength
  case invalidKey
  case cryptorCreateFailed(CCCryptorStatus)
  case cryptorUpdateFailed(CCCryptorStatus)
  case cryptorFinalFailed(CCCryptorStatus)
  case cannotOpenInput
  case cannotOpenOutput

  var errorDescription: String? {
    switch self {
    case .fileNotFound(let path):
      return "Encrypted file not found: \(path)"
    case .emptyFile:
      return "Encrypted file is empty"
    case .invalidCiphertextLength:
      return "Ciphertext length is not multiple of AES block size (16)."
    case .invalidKey:
      return "Decoded encryption key is too short (need 32 bytes)."
    case .cryptorCreateFailed(let status):
      return "CCCryptorCreate failed with status \(status)"
    case .cryptorUpdateFailed(let status):
      return "CCCryptorUpdate failed with status \(status)"
    case .cryptorFinalFailed(let status):
      return "CCCryptorFinal failed with status \(status)"
    case .cannotOpenInput:
      return "Cannot open encrypted input file"
    case .cannotOpenOutput:
      return "Cannot open decrypted output file"
    }
  }
}
