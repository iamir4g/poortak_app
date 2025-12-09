import 'dart:async';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/common/utils/video_downloader_util.dart';
import 'package:poortak/common/bloc/video_download_cubit/video_download_cubit.dart';
import 'package:poortak/common/bloc/connectivity_cubit/connectivity_cubit.dart';

/// Information about a paused download for resuming later
class PausedDownloadInfo {
  final String videoName;
  final String lessonId;
  final bool hasAccess;
  final bool isEncrypted;
  final bool usePublicUrl;
  final String? videoKey;
  final double downloadProgress;

  PausedDownloadInfo({
    required this.videoName,
    required this.lessonId,
    required this.hasAccess,
    required this.isEncrypted,
    required this.usePublicUrl,
    this.videoKey,
    this.downloadProgress = 0.0,
  });
}

/// Global service for managing video downloads
/// Downloads continue even when screens are disposed
class VideoDownloadService {
  final StorageService _storageService;
  final VideoDownloadCubit _downloadCubit;
  final ConnectivityCubit? _connectivityCubit;
  final Map<String, bool> _activeDownloads = {};
  final Map<String, PausedDownloadInfo> _pausedDownloads = {};
  StreamSubscription<ConnectivityState>? _connectivitySubscription;

  VideoDownloadService({
    required StorageService storageService,
    required VideoDownloadCubit downloadCubit,
    ConnectivityCubit? connectivityCubit,
  })  : _storageService = storageService,
        _downloadCubit = downloadCubit,
        _connectivityCubit = connectivityCubit {
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    final connectivityCubit = _connectivityCubit;
    if (connectivityCubit == null) return;

    _connectivitySubscription = connectivityCubit.stream.listen((state) {
      if (state.isConnected) {
        // Internet reconnected - resume paused downloads
        _resumePausedDownloads();
      } else {
        // Internet disconnected - pause active downloads
        _pauseActiveDownloads();
      }
    });
  }

  void _pauseActiveDownloads() {
    // Find all downloads that are currently downloading and pause them
    final currentState = _downloadCubit.state;
    if (currentState is VideoDownloadLoaded) {
      for (var entry in currentState.downloads.entries) {
        final videoName = entry.key;
        final downloadInfo = entry.value;

        if (downloadInfo.status == DownloadStatus.downloading &&
            _activeDownloads[videoName] == true) {
          // Mark as paused instead of error
          _downloadCubit.updateDownloadState(
            videoName: videoName,
            status: DownloadStatus.paused,
            isDownloading: false,
          );
          _activeDownloads[videoName] = false;
          print("⏸️ Paused download due to connectivity loss: $videoName");
        }
      }
    }
  }

