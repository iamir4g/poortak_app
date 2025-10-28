import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:pointycastle/export.dart' as pc;

/// تنظیمات
const int _aesBlockSize = 16;
const int _readChunkSize =
    256 * 1024; // 256 KB per read (must be multiple of 16)

/// Decrypt a file encrypted with Node's crypto.createCipheriv('aes-256-cbc', key, ivZero)
/// - encryptionKey: base64 string of 32 bytes (server stores encryptionKey.toString('base64'))
/// - iv assumed to be 16 zero bytes (as backend told us)
/// - Always decrypt from scratch (no caching)
Future<String> decryptFile(
  String filePath,
  String outputPath,
  String encryptionKey, {
  void Function(double progress)? onProgress,
}) async {
  final inputFile = File(filePath);
  final outputFile = File(outputPath);

  if (!await inputFile.exists()) {
    throw FileSystemException('Encrypted file not found', filePath);
  }

  final fileSize = await inputFile.length();
  print('📁 File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

  // file size must be multiple of block size (CBC produces whole blocks after final)
  if (fileSize % _aesBlockSize != 0) {
    throw Exception(
        'Ciphertext length is not multiple of AES block size ($_aesBlockSize).');
  }

  // decode key
  final decodedKey = base64Decode(encryptionKey);
  if (decodedKey.length < 32) {
    throw Exception(
        'Decoded encryption key is too short: ${decodedKey.length} bytes (need 32).');
  }
  final keyBytes = Uint8List.fromList(decodedKey.sublist(0, 32));

  // iv is 16 zero bytes (as backend uses Buffer.alloc(16))
  final ivBytes = Uint8List(_aesBlockSize);

  // Setup CBC AES engine
  final pc.BlockCipher cipher = pc.CBCBlockCipher(pc.AESEngine());
  cipher.init(
    false, // false = decrypt
    pc.ParametersWithIV(pc.KeyParameter(keyBytes), ivBytes),
  );

  // Open files
  final raf = inputFile.openSync(mode: FileMode.read);
  final outSink = outputFile.openWrite();

  int processed = 0;
  final int lastBlockStart = fileSize - _aesBlockSize;

  try {
    // Read and decrypt everything up to (but not including) the final block
    int position = 0;
    while (position < lastBlockStart) {
      // number of bytes to read in this iteration
      int remainBeforeFinal = lastBlockStart - position;
      int toRead = (_readChunkSize <= remainBeforeFinal)
          ? _readChunkSize
          : remainBeforeFinal;

      // ensure toRead is multiple of AES block
      if (toRead % _aesBlockSize != 0) {
        toRead -= toRead % _aesBlockSize;
      }
      if (toRead <= 0) break;

      final chunk = raf.readSync(toRead);
      final chunkLen = chunk.length;
      final outBuf = Uint8List(chunkLen);

      // process block-by-block
      for (int offset = 0; offset < chunkLen; offset += _aesBlockSize) {
        cipher.processBlock(chunk, offset, outBuf, offset);
      }

      // write plaintext chunk
      outSink.add(outBuf);

      position += chunkLen;
      processed += chunkLen;
      onProgress?.call((processed / fileSize).clamp(0.0, 0.95));
    }

    // Now process final block(s): read the last 16 bytes (single AES block)
    raf.setPositionSync(lastBlockStart);
    final finalCipherBlock = raf.readSync(_aesBlockSize);
    if (finalCipherBlock.length != _aesBlockSize) {
      throw Exception('Failed to read final cipher block.');
    }

    final finalPlain = Uint8List(_aesBlockSize);
    cipher.processBlock(finalCipherBlock, 0, finalPlain, 0);

    // PKCS7 unpadding on finalPlain
    final int pad = finalPlain[finalPlain.length - 1];
    if (pad <= 0 || pad > _aesBlockSize) {
      throw Exception('Invalid PKCS7 padding value: $pad');
    }
    // verify padding bytes
    for (int i = finalPlain.length - pad; i < finalPlain.length; i++) {
      if (finalPlain[i] != pad) {
        throw Exception('Invalid PKCS7 padding bytes detected.');
      }
    }

    final int plaintextFinalLen = finalPlain.length - pad;
    if (plaintextFinalLen > 0) {
      outSink.add(finalPlain.sublist(0, plaintextFinalLen));
    }

    processed += _aesBlockSize;
    onProgress?.call(1.0);

    await outSink.flush();
    await outSink.close();
    raf.closeSync();

    print('✅ File decrypted successfully: ${outputFile.path}');
    return outputFile.path;
  } catch (e) {
    try {
      await outSink.flush();
      await outSink.close();
    } catch (_) {}
    try {
      raf.closeSync();
    } catch (_) {}
    // remove partial output
    if (await outputFile.exists()) {
      try {
        await outputFile.delete();
      } catch (_) {}
    }
    rethrow;
  }
}
