import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../services/storage_service.dart';
import 'decryption.dart';

/// Utility class for handling video downloads, file checking, and decryption
class VideoDownloaderUtil {
  /// Helper method to extract base filename without flutter_file_downloader suffixes
  static String getBaseFileName(String filePath) {
    final fileName = filePath.split('/').last;
    // flutter_file_downloader adds suffixes like -1, -2, -3
    // A UUID has 4 dashes (e.g., 26ab6de7-147c-4297-a7d8-85939dc7d7f1)
    // If there's a 5th dash followed by a number, that's the flutter_file_downloader suffix
    final dashIndex = fileName.lastIndexOf('-');
    if (dashIndex != -1) {
      final suffix = fileName.substring(dashIndex + 1);
      // If the part after the last dash is a number, it's a suffix
      if (int.tryParse(suffix) != null) {
        return fileName.substring(0, dashIndex);
      }
    }
    return fileName;
  }

  /// Helper method to normalize filename for comparison (removes .mp4 extension if present)
  static String normalizeFileName(String fileName) {
    if (fileName.endsWith('.mp4')) {
      return fileName.substring(0, fileName.length - 4);
    }
    return fileName;
  }

  /// Check for existing video files in local directories
  static Future<String?> checkExistingFiles({
    required String name,
    required StorageService storageService,
    required bool hasAccess,
    Function(bool)? onDecrypting,
    Function(double)? onDecryptionProgress,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final videoDir = Directory('${directory.path}/videos');
      final encryptedDir = Directory('${directory.path}/encrypted');

      // Check in videos directory first (decrypted files)
      if (await videoDir.exists()) {
        final files = await videoDir.list().toList();
        print(
            "🔍 Checking ${files.length} files in videos directory for: $name");
        for (var file in files) {
          if (file is File) {
            final fileName = getBaseFileName(file.path);
            final normalizedFileName = normalizeFileName(fileName);
            print(
                "  - File: $fileName, Normalized: $normalizedFileName, Looking for: $name");
            // Compare normalized filename (without .mp4) with the name parameter
            if (normalizedFileName == name) {
              print("✅ Found existing decrypted video file: ${file.path}");
              return file.path;
            }
          }
        }
      } else {
        print("⚠️ Videos directory does not exist: ${videoDir.path}");
      }

      // Check encrypted directory for both purchased and trailer videos
      // (trailer videos are also stored in encrypted directory temporarily)
      if (await encryptedDir.exists()) {
        final files = await encryptedDir.list().toList();
        print(
            "🔍 Checking ${files.length} files in encrypted directory for: $name");
        for (var encryptedFile in files) {
          if (encryptedFile is File) {
            final fileName = getBaseFileName(encryptedFile.path);
            final normalizedFileName = normalizeFileName(fileName);
            print(
                "  - Encrypted file: $fileName, Normalized: $normalizedFileName, Looking for: $name");

            // For purchased content, try to decrypt
            if (hasAccess && normalizedFileName == name) {
              print("✅ Found existing encrypted file: ${encryptedFile.path}");
              // Try to decrypt it
              try {
                final decryptionKeyResponse =
                    await storageService.callGetDecryptedFile(fileName);
                final decryptedFileName = '$fileName.mp4';
                final decryptedFile =
                    File('${videoDir.path}/$decryptedFileName');

                onDecrypting?.call(true);
                if (onDecryptionProgress != null) {
                  final decryptedPath = await decryptFile(
                    encryptedFile.path,
                    decryptedFile.path,
                    decryptionKeyResponse.data.key,
                    onProgress: onDecryptionProgress,
                  );

                  if (await File(decryptedPath).exists()) {
                    onDecrypting?.call(false);
                    return decryptedPath;
                  }
                }
                onDecrypting?.call(false);
              } catch (e) {
                print("❌ Error decrypting existing file: $e");
                onDecrypting?.call(false);
              }
            }
            // For trailer videos (not encrypted), check if decrypted version exists
            // or copy directly if it's a trailer video
            else if (!hasAccess && normalizedFileName == name) {
              print(
                  "✅ Found existing file in encrypted directory (trailer): ${encryptedFile.path}");
              // Check if decrypted version already exists in videos directory
              final possibleDecryptedFile = File('${videoDir.path}/$name.mp4');
              if (await possibleDecryptedFile.exists()) {
                print("✅ Decrypted version already exists, using it");
                return possibleDecryptedFile.path;
              }
              // If not, copy to videos directory (trailer videos are not encrypted)
              try {
                final decryptedFile = File('${videoDir.path}/$name.mp4');
                await encryptedFile.copy(decryptedFile.path);
                if (await decryptedFile.exists()) {
                  print("✅ Copied trailer video to videos directory");
                  return decryptedFile.path;
                }
              } catch (e) {
                print("❌ Error copying trailer video: $e");
              }
            }
          }
        }
      }

      print("ℹ️ No existing file found for: $name");
      return null;
    } catch (e) {
      print("❌ Error checking existing files: $e");
      return null;
    }
  }

