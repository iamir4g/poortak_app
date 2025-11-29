import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/common/utils/video_downloader_util.dart';
import 'package:poortak/common/bloc/video_download_cubit/video_download_cubit.dart';

/// Global service for managing video downloads
/// Downloads continue even when screens are disposed
class VideoDownloadService {
  final StorageService _storageService;
  final VideoDownloadCubit _downloadCubit;
  final Map<String, bool> _activeDownloads = {};

  VideoDownloadService({
    required StorageService storageService,
    required VideoDownloadCubit downloadCubit,
  })  : _storageService = storageService,
        _downloadCubit = downloadCubit;

  /// Check for existing files and start download if needed
  Future<void> checkAndDownloadVideo({
    required String videoName,
    required String lessonId,
    required bool hasAccess,
    required bool isEncrypted,
    required bool usePublicUrl,
    String? videoKey,
  }) async {
    // Prevent duplicate downloads
    if (_activeDownloads[videoName] == true) {
      print("⚠️ Download already in progress for: $videoName");
      return;
    }

    _activeDownloads[videoName] = true;

    try {
      // Update state: checking files
      _downloadCubit.updateDownloadState(
        videoName: videoName,
        status: DownloadStatus.checking,
        isCheckingFiles: true,
      );

      // Check for existing files
      final existingPath = await VideoDownloaderUtil.checkExistingFiles(
        name: videoName,
        storageService: _storageService,
        hasAccess: hasAccess,
        onDecrypting: (decrypting) {
          _downloadCubit.updateDownloadState(
            videoName: videoName,
            status: decrypting ? DownloadStatus.decrypting : DownloadStatus.checking,
            isDecrypting: decrypting,
          );
        },
        onDecryptionProgress: (progress) {
          _downloadCubit.updateDownloadState(
            videoName: videoName,
            status: DownloadStatus.decrypting,
            decryptionProgress: progress,
          );
        },
      );

      if (existingPath != null) {
        _downloadCubit.updateDownloadState(
          videoName: videoName,
          status: DownloadStatus.completed,
          localPath: existingPath,
          isCheckingFiles: false,
          isDownloading: false,
          isDecrypting: false,
        );
        _activeDownloads[videoName] = false;
        return;
      }

      // No existing file found, start download
      _downloadCubit.updateDownloadState(
        videoName: videoName,
        status: DownloadStatus.downloading,
        isCheckingFiles: false,
        isDownloading: true,
        downloadProgress: 0.0,
      );

      // Determine video key if not provided
      final key = videoKey ?? videoName;

      // Start download
      await VideoDownloaderUtil.downloadAndStoreVideo(
        storageService: _storageService,
        key: key,
        name: videoName,
        fileId: videoName,
        lessonId: lessonId,
        isEncrypted: isEncrypted,
        usePublicUrl: usePublicUrl,
        onDownloading: (downloading) {
          _downloadCubit.updateDownloadState(
            videoName: videoName,
            status: downloading ? DownloadStatus.downloading : DownloadStatus.idle,
            isDownloading: downloading,
          );
        },
        onDownloadProgress: (progress) {
          _downloadCubit.updateDownloadState(
            videoName: videoName,
            status: DownloadStatus.downloading,
            downloadProgress: progress,
          );
        },
        onDecrypting: (decrypting) {
          _downloadCubit.updateDownloadState(
            videoName: videoName,
            status: decrypting ? DownloadStatus.decrypting : DownloadStatus.downloading,
            isDecrypting: decrypting,
          );
        },
        onDecryptionProgress: (progress) {
          _downloadCubit.updateDownloadState(
            videoName: videoName,
            status: DownloadStatus.decrypting,
            decryptionProgress: progress,
          );
        },
        onSuccess: (path) {
          _downloadCubit.updateDownloadState(
            videoName: videoName,
            status: DownloadStatus.completed,
            localPath: path,
            isDownloading: false,
            isDecrypting: false,
            downloadProgress: 1.0,
            decryptionProgress: 1.0,
          );
          _activeDownloads[videoName] = false;
        },
        onError: (error) {
          _downloadCubit.updateDownloadState(
            videoName: videoName,
            status: DownloadStatus.error,
            error: error,
            isDownloading: false,
            isDecrypting: false,
          );
          _activeDownloads[videoName] = false;
        },
      );
    } catch (e) {
      print("❌ Error in checkAndDownloadVideo: $e");
      _downloadCubit.updateDownloadState(
        videoName: videoName,
        status: DownloadStatus.error,
        error: e.toString(),
        isCheckingFiles: false,
        isDownloading: false,
        isDecrypting: false,
      );
      _activeDownloads[videoName] = false;
    }
  }

  /// Cancel a download (if possible)
  void cancelDownload(String videoName) {
    _activeDownloads[videoName] = false;
    _downloadCubit.updateDownloadState(
      videoName: videoName,
      status: DownloadStatus.idle,
      isDownloading: false,
      isDecrypting: false,
      isCheckingFiles: false,
    );
  }

  /// Get download info for a video
  VideoDownloadInfo? getDownloadInfo(String videoName) {
    return _downloadCubit.getDownloadInfo(videoName);
  }

  /// Check if a download is active
  bool isDownloadActive(String videoName) {
    return _activeDownloads[videoName] == true;
  }
}

