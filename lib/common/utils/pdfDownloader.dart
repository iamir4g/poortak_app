import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/config/constants.dart';
import 'package:poortak/locator.dart';
import '../services/storage_service.dart';
import 'decryption.dart';

class PdfDownloader {
  static bool _shouldAttachAuthHeaders(String url) {
    final apiBase = Uri.tryParse(Constants.baseUrl);
    final target = Uri.tryParse(url);
    if (apiBase == null || target == null) return false;
    return apiBase.scheme == target.scheme && apiBase.host == target.host;
  }

  static Future<Dio> _createDownloadClient(StorageService storageService) async {
    final dio = Dio();
    dio.httpClientAdapter = storageService.dio.httpClientAdapter;
    return dio;
  }

  static Future<void> _attachAuthHeadersIfNeeded(
    Dio dio,
    String downloadUrl,
  ) async {
    if (!_shouldAttachAuthHeaders(downloadUrl)) return;

    dio.options.headers['x-lang'] = 'fa';
    final prefsOperator = locator<PrefsOperator>();
    final token = await prefsOperator.getUserToken();
    if (token != null && token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  static Future<void> _processDownloadedPdf({
    required File encryptedFile,
    required File decryptedFile,
    required StorageService storageService,
    required String key,
    required bool allowDecryption,
  }) async {
    final fileSize = await encryptedFile.length();
    print("Downloaded file size: $fileSize bytes");

    if (await isValidPdfFile(encryptedFile.path)) {
      print("Downloaded file is a valid PDF, no decryption needed");
      await encryptedFile.copy(decryptedFile.path);
      return;
    }

    if (!allowDecryption) {
      throw Exception(
          'Downloaded file is not a valid PDF. The file may be corrupted.');
    }

    print("PDF appears encrypted, getting decryption key for: $key");
    try {
      final decryptionKeyResponse =
          await storageService.callGetDecryptedFile(key);
      print("Decryption key received for file: $key");

      await decryptFile(
        encryptedFile.path,
        decryptedFile.path,
        decryptionKeyResponse.data.key,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception(
            'دسترسی به فایل کتاب مجاز نیست. لطفاً با پشتیبانی تماس بگیرید.');
      }
      rethrow;
    }
  }
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
      sanitized = 'book_${DateTime.now().millisecondsSinceEpoch}.pdf';
    }

    return sanitized;
  }

  // Public method to get sanitized filename
  static String getSanitizedFileName(String fileName) {
    return _sanitizeFileName(fileName);
  }

  static Future<bool> isValidPdfFile(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return false;
      if (await file.length() < 4) return false;
      final bytes = await file.openRead(0, 4).first;
      return bytes.length >= 4 &&
          bytes[0] == 0x25 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x44 &&
          bytes[3] == 0x46;
    } catch (e) {
      print('Error validating PDF file: $e');
      return false;
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

      // Check if decrypted file already exists and is a valid PDF
      if (await decryptedFile.exists()) {
        if (await isValidPdfFile(decryptedFile.path)) {
          print("PDF already exists, using local path: ${decryptedFile.path}");
          onDownloadCompleted?.call(decryptedFile.path);
          return decryptedFile.path;
        }
        print("Existing PDF is invalid, deleting and re-downloading");
        await decryptedFile.delete();
      }

      // Get download URL from StorageService
      print("Getting download URL from StorageService");
      print("usePublicUrl: $usePublicUrl, key: $key, fileId: $fileId");
      String downloadUrl;
      if (usePublicUrl) {
        // For trailer book files, use public download URL (DO NOT TOUCH - this is correct)
        downloadUrl = await storageService.callGetDownloadPublicUrl(key);
        print("Public download URL received: $downloadUrl");
      } else {
        // For purchased book files, use new API endpoint
        // Extract bookId from fileId (format: 'book_{bookId}')
        final bookId =
            fileId.startsWith('book_') ? fileId.substring(5) : fileId;
        print("Extracted bookId: $bookId from fileId: $fileId");
        downloadUrl = await storageService.callDownloadBookFile(bookId);
        print("Authenticated book download URL received: $downloadUrl");
      }

      print("Starting PDF download directly to internal storage");

      // Delete the target file if it exists
      if (await encryptedFile.exists()) {
        print("Deleting existing encrypted file...");
        await encryptedFile.delete();
      }

      try {
        final dio = await _createDownloadClient(storageService);
        await _attachAuthHeadersIfNeeded(dio, downloadUrl);

        print("Downloading PDF from: $downloadUrl");
        await dio.download(
          downloadUrl,
          encryptedFile.path,
          onReceiveProgress: (received, total) {
            if (total > 0) {
              final progress = (received / total).clamp(0.0, 1.0);
              print(
                  "PDF download progress: ${(progress * 100).toStringAsFixed(1)}%");
              onProgress?.call(progress);
            }
          },
        );

        print("PDF download completed, file saved to: ${encryptedFile.path}");

        if (!await encryptedFile.exists()) {
          throw Exception(
              "Downloaded PDF file does not exist at: ${encryptedFile.path}");
        }

        await _processDownloadedPdf(
          encryptedFile: encryptedFile,
          decryptedFile: decryptedFile,
          storageService: storageService,
          key: key,
          allowDecryption: isEncrypted || !usePublicUrl,
        );

        if (!await isValidPdfFile(decryptedFile.path)) {
          await decryptedFile.delete();
          throw Exception(
              'Downloaded file is not a valid PDF. It may be corrupted or still encrypted.');
        }

        print("File processing completed successfully");
        print("Final PDF path: ${decryptedFile.path}");

        onDownloadCompleted?.call(decryptedFile.path);
      } on DioException catch (e) {
        print("Error downloading PDF file: $e");
        final status = e.response?.statusCode;
        if (status == 403) {
          onDownloadError?.call('شما دسترسی دانلود این کتاب را ندارید.');
        } else if (status == 401) {
          onDownloadError?.call('لطفاً دوباره وارد حساب کاربری شوید.');
        } else {
          onDownloadError?.call('خطا در دانلود فایل: $e');
        }
      } catch (e) {
        print("Error downloading PDF file: $e");
        onDownloadError?.call('خطا در دانلود فایل: $e');
      }

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
            if (await isValidPdfFile(file.path)) {
              print("Found PDF file with fileId $fileId: $fileName");
              return file.path;
            }
            print("Invalid cached PDF found, deleting: $fileName");
            await file.delete();
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
