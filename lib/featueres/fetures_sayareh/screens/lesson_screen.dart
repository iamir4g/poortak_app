// import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/iknow_access_bloc/iknow_access_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/lesson_bloc/lesson_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/converstion_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/quizzes_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/vocabulary_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/custom_video_player.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/dialog_cart.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/common/utils/decryption.dart';
import 'package:poortak/common/utils/prefs_operator.dart';

class LessonScreen extends StatefulWidget {
  static const routeName = "/lesson_screen";
  final int index;
  final String lessonId;
  final String title;
  final bool purchased;
  // final String name;

  const LessonScreen({
    super.key,
    required this.index,
    required this.title,
    required this.lessonId,
    required this.purchased,
    // required this.name,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  String? videoUrl;
  String? localVideoPath;
  bool isDownloading = false;
  double downloadProgress = 0.0;
  bool isDecrypting = false;
  double decryptionProgress = 0.0;
  final StorageService _storageService = locator<StorageService>();
  Lesson? _currentLesson;
  final GlobalKey<CustomVideoPlayerState> _videoPlayerKey =
      GlobalKey<CustomVideoPlayerState>();
  bool _isDisposed = false;

  // Helper method to check if user has access
  bool get hasAccess {
    final accessBloc = locator<IknowAccessBloc>();
    return accessBloc.hasCourseAccess(widget.lessonId);
  }

  // Helper method to extract base filename without flutter_file_downloader suffixes
  String _getBaseFileName(String filePath) {
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

  Future<void> _checkExistingFiles(String name) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final videoDir = Directory('${directory.path}/videos');
      final encryptedDir = Directory('${directory.path}/encrypted');

      // Check in videos directory first (decrypted files)
      if (await videoDir.exists()) {
        final files = await videoDir.list().toList();
        for (var file in files) {
          if (file is File) {
            final fileName = _getBaseFileName(file.path);
            if (fileName == name) {
              print("✅ Found existing decrypted video file: ${file.path}");
              if (!_isDisposed && mounted) {
                setState(() {
                  localVideoPath = file.path;
                });
              }
              return;
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
              final fileName = _getBaseFileName(encryptedFile.path);
              if (fileName == name) {
                print("✅ Found existing encrypted file: ${encryptedFile.path}");
                // Try to decrypt it
                try {
                  // Use the video file ID for getting decryption key, not the index
                  final decryptionKeyResponse =
                      await _storageService.callGetDecryptedFile(fileName);
                  final decryptedFileName =
                      '${fileName}.mp4'; // or keep original extension
                  final decryptedFile =
                      File('${videoDir.path}/$decryptedFileName');

                  if (!_isDisposed && mounted) {
                    setState(() {
                      isDecrypting = true;
                      decryptionProgress = 0.0;
                    });
                  }

                  final decryptedPath = await decryptFile(
                    encryptedFile.path,
                    decryptedFile.path,
                    decryptionKeyResponse.data.key,
                    onProgress: (progress) {
                      if (!_isDisposed && mounted) {
                        setState(() {
                          decryptionProgress = progress;
                        });
                      }
                    },
                  );

                  if (!_isDisposed && mounted) {
                    setState(() {
                      isDecrypting = false;
                    });
                  }
                  if (await File(decryptedPath).exists()) {
                    if (!_isDisposed && mounted) {
                      setState(() {
                        localVideoPath = decryptedPath;
                      });
                    }
                    return;
                  }
                } catch (e) {
                  print("❌ Error decrypting existing file: $e");
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
              final fileName = _getBaseFileName(downloadedFile.path);
              if (fileName == name) {
                print(
                    "✅ Found existing file in Downloads: ${downloadedFile.path}");
                // Copy to encrypted directory with the original name
                final encryptedFile = File('${encryptedDir.path}/$name');
                await File(downloadedFile.path).copy(encryptedFile.path);

                // Try to decrypt it
                try {
                  // Use the video file ID for getting decryption key, not the index
                  final decryptionKeyResponse =
                      await _storageService.callGetDecryptedFile(name);
                  final decryptedFile = File('${videoDir.path}/$name.mp4');

                  if (!_isDisposed && mounted) {
                    setState(() {
                      isDecrypting = true;
                      decryptionProgress = 0.0;
                    });
                  }

                  final decryptedPath = await decryptFile(
                    encryptedFile.path,
                    decryptedFile.path,
                    decryptionKeyResponse.data.key,
                    onProgress: (progress) {
                      if (!_isDisposed && mounted) {
                        setState(() {
                          decryptionProgress = progress;
                        });
                      }
                    },
                  );

                  if (!_isDisposed && mounted) {
                    setState(() {
                      isDecrypting = false;
                    });
                  }
                  if (await File(decryptedPath).exists()) {
                    if (!_isDisposed && mounted) {
                      setState(() {
                        localVideoPath = decryptedPath;
                      });
                    }
                    return;
                  }
                } catch (e) {
                  print("❌ Error processing file from Downloads: $e");
                }
              }
            }
          }
        }
      }

      print("ℹ️ No existing file found for: $name");
      return;
    } catch (e) {
      print("❌ Error checking existing files: $e");
      return;
    }
  }

  Future<void> _downloadAndStoreVideo(
      String key, String name, String fileId, bool isEncrypted,
      {bool usePublicUrl = false}) async {
    print(
        "Starting download process for key: $key, name: $name, isEncrypted: $isEncrypted");
    if (isDownloading) {
      print("Download already in progress");
      return;
    }

    // First check if we already have the file
    if (localVideoPath != null) {
      print("File already exists at: $localVideoPath");
      return;
    }

    // Check if file already exists in local directories
    final directory = await getApplicationDocumentsDirectory();
    final videoDir = Directory('${directory.path}/videos');
    final encryptedDir = Directory('${directory.path}/encrypted');

    // Check in videos directory (decrypted files)
    if (await videoDir.exists()) {
      final files = await videoDir.list().toList();
      for (var file in files) {
        if (file is File) {
          final fileName = _getBaseFileName(file.path);
          if (fileName == name) {
            print("✅ Found existing decrypted video file: ${file.path}");
            if (!_isDisposed && mounted) {
              setState(() {
                localVideoPath = file.path;
              });
            }
            return;
          }
        }
      }
    }

    // Check in encrypted directory for purchased content
    if (hasAccess && await encryptedDir.exists()) {
      final files = await encryptedDir.list().toList();
      for (var file in files) {
        if (file is File) {
          final fileName = _getBaseFileName(file.path);
          if (fileName == name) {
            print("✅ Found existing encrypted file: ${file.path}");
            // Try to decrypt it
            try {
              // Use the video file ID for getting decryption key, not the index
              final decryptionKeyResponse =
                  await _storageService.callGetDecryptedFile(fileName);
              final decryptedFileName = '${fileName}.mp4';
              final decryptedFile = File('${videoDir.path}/$decryptedFileName');

              if (!_isDisposed && mounted) {
                setState(() {
                  isDecrypting = true;
                  decryptionProgress = 0.0;
                });
              }

              final decryptedPath = await decryptFile(
                file.path,
                decryptedFile.path,
                decryptionKeyResponse.data.key,
                onProgress: (progress) {
                  if (!_isDisposed && mounted) {
                    setState(() {
                      decryptionProgress = progress;
                    });
                  }
                },
              );

              if (!_isDisposed && mounted) {
                setState(() {
                  isDecrypting = false;
                });
              }
              if (await File(decryptedPath).exists()) {
                print("✅ Successfully decrypted existing file: $decryptedPath");
                if (!_isDisposed && mounted) {
                  setState(() {
                    localVideoPath = decryptedPath;
                  });
                }
                return;
              }
            } catch (e) {
              print("❌ Error decrypting existing file: $e");
              // If decryption fails, use the encrypted file as is
              print("✅ Using encrypted file without decryption: ${file.path}");
              if (!_isDisposed && mounted) {
                setState(() {
                  localVideoPath = file.path;
                });
              }
              return;
            }
          }
        }
      }
    }

    if (!_isDisposed && mounted) {
      setState(() {
        isDownloading = true;
        downloadProgress = 0.0;
      });
    }

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
        if (!_isDisposed && mounted) {
          setState(() {
            localVideoPath = decryptedFile.path;
            isDownloading = false;
          });
        }
        return;
      }

      print("Getting download URL from StorageService");
      print("usePublicUrl: $usePublicUrl, key: $key");

      String downloadUrlString;
      try {
        if (usePublicUrl) {
          // For trailer videos, use public download URL (DO NOT TOUCH - this is correct)
          downloadUrlString =
              await _storageService.callGetDownloadPublicUrl(key);
          print("Public download URL received: $downloadUrlString");
        } else {
          // For purchased course videos, use new API endpoint with lessonId
          downloadUrlString =
              await _storageService.callDownloadCourseVideo(widget.lessonId);
          print("Course video download URL received: $downloadUrlString");
        }
      } catch (e) {
        print('Error getting download URL: $e');
        if (!_isDisposed && mounted) {
          setState(() {
            isDownloading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('خطا در دریافت لینک دانلود. لطفا دوباره تلاش کنید.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      print("Download URL received: $downloadUrlString");

      // Set the video URL for immediate playback while downloading
      if (!_isDisposed && mounted) {
        setState(() {
          videoUrl = downloadUrlString;
        });
      }

      print("Starting file download");
      // Download using flutter_file_downloader
      await FileDownloader.downloadFile(
        url: downloadUrlString,
        name: name,
        onProgress: (fileName, progress) {
          print("Download progress: $progress%");
          if (!_isDisposed && mounted) {
            setState(() {
              downloadProgress = progress / 100;
            });
          }
        },
        onDownloadCompleted: (path) async {
          print("Download completed, file saved to: $path");
          try {
            // Get the downloaded file name without suffixes
            final downloadedFileName = _getBaseFileName(path);

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
              // For course videos, use video ID (the actual file key) for getting decryption key
              final decryptionKeyResponse =
                  await _storageService.callGetDecryptedFile(fileId);
              print(
                  "Decryption key received: ${decryptionKeyResponse.data.key}");

              // Decrypt the file using the utility function
              print("Starting decryption process");
              // Use a clean path for decrypted file (without flutter_file_downloader suffixes)
              final cleanDecryptedFile = File('${videoDir.path}/$name.mp4');

              // Set decryption state
              if (!_isDisposed && mounted) {
                setState(() {
                  isDecrypting = true;
                  decryptionProgress = 0.0;
                  isDownloading = false; // Download finished, now decrypting
                });
              }

              final decryptedPath = await decryptFile(
                encryptedFile.path,
                cleanDecryptedFile.path,
                decryptionKeyResponse.data.key,
                onProgress: (progress) {
                  if (!_isDisposed && mounted) {
                    setState(() {
                      decryptionProgress = progress;
                    });
                  }
                },
              );

              // Reset decryption state
              if (!_isDisposed && mounted) {
                setState(() {
                  isDecrypting = false;
                });
              }

              if (await File(decryptedPath).exists()) {
                print("✅ File successfully decrypted and processed");
                if (!_isDisposed && mounted) {
                  setState(() {
                    localVideoPath = decryptedPath;
                    videoUrl =
                        null; // Clear the URL since we now have local file
                  });
                }

                // Show success snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('فایل دانلود شد'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                print("❌ Failed to process file");
                throw Exception("Failed to process file");
              }
            } else {
              // If not encrypted (trailer video), just copy to video directory
              final cleanDecryptedFile = File('${videoDir.path}/$name.mp4');
              await encryptedFile.copy(cleanDecryptedFile.path);
              if (!_isDisposed && mounted) {
                setState(() {
                  localVideoPath = cleanDecryptedFile.path;
                  videoUrl = null;
                  isDownloading = false;
                });

                // Show success snackbar for trailer video
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تریلر دانلود شد'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            }
          } catch (e) {
            print("Error processing file: $e");
            if (!_isDisposed && mounted) {
              setState(() {
                isDownloading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('خطا در پردازش فایل: $e'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        },
        onDownloadError: (error) {
          print("Download error: $error");
          if (!_isDisposed && mounted) {
            setState(() {
              isDownloading = false;
            });

            // Show error snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطا در دانلود فایل: $error'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      );
    } catch (e) {
      print('Error in download process: $e');
      if (!_isDisposed && mounted) {
        setState(() {
          isDownloading = false;
        });

        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در دانلود فایل: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showPurchaseDialog() {
    if (_currentLesson == null) {
      print('No lesson data available for purchase dialog');
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogCart(item: _currentLesson!);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Call the storage API when the screen initializes
    context.read<LessonBloc>().add(GetLessonEvenet(id: widget.lessonId));
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Stop video when leaving the screen
    _videoPlayerKey.currentState?.stopVideo();
    // Stop download if it's in progress
    if (isDownloading) {
      // Reset downloading state
      isDownloading = false;
      downloadProgress = 0.0;
    }
    // Reset decryption state
    if (isDecrypting) {
      isDecrypting = false;
      decryptionProgress = 0.0;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LessonBloc, LessonState>(
      listener: (context, state) {
        print("LessonBloc state changed: $state");
        if (state is LessonSuccess) {
          // Store the lesson data for use in dialogs
          if (!_isDisposed && mounted) {
            setState(() {
              _currentLesson = state.lesson;
            });
          }

          // First determine which video to use based on login and purchase status
          String? videoToCheck;

          // Check if user is logged in
          final prefsOperator = locator<PrefsOperator>();
          final isLoggedIn = prefsOperator.isLoggedIn();

          if (isLoggedIn &&
              hasAccess &&
              state.lesson.video != null &&
              state.lesson.video!.isNotEmpty) {
            // User has purchased, check for the full video first
            videoToCheck = state.lesson.video;
            print("Checking for purchased video: $videoToCheck");
          } else {
            // Check for trailer video
            videoToCheck = state.lesson.trailerVideo;
            print("Checking for trailer video: $videoToCheck");
          }

          // Check for existing files first
          if (videoToCheck != null && videoToCheck.isNotEmpty) {
            _checkExistingFiles(videoToCheck).then((_) async {
              // Only start download if we don't have a local file
              if (localVideoPath == null) {
                // Determine which video to download based on login and purchase status
                String? videoToDownload;
                bool usePublicUrl = false;

                // Check if user is logged in
                final prefsOperator = locator<PrefsOperator>();
                final isLoggedIn = prefsOperator.isLoggedIn();

                print(
                    "Video download logic - isLoggedIn: $isLoggedIn, hasAccess: $hasAccess, video: ${state.lesson.video}, trailerVideo: ${state.lesson.trailerVideo}");

                if (isLoggedIn) {
                  // User is logged in
                  if (hasAccess &&
                      state.lesson.video != null &&
                      state.lesson.video!.isNotEmpty) {
                    // User has purchased the lesson, use the full video
                    videoToDownload = state.lesson.video;
                    usePublicUrl = false;
                    print(
                        "Using purchased video: $videoToDownload with authenticated URL");
                  } else if (state.lesson.trailerVideo.isNotEmpty) {
                    // User hasn't purchased or video is not available, use trailer video with public URL
                    videoToDownload = state.lesson.trailerVideo;
                    usePublicUrl = true;
                    print(
                        "Using trailer video: $videoToDownload with public URL");
                  }
                } else {
                  // User is not logged in, always use trailer video with public URL
                  if (state.lesson.trailerVideo.isNotEmpty) {
                    videoToDownload = state.lesson.trailerVideo;
                    usePublicUrl = true;
                    print(
                        "Using trailer video: $videoToDownload with public URL");
                  }
                }

                if (videoToDownload != null && videoToDownload.isNotEmpty) {
                  _downloadAndStoreVideo(
                    videoToDownload, // video ID for download
                    videoToDownload, // name for file
                    videoToDownload, // video ID for decryption key
                    !usePublicUrl, // isEncrypted: true for authenticated URL, false for public URL
                    usePublicUrl: usePublicUrl, // usePublicUrl parameter
                  );
                }
              }
            });
          }
        } else if (state is LessonError) {
          print("LessonError: ${state.message}");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9FE),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(57),
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 32, 0),
              height: 57,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(33.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 1),
                    blurRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title
                  BlocBuilder<LessonBloc, LessonState>(
                    builder: (context, state) {
                      return Text(
                        state is LessonSuccess
                            ? state.lesson.name
                            : widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'IranSans',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D495C),
                        ),
                      );
                    },
                  ),

                  // Back button
                  Container(
                    width: 40,
                    height: 40,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Color(0xFF3D495C),
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: _buildContent(context, widget.lessonId),
      ),
    );
  }

  Widget _buildContent(BuildContext context, String? conversationId) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 28),
          Center(
            child: Column(
              children: [
                // White container background with video
                Container(
                  width: 360,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(37),
                    child: Container(
                      width: 350,
                      height: 240,
                      child: localVideoPath == null && videoUrl == null
                          ? Container(
                              decoration: BoxDecoration(
                                color: MyColors.brandSecondary,
                                borderRadius: BorderRadius.circular(37),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.color,
                                      size: 48,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'خطا در بارگذاری ویدیو',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.color,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : CustomVideoPlayer(
                              key: _videoPlayerKey,
                              videoPath: localVideoPath ?? videoUrl!,
                              isNetworkVideo:
                                  localVideoPath == null && videoUrl != null,
                              width: 350,
                              height: 240,
                              borderRadius: 37,
                              autoPlay: true,
                              showControls: true,
                              onVideoEnded: () {
                                print('Video ended');
                                // If user hasn't purchased and this was a trailer video, show purchase dialog
                                if (!hasAccess) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return DialogCart(item: _currentLesson!);
                                    },
                                  );
                                  // _showPurchaseDialog();
                                }
                              },
                            ),
                    ),
                  ),
                ),

                // Download progress bar (below video)
                if (isDownloading)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 350,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'در حال دانلود...',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${(downloadProgress * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: downloadProgress,
                            minHeight: 6,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Decryption progress bar (below video or download)
                if (isDecrypting)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 350,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'در حال رمزگشایی...',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${(decryptionProgress * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: decryptionProgress,
                            minHeight: 6,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 18),
          //card lesons
          InkWell(
            onTap: () {
              if (!hasAccess) {
                _showPurchaseDialog();
                return;
              }
              Navigator.pushNamed(context, ConversationScreen.routeName,
                  arguments: {"conversationId": conversationId});
            },
            child: Container(
              width: 359,
              height: 104,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    offset: const Offset(0, 0),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 22, horizontal: 28),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/images/chat_icon.png",
                      width: 48.0,
                      height: 48.0,
                    ),
                    const SizedBox(width: 18),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "conversation",
                          style: const TextStyle(
                            fontFamily: 'IranSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFA3AFC2),
                          ),
                        ),
                        Text(
                          "مکالمه",
                          style: const TextStyle(
                            fontFamily: 'IranSans',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF29303D),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
          //card vocabulary
          InkWell(
            onTap: () {
              print("VocabularyScreen.routeName: $hasAccess");
              if (!hasAccess) {
                _showPurchaseDialog();
                return;
              }
              Navigator.pushNamed(context, VocabularyScreen.routeName,
                  arguments: {"id": conversationId});
            },
            child: Container(
              width: 359,
              height: 104,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    offset: const Offset(0, 0),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 22, horizontal: 28),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Image.asset(
                          "assets/images/words_icon.png",
                          width: 48.0,
                          height: 48.0,
                        ),
                        Positioned(
                          top: 5,
                          left: 14,
                          child: Container(
                            width: 40,
                            height: 15,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                "Word",
                                style: TextStyle(
                                  fontFamily: 'IranSans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF95D6A4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 18),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "vocabulary",
                          style: const TextStyle(
                            fontFamily: 'IranSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFA3AFC2),
                          ),
                        ),
                        Text(
                          "واژگان",
                          style: const TextStyle(
                            fontFamily: 'IranSans',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF29303D),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
          //card quiz
          InkWell(
            onTap: () {
              if (!hasAccess) {
                _showPurchaseDialog();
                return;
              }
              final prefsOperator = locator<PrefsOperator>();
              if (!prefsOperator.isLoggedIn()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('لطفا ابتدا وارد حساب کاربری خود شوید'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }
              Navigator.pushNamed(context, QuizzesScreen.routeName,
                  arguments: {"courseId": conversationId});
            },
            child: Container(
              width: 359,
              height: 104,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    offset: const Offset(0, 0),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 22, horizontal: 28),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/images/quiz_icon.png",
                      width: 48.0,
                      height: 48.0,
                    ),
                    const SizedBox(width: 18),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Quiz",
                          style: const TextStyle(
                            fontFamily: 'IranSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFA3AFC2),
                          ),
                        ),
                        Text(
                          "آزمون",
                          style: const TextStyle(
                            fontFamily: 'IranSans',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF29303D),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 50),

          // Floating Action Button - Left positioned
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Container(
                width: 63,
                height: 63,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      offset: const Offset(0, 0),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    // Add your action here
                  },
                  icon: Image.asset(
                    "assets/images/iknow/dictionary_icon.png",
                    width: 36,
                    height: 36,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
