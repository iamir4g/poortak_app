part of 'video_download_cubit.dart';

abstract class VideoDownloadState extends Equatable {
  const VideoDownloadState();

  @override
  List<Object?> get props => [];
}

class VideoDownloadInitial extends VideoDownloadState {}

class VideoDownloadLoaded extends VideoDownloadState {
  final Map<String, VideoDownloadInfo> downloads;

  const VideoDownloadLoaded({required this.downloads});

  @override
  List<Object?> get props => [downloads];
}

/// Information about a single video download
class VideoDownloadInfo extends Equatable {
  final String videoName;
  final DownloadStatus status;
  final double downloadProgress;
  final double decryptionProgress;
  final bool isDownloading;
  final bool isDecrypting;
  final bool isCheckingFiles;
  final String? localPath;
  final String? error;

  const VideoDownloadInfo({
    required this.videoName,
    required this.status,
    this.downloadProgress = 0.0,
    this.decryptionProgress = 0.0,
    this.isDownloading = false,
    this.isDecrypting = false,
    this.isCheckingFiles = false,
    this.localPath,
    this.error,
  });

  @override
  List<Object?> get props => [
        videoName,
        status,
        downloadProgress,
        decryptionProgress,
        isDownloading,
        isDecrypting,
        isCheckingFiles,
        localPath,
        error,
      ];
}

enum DownloadStatus {
  idle,
  checking,
  downloading,
  decrypting,
  completed,
  error,
}

