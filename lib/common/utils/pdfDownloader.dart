import 'dart:io';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:path_provider/path_provider.dart';
import '../services/storage_service.dart';

class PdfDownloader {
  // Helper method to sanitize filename for safe file operations
  static String _sanitizeFileName(String fileName) {
    // Extract the base name without extension
    String baseName = fileName;
    String extension = '.pdf';

    if (fileName.toLowerCase().endsWith('.pdf')) {
      baseName = fileName.substring(0, fileName.length - 4);
      extension = '.pdf';
    }

    // Convert Persian characters to English equivalents
    Map<String, String> persianToEnglish = {
      'ا': 'a',
      'ب': 'b',
      'پ': 'p',
      'ت': 't',
      'ث': 'th',
      'ج': 'j',
      'چ': 'ch',
      'ح': 'h',
      'خ': 'kh',
      'د': 'd',
      'ذ': 'z',
      'ر': 'r',
      'ز': 'z',
      'س': 's',
      'ش': 'sh',
      'ص': 's',
      'ض': 'z',
      'ط': 't',
      'ظ': 'z',
      'ع': 'a',
      'غ': 'gh',
      'ف': 'f',
      'ق': 'gh',
      'ک': 'k',
      'گ': 'g',
      'ل': 'l',
      'م': 'm',
      'ن': 'n',
      'و': 'v',
      'ه': 'h',
      'ی': 'y',
      'آ': 'aa',
      'ئ': 'e',
      'ة': 'h',
      '۰': '0',
      '۱': '1',
      '۲': '2',
      '۳': '3',
      '۴': '4',
      '۵': '5',
      '۶': '6',
      '۷': '7',
      '۸': '8',
      '۹': '9',
    };

    // Replace Persian characters
    String sanitized = baseName;
    persianToEnglish.forEach((persian, english) {
      sanitized = sanitized.replaceAll(persian, english);
    });

    // Replace remaining special characters and spaces
    sanitized = sanitized
        .replaceAll(RegExp(r'[^\w\s\-\.]'),
            '_') // Replace special chars with underscore
        .replaceAll(RegExp(r'\s+'), '_') // Replace spaces with underscore
        .replaceAll(
            RegExp(r'_+'), '_') // Replace multiple underscores with single
        .trim();

    // Ensure it ends with .pdf
    if (!sanitized.toLowerCase().endsWith('.pdf')) {
      sanitized += extension;
    }

    // If filename is too long, truncate it
    if (sanitized.length > 100) {
      String name = sanitized.substring(0, 100 - extension.length);
      sanitized = name + extension;
    }

    // Ensure filename is not empty
    if (sanitized.isEmpty || sanitized == '.pdf') {
      sanitized =
          'book_' + DateTime.now().millisecondsSinceEpoch.toString() + '.pdf';
    }

    return sanitized;
  }

  // Public method to get sanitized filename
  static String getSanitizedFileName(String fileName) {
    return _sanitizeFileName(fileName);
  }

  // Helper method to find the actual downloaded file
  static Future<String?> _findDownloadedFile(
      String expectedPath, String sanitizedFileName) async {
    try {
      // First check if the expected path exists
      final expectedFile = File(expectedPath);
      if (await expectedFile.exists()) {
        return expectedPath;
      }

      // If not, search in the Downloads directory
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (await downloadsDir.exists()) {
        final files = downloadsDir.listSync();

        // Look for files that might match our expected name
        for (var file in files) {
          if (file is File) {
            final fileName = file.path.split('/').last;
            // Check if it's a PDF file
            if (fileName.toLowerCase().endsWith('.pdf')) {
              print("Found PDF file: $fileName");
              return file.path;
            }
          }
        }
      }

      return null;
    } catch (e) {
      print('Error finding downloaded file: $e');
      return null;
    }
  }

  // Debug method to test filename sanitization
  static void testSanitization(String fileName) {
    print("=== Filename Sanitization Test ===");
    print("Original: $fileName");
    print("Sanitized: ${_sanitizeFileName(fileName)}");
    print("================================");
  }

