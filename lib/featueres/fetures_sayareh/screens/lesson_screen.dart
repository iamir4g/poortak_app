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

  Future<void> _downloadAndStoreVideo(String key, String name) async {
    print("Starting download process for key: $key, name: $name");
    if (isDownloading) {
      print("Download already in progress");
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
      print("Video directory path: ${videoDir.path}");

      // Create videos directory if it doesn't exist
      if (!await videoDir.exists()) {
        print("Creating video directory");
        await videoDir.create(recursive: true);
      }

      // Create a file with the key as name
      final file = File('${videoDir.path}/$name');
      print("Target file path: ${file.path}");

      // Check if file already exists in app directory
      if (await file.exists()) {
        print("File already exists in app directory, using local path");
        setState(() {
          localVideoPath = file.path;
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
            if (await file.exists()) {
              await file.delete();
            }

            // Copy the file from Downloads to app directory
            final downloadedFile = File(path);
            await downloadedFile.copy(file.path);

            // Verify the file was copied successfully
            if (await file.exists()) {
              print("File successfully copied to app directory");
              setState(() {
                localVideoPath = file.path;
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
              print("Failed to copy file to app directory");
              throw Exception("Failed to copy file to app directory");
            }
          } catch (e) {
            print("Error copying downloaded file: $e");
            setState(() {
              isDownloading = false;
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('خطا در کپی فایل: $e'),
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
            _downloadAndStoreVideo(
              state.data.data[6].key,
              state.data.data[6].name,
            );
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
                // Call download function directly
                // _downloadAndStoreVideo(
                //   storageData.data.data[0].key,
                //   storageData.data.data[0].name,
                // );
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