  void _resumePausedDownloads() {
    if (_pausedDownloads.isEmpty) return;

    print("🔄 Resuming ${_pausedDownloads.length} paused downloads...");

    // Resume all paused downloads
    final pausedList = _pausedDownloads.values.toList();
    _pausedDownloads.clear();

    for (var pausedInfo in pausedList) {
      // Check if download is still in paused state
      final currentInfo = _downloadCubit.getDownloadInfo(pausedInfo.videoName);
      if (currentInfo?.status == DownloadStatus.paused) {
        print("▶️ Resuming download: ${pausedInfo.videoName}");
        checkAndDownloadVideo(
          videoName: pausedInfo.videoName,
          lessonId: pausedInfo.lessonId,
          hasAccess: pausedInfo.hasAccess,
          isEncrypted: pausedInfo.isEncrypted,
          usePublicUrl: pausedInfo.usePublicUrl,
          videoKey: pausedInfo.videoKey,
        );
      }
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }

  /// Check for existing files and start download if needed
  Future<void> checkAndDownloadVideo({
    required String videoName,
    required String lessonId,
    required bool hasAccess,
    required bool isEncrypted,
    required bool usePublicUrl,
    String? videoKey,
  }) async {
    // Check if internet is connected before starting/resuming download
    final connectivityCubit = _connectivityCubit;
    if (connectivityCubit != null && !connectivityCubit.state.isConnected) {
      print("⚠️ No internet connection, cannot start download: $videoName");
      // Store download info for later resume
      _pausedDownloads[videoName] = PausedDownloadInfo(
        videoName: videoName,
        lessonId: lessonId,
        hasAccess: hasAccess,
        isEncrypted: isEncrypted,
        usePublicUrl: usePublicUrl,
        videoKey: videoKey,
      );
      _downloadCubit.updateDownloadState(
        videoName: videoName,
        status: DownloadStatus.paused,
        isDownloading: false,
      );
      return;
    }

    // Check if this is a resume from paused state
    final currentInfo = _downloadCubit.getDownloadInfo(videoName);
    if (currentInfo?.status == DownloadStatus.paused) {
      // Remove from paused downloads since we're resuming
      _pausedDownloads.remove(videoName);
    }

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
            status: decrypting
                ? DownloadStatus.decrypting
                : DownloadStatus.checking,
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
            status:
                downloading ? DownloadStatus.downloading : DownloadStatus.idle,
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
            status: decrypting
                ? DownloadStatus.decrypting
                : DownloadStatus.downloading,
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
          // Check if error is due to connectivity issue
          final isConnectivityError = _isConnectivityError(error);

          // If error is connectivity-related, pause the download
          // Don't wait for connectivityCubit to detect - the error itself indicates connectivity issue
          if (isConnectivityError) {
            // Pause instead of error for connectivity issues
            _pausedDownloads[videoName] = PausedDownloadInfo(
              videoName: videoName,
              lessonId: lessonId,
              hasAccess: hasAccess,
              isEncrypted: isEncrypted,
              usePublicUrl: usePublicUrl,
              videoKey: videoKey,
              downloadProgress:
                  _downloadCubit.getDownloadInfo(videoName)?.downloadProgress ??
                      0.0,
            );
            _downloadCubit.updateDownloadState(
              videoName: videoName,
              status: DownloadStatus.paused,
              isDownloading: false,
              isDecrypting: false,
            );
            print("⏸️ Download paused due to connectivity error: $videoName");
          } else {
            // Real error - show error state
            _downloadCubit.updateDownloadState(
              videoName: videoName,
              status: DownloadStatus.error,
              error: error,
              isDownloading: false,
              isDecrypting: false,
            );
          }
          _activeDownloads[videoName] = false;
        },
      );
    } catch (e) {
      print("❌ Error in checkAndDownloadVideo: $e");

      // Check if error is due to connectivity issue
      final isConnectivityError = _isConnectivityError(e.toString());

      // If error is connectivity-related, pause the download
      // Don't wait for connectivityCubit to detect - the error itself indicates connectivity issue
      if (isConnectivityError) {
        // Pause instead of error for connectivity issues
        _pausedDownloads[videoName] = PausedDownloadInfo(
          videoName: videoName,
          lessonId: lessonId,
          hasAccess: hasAccess,
          isEncrypted: isEncrypted,
          usePublicUrl: usePublicUrl,
          videoKey: videoKey,
        );
        _downloadCubit.updateDownloadState(
          videoName: videoName,
          status: DownloadStatus.paused,
          isCheckingFiles: false,
          isDownloading: false,
          isDecrypting: false,
        );
        print("⏸️ Download paused due to connectivity error: $videoName");
      } else {
        // Real error - show error state
        _downloadCubit.updateDownloadState(
          videoName: videoName,
          status: DownloadStatus.error,
          error: e.toString(),
          isCheckingFiles: false,
          isDownloading: false,
          isDecrypting: false,
        );
      }
      _activeDownloads[videoName] = false;
    }
  }

  /// Check if an error is related to connectivity
  bool _isConnectivityError(String error) {
    final errorLower = error.toLowerCase();
    return errorLower.contains('socket') ||
        errorLower.contains('network') ||
        errorLower.contains('connection') ||
        errorLower.contains('timeout') ||
        errorLower.contains('failed host lookup') ||
        errorLower.contains('no internet') ||
        errorLower.contains('internet') ||
        errorLower.contains('connection closed') ||
        errorLower.contains('closed while receiving') ||
        errorLower.contains('httpexception') ||
        errorLower.contains('dioexception') ||
        errorLower.contains('receive data') ||
        errorLower.contains('connection reset') ||
        errorLower.contains('connection refused');
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
