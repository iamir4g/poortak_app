// import 'package:appinio_video_player/appinio_video_player.dart';
import 'dart:math';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/common/utils/custom_textStyle.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/bloc_storage_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/lesson_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/converstion_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/practice_vocabulary_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/quiezs_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/vocabulary_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/custom_video_player.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/sayareh_cubit.dart';
import 'package:poortak/locator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:typed_data';
import 'package:poortak/common/utils/decryption.dart';

class LessonScreen extends StatefulWidget {
  static const routeName = "/lesson_screen";
  final int index;
  final String lessonId;
  final String title;
  // final String name;

  const LessonScreen({
    super.key,
    required this.index,
    required this.title,
    required this.lessonId,
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

      // Check in Downloads directory
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
      final downloadUrl = await _storageService.callGetDownloadUrl(key);
      print("Download URL received: ${downloadUrl.data}");

      // Set the video URL for immediate playback while downloading
      setState(() {
        videoUrl = downloadUrl.data;
      });

      print("Starting file download");
      // Download using flutter_file_downloader
      await FileDownloader.downloadFile(
        url: downloadUrl.data,
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
              // If not encrypted, just copy to video directory
              await encryptedFile.copy(decryptedFile.path);
              setState(() {
                localVideoPath = decryptedFile.path;
                videoUrl = null;
                isDownloading = false;
              });
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

  @override
  void initState() {
    super.initState();
    // Call the storage API when the screen initializes
    context.read<LessonBloc>().add(GetLessonEvenet(id: widget.lessonId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LessonBloc, LessonState>(
      listener: (context, state) {
        print("LessonBloc state changed: $state");
        if (state is LessonSuccess) {
          // Check for existing files first
          _checkExistingFiles(state.lesson.video).then((_) {
            // Only start download if we don't have a local file
            if (localVideoPath == null) {
              _downloadAndStoreVideo(
                state.lesson.video, // video ID for download
                state.lesson.id, // name for file
                state.lesson.video, // video ID for decryption key
                true,
              );
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
        backgroundColor: MyColors.secondaryTint4,
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
            ),
          ),
          title: BlocBuilder<LessonBloc, LessonState>(
            builder: (context, state) {
              if (state is LessonSuccess) {
                return Text(
                  state.lesson.name,
                  style: MyTextStyle.textHeader16Bold,
                );
              }
              return Text(
                widget.title,
                style: MyTextStyle.textHeader16Bold,
              );
            },
          ),
        ),
        body: _buildContent(widget.lessonId),
      ),
    );
  }

  Widget _buildContent(String? conversationId) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: Stack(
              children: [
                if (localVideoPath == null && videoUrl == null)
                  Container(
                    width: 350,
                    height: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(37),
                      color: MyColors.brandSecondary,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 48,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'خطا در بارگذاری ویدیو',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  CustomVideoPlayer(
                    videoPath: localVideoPath ?? videoUrl!,
                    isNetworkVideo: localVideoPath == null && videoUrl != null,
                    width: 350,
                    height: 240,
                    borderRadius: 37,
                    autoPlay: true,
                    showControls: true,
                  ),
                if (isDownloading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(37),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${(downloadProgress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
              Navigator.pushNamed(context, ConversationScreen.routeName,
                  arguments: {"conversationId": conversationId});
            },
            child: Container(
              width: 350,
              height: 104,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                  color: MyColors.background),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 22, horizontal: 28),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/images/chat_icon.png",
                      width: 48.0,
                      height: 48.0,
                    ),
                    SizedBox(
                      width: 18,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("conversation",
                            style: CustomTextStyle.titleLesonText),
                        Text("مکالمه",
                            style: CustomTextStyle.subTitleLeasonText)
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
              Navigator.pushNamed(context, VocabularyScreen.routeName,
                  arguments: {"id": conversationId});
            },
            child: Container(
              width: 350,
              height: 104,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                  color: MyColors.background),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 22, horizontal: 28),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/images/words_icon.png",
                      width: 48.0,
                      height: 48.0,
                    ),
                    SizedBox(
                      width: 18,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("vocabulary",
                            style: CustomTextStyle.titleLesonText),
                        Text("واژگان",
                            style: CustomTextStyle.subTitleLeasonText)
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
              Navigator.pushNamed(context, QuizzesScreen.routeName);
              // Navigator.pushNamed(context, PracticeVocabularyScreen.routeName,
              //     arguments: {"courseId": conversationId});
            },
            child: Container(
              width: 350,
              height: 104,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                  color: MyColors.background),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 22, horizontal: 28),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/images/quiz_icon.png",
                      width: 48.0,
                      height: 48.0,
                    ),
                    SizedBox(
                      width: 18,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Quiz", style: CustomTextStyle.titleLesonText),
                        Text("آزمون", style: CustomTextStyle.subTitleLeasonText)
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