  static Future<String?> downloadAndStorePdf({
    required StorageService storageService,
    required String key,
    required String fileName,
    required String fileId,
    bool isEncrypted = false,
    bool usePublicUrl = false,
    Function(double)? onProgress,
    Function(String)? onDownloadCompleted,
    Function(String)? onDownloadError,
  }) async {
    try {
      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final pdfDir = Directory('${directory.path}/pdfs');
      final encryptedDir = Directory('${directory.path}/encrypted_pdfs');

      // Create directories if they don't exist
      if (!await pdfDir.exists()) {
        await pdfDir.create(recursive: true);
      }
      if (!await encryptedDir.exists()) {
        await encryptedDir.create(recursive: true);
      }

      // Sanitize filename for safe file operations and include fileId
      final baseFileName = _sanitizeFileName(fileName);
      final sanitizedFileName = '${fileId}_$baseFileName';
      print("Original filename: $fileName");
      print("Sanitized filename: $sanitizedFileName");
      print("FileId: $fileId");

      // Test the sanitization
      testSanitization(fileName);

      // Create file paths with sanitized filename
      final encryptedFile = File('${encryptedDir.path}/$sanitizedFileName');
      final decryptedFile = File('${pdfDir.path}/$sanitizedFileName');

      print("Encrypted file path: ${encryptedFile.path}");
      print("Decrypted file path: ${decryptedFile.path}");

      // Check if decrypted file already exists
      if (await decryptedFile.exists()) {
        print("PDF already exists, using local path: ${decryptedFile.path}");
        return decryptedFile.path;
      }

      // Get download URL from StorageService
      print("Getting download URL from StorageService");
      print("usePublicUrl: $usePublicUrl, key: $key");
      String downloadUrl;
      if (usePublicUrl) {
        downloadUrl = await storageService.callGetDownloadPublicUrl(key);
        print("Public download URL received: $downloadUrl");
      } else {
        final response = await storageService.callGetDownloadUrl(key);
        downloadUrl = response.data;
        print("Authenticated download URL received: $downloadUrl");
        print(
            "Response ok: ${response.ok}, data length: ${downloadUrl.length}");
      }

      // Download using flutter_file_downloader
      await FileDownloader.downloadFile(
        url: downloadUrl,
        name: sanitizedFileName,
        onProgress: (fileName, progress) {
          print("PDF download progress: $progress%");
          onProgress?.call(progress / 100);
        },
        onDownloadCompleted: (path) async {
          print("PDF download completed, file saved to: $path");
          print("Expected sanitized filename: $sanitizedFileName");
          print("Download path: $path");

          try {
            // Ensure directories exist
            if (!await encryptedDir.exists()) {
              await encryptedDir.create(recursive: true);
            }
            if (!await pdfDir.exists()) {
              await pdfDir.create(recursive: true);
            }

            // Delete the target file if it exists
            if (await encryptedFile.exists()) {
              await encryptedFile.delete();
            }

            // Try to find the actual downloaded file
            String? actualFilePath =
                await _findDownloadedFile(path, sanitizedFileName);
            if (actualFilePath == null) {
              throw Exception("Could not find downloaded PDF file");
            }

            // Copy the file from Downloads to encrypted directory
            final downloadedFile = File(actualFilePath);
            print("Copying file from: $actualFilePath");
            print("Copying file to: ${encryptedFile.path}");

            await downloadedFile.copy(encryptedFile.path);
            print("File copied to encrypted directory successfully");

            // If file is encrypted, get decryption key and decrypt
            if (isEncrypted) {
              print("PDF is encrypted, getting decryption key");
              // TODO: Implement decryption logic for PDFs
              // For now, just copy to pdf directory
              await encryptedFile.copy(decryptedFile.path);
            } else {
              // If not encrypted, just copy to pdf directory
              print("File is not encrypted, copying to PDF directory");
              await encryptedFile.copy(decryptedFile.path);
            }

            print("File processing completed successfully");
            print("Final PDF path: ${decryptedFile.path}");

            // Call the completion callback with the local file path
            onDownloadCompleted?.call(decryptedFile.path);
          } catch (e) {
            print("Error processing PDF file: $e");
            onDownloadError?.call("Error processing PDF file: $e");
          }
        },
        onDownloadError: (error) {
          print("PDF download error: $error");
          onDownloadError?.call(error);
        },
      );

      return null; // Will be set in onDownloadCompleted callback
    } catch (e) {
      print('Error in PDF download process: $e');
      onDownloadError?.call("Error in PDF download process: $e");
      return null;
    }
  }

  static Future<bool> isPdfDownloaded(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final pdfDir = Directory('${directory.path}/pdfs');
      final sanitizedFileName = _sanitizeFileName(fileName);
      final pdfFile = File('${pdfDir.path}/$sanitizedFileName');
      return await pdfFile.exists();
    } catch (e) {
      print('Error checking if PDF is downloaded: $e');
      return false;
    }
  }

  static Future<String?> getLocalPdfPath(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final pdfDir = Directory('${directory.path}/pdfs');
      final sanitizedFileName = _sanitizeFileName(fileName);
      final pdfFile = File('${pdfDir.path}/$sanitizedFileName');

      if (await pdfFile.exists()) {
        return pdfFile.path;
      }
      return null;
    } catch (e) {
      print('Error getting local PDF path: $e');
      return null;
    }
  }

  static Future<String?> getLocalPdfPathByFileId(String fileId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final pdfDir = Directory('${directory.path}/pdfs');

      if (!await pdfDir.exists()) {
        return null;
      }

      // List all files in the PDF directory
      final files = await pdfDir.list().toList();

      // Look for files that contain the fileId in their name
      for (var file in files) {
        if (file is File && file.path.toLowerCase().endsWith('.pdf')) {
          final fileName = file.path.split('/').last;
          // Check if the file name contains our fileId
          if (fileName.contains(fileId)) {
            print("Found PDF file with fileId $fileId: $fileName");
            return file.path;
          }
        }
      }

      return null;
    } catch (e) {
      print('Error getting local PDF path by fileId: $e');
      return null;
    }
  }

  static Future<void> deletePdf(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final pdfDir = Directory('${directory.path}/pdfs');
      final sanitizedFileName = _sanitizeFileName(fileName);
      final pdfFile = File('${pdfDir.path}/$sanitizedFileName');

      if (await pdfFile.exists()) {
        await pdfFile.delete();
        print('PDF deleted: $sanitizedFileName');
      }
    } catch (e) {
      print('Error deleting PDF: $e');
    }
  }

  static Future<void> deletePdfByFileId(String fileId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final pdfDir = Directory('${directory.path}/pdfs');

      if (!await pdfDir.exists()) {
        return;
      }

      // List all files in the PDF directory
      final files = await pdfDir.list().toList();

      // Look for files that contain the fileId in their name and delete them
      for (var file in files) {
        if (file is File && file.path.toLowerCase().endsWith('.pdf')) {
          final fileName = file.path.split('/').last;
          // Check if the file name contains our fileId
          if (fileName.contains(fileId)) {
            await file.delete();
            print('PDF deleted by fileId $fileId: $fileName');
          }
        }
      }
    } catch (e) {
      print('Error deleting PDF by fileId: $e');
    }
  }
}
