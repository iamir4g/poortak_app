import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

void decryptFile(String filePath, String outputPath, String encryptionKey) async {
  try {
    // Read the encrypted file
    final encryptedBytes = File(filePath).readAsBytesSync();

    // Create key and IV (Initialization Vector)
    final key = Key.fromUtf8(encryptionKey.padRight(32));  // Ensure the key is 32 bytes
    final iv = IV(Uint8List(16));  // Equivalent to Buffer.alloc(16) in Node.js

    // Initialize AES with CBC mode and PKCS7 padding
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));

    // Decrypt data
    final decryptedBytes = encrypter.decryptBytes(Encrypted(encryptedBytes), iv: iv);

    // Write the decrypted data to a new file
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(decryptedBytes);

    print('File decrypted successfully: $outputPath');
  } catch (e) {
    print('Decryption failed: $e');
  }
}

void main() {
  const filePath = './download/encrypted_file.dat';  // Adjust the path accordingly
  const outputPath = './download/decrypted_file.ext'; // Adjust the output path and extension
  const encryptionKey = String.fromEnvironment('ENCRYPTION_KEY');  // Read the key from environment variable

  decryptFile(filePath, outputPath, encryptionKey);
}
