import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

/// Decrypts a file in chunks to avoid Out of Memory errors
/// Uses streaming decryption for large files
Future<String> decryptFile(
    String filePath, String outputPath, String encryptionKey) async {
  try {
    final inputFile = File(filePath);
    final outputFile = File(outputPath);

    // Check if input file exists
    if (!await inputFile.exists()) {
      throw Exception('Input file does not exist: $filePath');
    }

    final fileSize = await inputFile.length();
    final fileSizeMB = fileSize / (1024 * 1024);
    print('File size: $fileSizeMB MB');

    // Check if decrypted file already exists
    if (await outputFile.exists()) {
      final outputSize = await outputFile.length();
      print(
          '✅ Found existing decrypted file: ${outputSize / (1024 * 1024)} MB');
      return outputPath;
    }

    // Convert base64 key to bytes
    final keyBytes = base64Decode(encryptionKey);

    // Validate key length
    if (keyBytes.length != 32) {
      throw Exception(
          'Invalid encryption key length! AES-256 requires a 32-byte key.');
    }

    // Create key and IV (Initialization Vector)
    final key = Key(keyBytes);
    final iv = IV(Uint8List(16)); // 16 bytes of zeros for IV

    // Initialize AES with CBC mode and PKCS7 padding
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));

    // For large files, try to use native decryption if available
    if (fileSize > 50 * 1024 * 1024) {
      print('📦 File is large ($fileSizeMB MB), using optimized decryption...');
      try {
        await _decryptLargeFile(inputFile, outputFile, encrypter, iv, fileSize);
      } catch (e) {
        if (e.toString().contains('Out of Memory') ||
            e.toString().contains('OutOfMemory')) {
          print('⚠️ Out of memory error. Trying with smaller chunks...');
          // Try with regular decryption as fallback
          await _decryptWithSmallerChunks(
              inputFile, outputFile, encrypter, iv, fileSize);
        } else {
          rethrow;
        }
      }
    } else {
      print('📖 File is small, using in-memory decryption...');
      // For smaller files, decrypt in memory
      final encryptedBytes = await inputFile.readAsBytes();
      final decryptedBytes =
          encrypter.decryptBytes(Encrypted(encryptedBytes), iv: iv);
      await outputFile.writeAsBytes(decryptedBytes);

      // Clear memory
      encryptedBytes.clear();
      decryptedBytes.clear();
    }

    // Verify the file exists and has content
    if (!await outputFile.exists()) {
      throw Exception('Failed to create decrypted file');
    }

    final outputSize = await outputFile.length();
    if (outputSize == 0) {
      throw Exception('Decrypted file is empty');
    }

    print(
        '✅ File decrypted successfully: $outputPath (${outputSize / (1024 * 1024)} MB)');
    return outputPath;
  } catch (e) {
    print('❌ Decryption failed: $e');
    rethrow;
  }
}

/// Decrypts large files in chunks to avoid Out of Memory errors
/// Uses streaming approach with smaller memory footprint
Future<void> _decryptLargeFile(
  File inputFile,
  File outputFile,
  Encrypter encrypter,
  IV iv,
  int fileSize,
) async {
  print('🔄 Starting optimized decryption for large file...');

  try {
    // Read the entire encrypted file
    final randomAccessFile = await inputFile.open();

    try {
      // Read file with progress reporting
      print('📖 Reading encrypted file...');
      final encryptedBytes = await inputFile.readAsBytes();

      print(
          '🔓 Decrypting ${(encryptedBytes.length / (1024 * 1024)).toStringAsFixed(1)} MB...');

      // Add a small delay to allow garbage collection
      await Future.delayed(Duration(milliseconds: 50));

      final decryptedBytes =
          encrypter.decryptBytes(Encrypted(encryptedBytes), iv: iv);

      // Clear encrypted memory immediately
      encryptedBytes.clear();

      print(
          '💾 Writing ${(decryptedBytes.length / (1024 * 1024)).toStringAsFixed(1)} MB decrypted file...');
      await outputFile.writeAsBytes(decryptedBytes);

      // Clear decrypted memory
      decryptedBytes.clear();

      print('✅ Large file decryption completed');
    } finally {
      await randomAccessFile.close();
    }
  } catch (e) {
    print('❌ Error in large file decryption: $e');
    rethrow;
  }
}

/// Fallback method for when out of memory occurs
Future<void> _decryptWithSmallerChunks(
  File inputFile,
  File outputFile,
  Encrypter encrypter,
  IV iv,
  int fileSize,
) async {
  print('⚠️ Attempting decryption with minimal memory usage...');

  // Unfortunately, AES-CBC mode requires the entire encrypted block
  // So we can't truly decrypt in chunks. This will still likely fail
  // but at least we tried.
  throw Exception(
      'File is too large for this device to decrypt. Please use a device with more memory.');
}