  /// Download and store video file
  static Future<void> downloadAndStoreVideo({
    required StorageService storageService,
    required String key,
    required String name,
    required String fileId,
    required String lessonId,
    required bool isEncrypted,
    required bool usePublicUrl,
    Function(bool)? onDownloading,
    Function(double)? onDownloadProgress,
    Function(bool)? onDecrypting,
    Function(double)? onDecryptionProgress,
    Function(String)? onSuccess,
    Function(String)? onError,
  }) async {
    print(
        "Starting download process for key: $key, name: $name, isEncrypted: $isEncrypted");

    try {
      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final videoDir = Directory('${directory.path}/videos');
      final encryptedDir = Directory('${directory.path}/encrypted');
      print("Video directory path: ${videoDir.path}");

      // Create directories if they don't exist
      if (!await videoDir.exists()) {
        print("Creating video directory");
        await videoDir.create(recursive: true);
      }
      if (!await encryptedDir.exists()) {
        print("Creating encrypted directory");
        await encryptedDir.create(recursive: true);
      }

      // Create file paths
      final encryptedFile = File('${encryptedDir.path}/$name');
      final decryptedFile = File('${videoDir.path}/$name');
      print("Encrypted file path: ${encryptedFile.path}");
      print("Decrypted file path: ${decryptedFile.path}");

      // Check if decrypted file already exists
      if (await decryptedFile.exists()) {
        print("Decrypted file already exists, using local path");
        onSuccess?.call(decryptedFile.path);
        return;
      }

      print("Getting download URL from StorageService");
      String downloadUrlString;
      try {
        if (usePublicUrl) {
          // For trailer videos, use public download URL
          downloadUrlString =
              await storageService.callGetDownloadPublicUrl(key);
          print("Public download URL received: $downloadUrlString");
        } else {
          // For purchased course videos, use new API endpoint with lessonId
          downloadUrlString =
              await storageService.callDownloadCourseVideo(lessonId);
          print("Course video download URL received: $downloadUrlString");
        }
      } catch (e) {
        print('Error getting download URL: $e');
        onError?.call('خطا در دریافت لینک دانلود. لطفا دوباره تلاش کنید.');
        return;
      }

      print("Download URL received: $downloadUrlString");

      print("Starting file download directly to internal storage");

      // Delete the target file if it exists
      if (await encryptedFile.exists()) {
        print("Deleting existing encrypted file...");
        await encryptedFile.delete();
      }

      // Download directly to internal storage using Dio
      try {
        // Create a new Dio instance without interceptors for file downloads
        // Signed S3 URLs should not have additional headers (x-lang, Authorization)
        // as they would invalidate the signature
        final dio = Dio();

        // Download with progress tracking
        await dio.download(
          downloadUrlString,
          encryptedFile.path,
          onReceiveProgress: (received, total) {
            if (total > 0) {
              final progress = (received / total).clamp(0.0, 1.0);
              print(
                  "Download progress: ${(progress * 100).toStringAsFixed(1)}%");
              onDownloadProgress?.call(progress);
            }
          },
        );

        print("Download completed, file saved to: ${encryptedFile.path}");

        // Verify file was downloaded
        if (!await encryptedFile.exists()) {
          throw Exception(
              "Downloaded file does not exist at: ${encryptedFile.path}");
        }

        // If file is encrypted, get decryption key and decrypt
        if (isEncrypted) {
          print("File is encrypted, getting decryption key");
          final decryptionKeyResponse =
              await storageService.callGetDecryptedFile(fileId);
          print("Decryption key received: ${decryptionKeyResponse.data.key}");

          // Decrypt the file using the utility function
          print("Starting decryption process");
          final cleanDecryptedFile = File('${videoDir.path}/$name.mp4');

          // Set decryption state
          onDownloading?.call(false);
          onDecrypting?.call(true);

          final decryptedPath = await decryptFile(
            encryptedFile.path,
            cleanDecryptedFile.path,
            decryptionKeyResponse.data.key,
            onProgress: onDecryptionProgress,
          );

          // Reset decryption state
          onDecrypting?.call(false);

          if (await File(decryptedPath).exists()) {
            print("✅ File successfully decrypted and processed");
            onSuccess?.call(decryptedPath);
          } else {
            print("❌ Failed to process file");
            onError?.call("Failed to process file");
          }
        } else {
          // If not encrypted (trailer video), just copy to video directory
          final cleanDecryptedFile = File('${videoDir.path}/$name.mp4');
          await encryptedFile.copy(cleanDecryptedFile.path);
          onSuccess?.call(cleanDecryptedFile.path);
        }
      } catch (e) {
        print("Error downloading file: $e");
        // Pass the error message as-is so VideoDownloadService can determine if it's a connectivity error
        // DioException contains more detailed error information
        String errorMessage;
        if (e is DioException) {
          errorMessage = e.message ?? e.toString();
          // Check DioException type for better connectivity error detection
          // unknown type often occurs when connection is closed during download
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.unknown) {
            errorMessage = 'Connection error: $errorMessage';
          }
        } else {
          errorMessage = e.toString();
          // Also check for HttpException (which wraps connection errors)
          if (errorMessage.contains('Connection closed') ||
              errorMessage.contains('HttpException')) {
            errorMessage = 'Connection error: $errorMessage';
          }
        }
        onError?.call(errorMessage);
      }
    } catch (e) {
      print('Error in download process: $e');
      // Pass the error message as-is so VideoDownloadService can determine if it's a connectivity error
      String errorMessage;
      if (e is DioException) {
        errorMessage = e.message ?? e.toString();
        // Check DioException type for better connectivity error detection
        // unknown type often occurs when connection is closed during download
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.unknown) {
          errorMessage = 'Connection error: $errorMessage';
        }
      } else {
        errorMessage = e.toString();
        // Also check for HttpException (which wraps connection errors)
        if (errorMessage.contains('Connection closed') ||
            errorMessage.contains('HttpException')) {
          errorMessage = 'Connection error: $errorMessage';
        }
      }
      onError?.call(errorMessage);
    }
  }
}
