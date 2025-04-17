import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

Future<String> decryptFile(
    String filePath, String outputPath, String encryptionKey) async {
  try {
    // Read the encrypted file
    final encryptedBytes = File(filePath).readAsBytesSync();

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

    // Decrypt data
    final decryptedBytes =
        encrypter.decryptBytes(Encrypted(encryptedBytes), iv: iv);

    // Write the decrypted data to a new file
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(decryptedBytes);

    // Verify the file exists and has content
    if (!await outputFile.exists()) {
      throw Exception('Failed to create decrypted file');
    }

    final fileSize = await outputFile.length();
    if (fileSize == 0) {
      throw Exception('Decrypted file is empty');
    }

    print('File decrypted successfully: $outputPath');
    return outputPath;
  } catch (e) {
    print('Decryption failed: $e');
    rethrow;
  }
}

void main() {
  const filePath =
      './download/encrypted_file.dat'; // Adjust the path accordingly
  const outputPath =
      './download/decrypted_file.ext'; // Adjust the output path and extension
  const encryptionKey = String.fromEnvironment(
      'ENCRYPTION_KEY'); // Read the key from environment variable

  decryptFile(filePath, outputPath, encryptionKey);
}
