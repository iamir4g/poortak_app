// import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';
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
  final StorageService _storageService = locator<StorageService>();
  Lesson? _currentLesson;
  final GlobalKey<CustomVideoPlayerState> _videoPlayerKey =
      GlobalKey<CustomVideoPlayerState>();

  Future<void> _checkExistingFiles(String name) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final videoDir = Directory('${directory.path}/videos');
      final encryptedDir = Directory('${directory.path}/encrypted');

      // Check in videos directory first
      if (await videoDir.exists()) {
        final files = await videoDir.list().toList();
        for (var file in files) {
          if (file.path.contains(name)) {
            print(
                "Found existing video file in videos directory: ${file.path}");
            setState(() {
              localVideoPath = file.path;
            });
            return;
          }
        }
      }

      // For purchased content, check encrypted directory and try to decrypt
      if (widget.purchased) {
        // Check in encrypted directory
        if (await encryptedDir.exists()) {
          final files = await encryptedDir.list().toList();
          for (var encryptedFile in files) {
            if (encryptedFile.path.contains(name)) {
              print("Found existing encrypted file: ${encryptedFile.path}");
              // Try to decrypt it
              try {
                final decryptionKeyResponse = await _storageService
                    .callGetDecryptedFile(widget.index.toString());
                final decryptedFile = File(
                    '${videoDir.path}/${encryptedFile.path.split('/').last}');
                final decryptedPath = await decryptFile(
                  encryptedFile.path,
                  decryptedFile.path,
                  decryptionKeyResponse.data.key,
                );
                if (await File(decryptedPath).exists()) {
                  setState(() {
                    localVideoPath = decryptedPath;
                  });
                  return;
                }
              } catch (e) {
                print("Error decrypting existing file: $e");
              }
            }
          }
        }

        // Check in Downloads directory for purchased content
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (await downloadsDir.exists()) {
          final files = await downloadsDir.list().toList();
          for (var downloadedFile in files) {
            if (downloadedFile.path.contains(name) &&
                !downloadedFile.path.contains('-')) {
              print("Found existing file in Downloads: ${downloadedFile.path}");
              // Copy to encrypted directory
              final encryptedFile = File(
                  '${encryptedDir.path}/${downloadedFile.path.split('/').last}');
              await File(downloadedFile.path).copy(encryptedFile.path);

              // Try to decrypt it
              try {
                final decryptionKeyResponse = await _storageService
                    .callGetDecryptedFile(widget.index.toString());
                final decryptedFile = File(
                    '${videoDir.path}/${downloadedFile.path.split('/').last}');
                final decryptedPath = await decryptFile(
                  encryptedFile.path,
                  decryptedFile.path,
                  decryptionKeyResponse.data.key,
                );
                if (await File(decryptedPath).exists()) {
                  setState(() {
                    localVideoPath = decryptedPath;
                  });
                  return;
                }
              } catch (e) {
                print("Error processing file from Downloads: $e");
              }
            }
          }
        }
      }

      // If we reach here, file doesn't exist anywhere - return false to indicate download needed
      return;
    } catch (e) {
      print("Error checking existing files: $e");
      return;
    }
  }

  Future<void> _downloadAndStoreVideo(
      String key, String name, String fileId, bool isEncrypted) async {
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

    setState(() {
      isDownloading = true;
      downloadProgress = 0.0;
    });

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
        setState(() {
          localVideoPath = decryptedFile.path;
          isDownloading = false;
        });
        return;
      }

      print("Getting download URL from StorageService");

      String downloadUrlString;
      if (isEncrypted) {
        // For purchased content, use regular download URL
        final downloadUrl = await _storageService.callGetDownloadUrl(key);
        downloadUrlString = downloadUrl.data;
      } else {
        // For trailer videos, use public download URL
        downloadUrlString = await _storageService.callGetDownloadPublicUrl(key);
      }

      print("Download URL received: $downloadUrlString");

      // Set the video URL for immediate playback while downloading
      setState(() {
        videoUrl = downloadUrlString;
      });

      print("Starting file download");
      // Download using flutter_file_downloader
      await FileDownloader.downloadFile(
        url: downloadUrlString,
        name: name,
        onProgress: (fileName, progress) {
          print("Download progress: $progress%");
          setState(() {
            downloadProgress = progress / 100;
          });
        },
        onDownloadCompleted: (path) async {
          print("Download completed, file saved to: $path");
          try {
            // Delete the target file if it exists
            if (await encryptedFile.exists()) {
              await encryptedFile.delete();
            }

            // Copy the file from Downloads to encrypted directory
            final downloadedFile = File(path);
            await downloadedFile.copy(encryptedFile.path);

            // If file is encrypted, get decryption key and decrypt
            if (isEncrypted) {
              print("File is encrypted, getting decryption key");
              final decryptionKeyResponse =
                  await _storageService.callGetDecryptedFile(fileId);
              print(
                  "Decryption key received: ${decryptionKeyResponse.data.key}");

              // Decrypt the file using the utility function
              print("Starting decryption process");
              final decryptedPath = await decryptFile(
                encryptedFile.path,
                decryptedFile.path,
                decryptionKeyResponse.data.key,
              );

              if (await File(decryptedPath).exists()) {
                print("File successfully processed");
                setState(() {
                  localVideoPath = decryptedPath;
                  videoUrl = null; // Clear the URL since we now have local file
                  isDownloading = false;
                });

                // Show success snackbar
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('فایل دانلود شد'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } else {
                print("Failed to process file");
                throw Exception("Failed to process file");
              }
            } else {
              // If not encrypted (trailer video), just copy to video directory
              await encryptedFile.copy(decryptedFile.path);
              setState(() {
                localVideoPath = decryptedFile.path;
                videoUrl = null;
                isDownloading = false;
              });

              // Show success snackbar for trailer video
              if (mounted) {
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
            setState(() {
              isDownloading = false;
            });
            if (mounted) {
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
          setState(() {
            isDownloading = false;
          });

          // Show error snackbar
          if (mounted) {
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
      setState(() {
        isDownloading = false;
      });

      // Show error snackbar
      if (mounted) {
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
    // Stop video when leaving the screen
    _videoPlayerKey.currentState?.stopVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LessonBloc, LessonState>(
      listener: (context, state) {
        print("LessonBloc state changed: $state");
        if (state is LessonSuccess) {
          // Store the lesson data for use in dialogs
          setState(() {
            _currentLesson = state.lesson;
          });

          // Check for existing files first
          _checkExistingFiles(state.lesson.trailerVideo).then((_) {
            // Only start download if we don't have a local file
            if (localVideoPath == null) {
              if (widget.purchased) {
                _downloadAndStoreVideo(
                  state.lesson.trailerVideo, // video ID for download
                  state.lesson.trailerVideo, // name for file
                  state.lesson.trailerVideo, // video ID for decryption key
                  true,
                );
              } else {
                _downloadAndStoreVideo(
                  state.lesson
                      .trailerVideo, // trailer video ID for public download
                  state.lesson.trailerVideo, // name for file
                  state.lesson.trailerVideo, // video ID (not used for public)
                  false,
                );
              }
            }
          });
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
            child: Stack(
              children: [
                // White container background
                Container(
                  width: 360,
                  height: 248,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),

                // Video player
                Positioned(
                  top: 5,
                  left: 5,
                  child: Container(
                    width: 350,
                    height: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(37),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(37),
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
                                if (!widget.purchased) {
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
              ],
            ),
          ),

          const SizedBox(height: 18),
          //card lesons
          InkWell(
            onTap: () {
              if (!widget.purchased) {
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
          InkWell(
            onTap: () {
              if (!widget.purchased) {
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
          InkWell(
            onTap: () {
              if (!widget.purchased) {
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
