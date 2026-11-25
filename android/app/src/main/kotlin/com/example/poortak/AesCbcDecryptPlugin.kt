package com.example.poortak

import android.os.Handler
import android.os.Looper
import android.util.Base64
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.util.concurrent.Executors
import javax.crypto.Cipher
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec

/**
 * Native AES-256-CBC file decrypt (Node-compatible: zero IV, PKCS7).
 * Runs on a background thread and reports progress via EventChannel.
 */
class AesCbcDecryptPlugin private constructor(
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val methodChannel = MethodChannel(messenger, METHOD_CHANNEL)
    private val eventChannel = EventChannel(messenger, PROGRESS_CHANNEL)
    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())
    private var eventSink: EventChannel.EventSink? = null

    init {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "decryptFile") {
            result.notImplemented()
            return
        }

        val inputPath = call.argument<String>("inputPath")
        val outputPath = call.argument<String>("outputPath")
        val keyBase64 = call.argument<String>("keyBase64")

        if (inputPath.isNullOrBlank() || outputPath.isNullOrBlank() || keyBase64.isNullOrBlank()) {
            result.error("INVALID_ARGS", "inputPath, outputPath, and keyBase64 are required", null)
            return
        }

        executor.execute {
            try {
                decryptFile(inputPath, outputPath, keyBase64)
                mainHandler.post {
                    emitProgress(1.0)
                    result.success(outputPath)
                }
            } catch (e: Exception) {
                try {
                    File(outputPath).takeIf { it.exists() }?.delete()
                } catch (_: Exception) {
                }
                mainHandler.post {
                    result.error(
                        "DECRYPT_FAILED",
                        e.message ?: "Native AES-CBC decrypt failed",
                        null,
                    )
                }
            }
        }
    }

    private fun decryptFile(inputPath: String, outputPath: String, keyBase64: String) {
        val inputFile = File(inputPath)
        if (!inputFile.exists()) {
            throw IllegalArgumentException("Encrypted file not found: $inputPath")
        }

        val fileSize = inputFile.length()
        if (fileSize == 0L) {
            throw IllegalArgumentException("Encrypted file is empty")
        }
        if (fileSize % AES_BLOCK_SIZE != 0L) {
            throw IllegalArgumentException(
                "Ciphertext length is not multiple of AES block size ($AES_BLOCK_SIZE).",
            )
        }

        val decodedKey = Base64.decode(keyBase64, Base64.DEFAULT)
        if (decodedKey.size < 32) {
            throw IllegalArgumentException(
                "Decoded encryption key is too short: ${decodedKey.size} bytes (need 32).",
            )
        }
        val keyBytes = decodedKey.copyOf(32)

        val cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
        cipher.init(
            Cipher.DECRYPT_MODE,
            SecretKeySpec(keyBytes, "AES"),
            IvParameterSpec(ByteArray(AES_BLOCK_SIZE)),
        )

        val buffer = ByteArray(READ_CHUNK_SIZE)
        var processed = 0L
        var chunkCount = 0

        FileInputStream(inputFile).use { input ->
            FileOutputStream(File(outputPath)).use { output ->
                while (true) {
                    val read = input.read(buffer)
                    if (read < 0) break

                    val decrypted = cipher.update(buffer, 0, read)
                    if (decrypted != null && decrypted.isNotEmpty()) {
                        output.write(decrypted)
                    }

                    processed += read
                    chunkCount++
                    if (chunkCount % PROGRESS_UPDATE_INTERVAL == 0) {
                        val progress = (processed.toDouble() / fileSize.toDouble()).coerceIn(0.0, 0.95)
                        mainHandler.post { emitProgress(progress) }
                    }
                }

                val finalBlock = cipher.doFinal()
                if (finalBlock != null && finalBlock.isNotEmpty()) {
                    output.write(finalBlock)
                }
                output.flush()
            }
        }
    }

    private fun emitProgress(progress: Double) {
        eventSink?.success(progress)
    }

    companion object {
        const val METHOD_CHANNEL = "poortak/aes_cbc_decrypt"
        const val PROGRESS_CHANNEL = "poortak/aes_cbc_decrypt/progress"

        private const val AES_BLOCK_SIZE = 16
        private const val READ_CHUNK_SIZE = 256 * 1024
        private const val PROGRESS_UPDATE_INTERVAL = 50

        fun registerWith(messenger: BinaryMessenger): AesCbcDecryptPlugin {
            return AesCbcDecryptPlugin(messenger)
        }
    }
}
