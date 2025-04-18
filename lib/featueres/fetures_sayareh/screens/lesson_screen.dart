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
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/bloc_storage_bloc.dart';
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
  final String title;
  // final String name;

  const LessonScreen({
    super.key,
    required this.index,
    required this.title,
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

      // Check in Downloads directory first
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (await downloadsDir.exists()) {
        final files = await downloadsDir.list().toList();
        for (var file in files) {
          if (file.path.contains(name) && !file.path.contains('-')) {
            print("Found existing file in Downloads: ${file.path}");
            // Copy to encrypted directory
            await File(file.path).copy(encryptedFile.path);

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
                file.path,
                decryptedFile.path,
                decryptionKeyResponse.data.key,
              );
              if (await File(decryptedPath).exists()) {
                print("File successfully processed from Downloads");
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
            }

            // Verify the file was processed successfully
            if (await decryptedFile.exists()) {
              print("File successfully processed from Downloads");
              setState(() {
                localVideoPath = decryptedFile.path;
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
          }
        }
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
                path,
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
            }

            // Verify the file was processed successfully
            if (await decryptedFile.exists()) {
              print("File successfully processed");
              setState(() {
                localVideoPath = decryptedFile.path;
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
    print("initState called");
    // Call the storage API when the screen initializes
    context.read<BlocStorageBloc>().add(RequestStorageEvent());
    print("RequestStorageEvent dispatched");
  }

  @override
  Widget build(BuildContext context) {
    print("build called");
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SayarehCubit(sayarehRepository: locator()),
        ),
      ],
      child: BlocListener<BlocStorageBloc, BlocStorageState>(
        listener: (context, state) {
          print("BlocStorageBloc state changed: $state");
          if (state is BlocStorageCompleted) {
            print("BlocStorageCompleted");
            print("Sayareh Storage Response: ${state.data}");

            // Check for existing files first
            _checkExistingFiles(state.data.data[7].name).then((_) {
              // Only start download if we don't have a local file
              if (localVideoPath == null) {
                _downloadAndStoreVideo(
                  state.data.data[7].key,
                  state.data.data[7].name,
                  state.data.data[7].id,
                  state.data.data[7].isEncrypted,
                );
              }
            });
          } else if (state is BlocStorageError) {
            print("BlocStorageError: ${state.message}");
          }
        },
        child: BlocListener<SayarehCubit, SayarehState>(
          listener: (context, state) {
            print("SayarehCubit state changed: $state");
            if (state.sayarehDataStatus is SayarehDataCompleted) {
              print("SayarehStorageCompleted");
              final storageData =
                  state.sayarehDataStatus as SayarehDataCompleted;
              if (storageData.data.data.isNotEmpty) {
                print("Data is not empty, calling download");
                print("Key: ${storageData.data.data[0].key}");
                print("Name: ${storageData.data.data[0].name}");
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
              title: Text(widget.title),
            ),
            body: BlocBuilder<SayarehCubit, SayarehState>(
              builder: (context, state) {
                print("BlocBuilder building with state: $state");
                // Show loading only when explicitly loading storage data
                if (state.sayarehDataStatus is SayarehDataLoading) {
                  return Stack(
                    children: [
                      _buildContent(),
                      const Center(child: CircularProgressIndicator()),
                    ],
                  );
                }

                // Show error state if storage API fails
                if (state.sayarehDataStatus is SayarehDataError) {
                  final error = state.sayarehDataStatus as SayarehDataError;
                  return Stack(
                    children: [
                      _buildContent(),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(error.errorMessage),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                // context
                                //     .read<SayarehStorageCubit>()
                                //     .downloadSayareh(widget.key, widget.name);
                              },
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                // For all other states (including initial and completed), show the content
                return _buildContent();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
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
          Container(
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
                      Text("مکالمه", style: CustomTextStyle.subTitleLeasonText)
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
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
                      Text("vocabulary", style: CustomTextStyle.titleLesonText),
                      Text("واژگان", style: CustomTextStyle.subTitleLeasonText)
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
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
        ],
      ),
    );
  }
}
