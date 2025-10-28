import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
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
        for (var file in files) {
          if (file is File) {
            final fileName = getBaseFileName(file.path);
            if (fileName == name) {
              print("✅ Found existing decrypted video file: ${file.path}");
              return file.path;
            }
          }
        }
      }

      // For purchased content, check encrypted directory and try to decrypt
      if (hasAccess) {
        // Check in encrypted directory
        if (await encryptedDir.exists()) {
          final files = await encryptedDir.list().toList();
          for (var encryptedFile in files) {
            if (encryptedFile is File) {
              final fileName = getBaseFileName(encryptedFile.path);
              if (fileName == name) {
                print("✅ Found existing encrypted file: ${encryptedFile.path}");
                // Try to decrypt it
                try {
                  final decryptionKeyResponse =
                      await storageService.callGetDecryptedFile(fileName);
                  final decryptedFileName = '${fileName}.mp4';
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
            }
          }
        }

        // Check in Downloads directory for purchased content
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (await downloadsDir.exists()) {
          final files = await downloadsDir.list().toList();
          for (var downloadedFile in files) {
            if (downloadedFile is File) {
              final fileName = getBaseFileName(downloadedFile.path);
              if (fileName == name) {
                print(
                    "✅ Found existing file in Downloads: ${downloadedFile.path}");
                // Copy to encrypted directory with the original name
                final encryptedFile = File('${encryptedDir.path}/$name');
                await File(downloadedFile.path).copy(encryptedFile.path);

                // Try to decrypt it
                try {
                  final decryptionKeyResponse =
                      await storageService.callGetDecryptedFile(name);
                  final decryptedFile = File('${videoDir.path}/$name.mp4');

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
                  print("❌ Error processing file from Downloads: $e");
                  onDecrypting?.call(false);
                }
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

      print("Starting file download");
      // Download using flutter_file_downloader
      await FileDownloader.downloadFile(
        url: downloadUrlString,
        name: name,
        onProgress: (fileName, progress) {
          print("Download progress: $progress%");
          onDownloadProgress?.call(progress / 100);
        },
        onDownloadCompleted: (path) async {
          print("Download completed, file saved to: $path");
          try {
            // Get the downloaded file name without suffixes
            final downloadedFileName = getBaseFileName(path);

            // Delete the target file if it exists
            if (await encryptedFile.exists()) {
              print("Deleting existing encrypted file...");
              await encryptedFile.delete();
            }

            // Copy the file from Downloads to encrypted directory
            final downloadedFile = File(path);
            print("Downloaded file path: $path");
            print("Downloaded file base name: $downloadedFileName");
            print("Target encrypted file path: ${encryptedFile.path}");

            // Check if downloaded file exists
            if (await downloadedFile.exists()) {
              await downloadedFile.copy(encryptedFile.path);
              print("File copied successfully to encrypted directory");
            } else {
              throw Exception("Downloaded file does not exist at: $path");
            }

            // If file is encrypted, get decryption key and decrypt
            if (isEncrypted) {
              print("File is encrypted, getting decryption key");
              final decryptionKeyResponse =
                  await storageService.callGetDecryptedFile(fileId);
              print(
                  "Decryption key received: ${decryptionKeyResponse.data.key}");

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
            print("Error processing file: $e");
            onError?.call('خطا در پردازش فایل: $e');
          }
        },
        onDownloadError: (error) {
          print("Download error: $error");
          onError?.call('خطا در دانلود فایل: $error');
        },
      );
    } catch (e) {
      print('Error in download process: $e');
      onError?.call('خطا در دانلود فایل: $e');
    }
  }
}
