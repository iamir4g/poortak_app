import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'video_download_state.dart';

/// Cubit for managing video download state globally
/// Downloads continue even when screens are disposed
class VideoDownloadCubit extends Cubit<VideoDownloadState> {
  VideoDownloadCubit() : super(VideoDownloadInitial());

  /// Update download state for a specific video
  void updateDownloadState({
    required String videoName,
    required DownloadStatus status,
    double? downloadProgress,
    double? decryptionProgress,
    bool? isDownloading,
    bool? isDecrypting,
    bool? isCheckingFiles,
    String? localPath,
    String? error,
  }) {
    final currentDownloads = Map<String, VideoDownloadInfo>.from(
      state is VideoDownloadLoaded
          ? (state as VideoDownloadLoaded).downloads
          : {},
    );

    currentDownloads[videoName] = VideoDownloadInfo(
      videoName: videoName,
      status: status,
      downloadProgress: downloadProgress ?? currentDownloads[videoName]?.downloadProgress ?? 0.0,
      decryptionProgress: decryptionProgress ?? currentDownloads[videoName]?.decryptionProgress ?? 0.0,
      isDownloading: isDownloading ?? currentDownloads[videoName]?.isDownloading ?? false,
      isDecrypting: isDecrypting ?? currentDownloads[videoName]?.isDecrypting ?? false,
      isCheckingFiles: isCheckingFiles ?? currentDownloads[videoName]?.isCheckingFiles ?? false,
      localPath: localPath ?? currentDownloads[videoName]?.localPath,
      error: error ?? currentDownloads[videoName]?.error,
    );

    emit(VideoDownloadLoaded(downloads: currentDownloads));
  }

  /// Get download info for a specific video
  VideoDownloadInfo? getDownloadInfo(String videoName) {
    if (state is VideoDownloadLoaded) {
      return (state as VideoDownloadLoaded).downloads[videoName];
    }
    return null;
  }

  /// Remove download info (when download is complete or cancelled)
  void removeDownload(String videoName) {
    if (state is VideoDownloadLoaded) {
      final currentDownloads = Map<String, VideoDownloadInfo>.from(
        (state as VideoDownloadLoaded).downloads,
      );
      currentDownloads.remove(videoName);
      emit(VideoDownloadLoaded(downloads: currentDownloads));
    }
  }

  /// Clear all downloads
  void clearAll() {
    emit(VideoDownloadInitial());
  }
}

