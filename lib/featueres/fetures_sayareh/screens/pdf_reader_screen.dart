import 'package:flutter/material.dart';
import 'package:poortak/common/widgets/custom_pdfReader.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/config/myTextStyle.dart';

class PdfReaderScreen extends StatelessWidget {
  final String fileKey;
  final String fileName;
  final String fileId;
  final StorageService storageService;
  final String bookTitle;

  const PdfReaderScreen({
    Key? key,
    required this.fileKey,
    required this.fileName,
    required this.fileId,
    required this.storageService,
    required this.bookTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          bookTitle,
          style: MyTextStyle.textMatn14Bold,
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // This will trigger the download in the PDF reader
              // The download button is already handled by CustomPdfReader
            },
            tooltip: 'دانلود کتاب',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F0FC),
              Color(0xFFFCEBF1),
              Color(0xFFEFE8FC),
            ],
            stops: [0.1, 0.54, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book info header
              // Container(
              //   width: double.infinity,
              //   padding: const EdgeInsets.all(16),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(16),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.grey.withOpacity(0.1),
              //         spreadRadius: 1,
              //         blurRadius: 3,
              //         offset: const Offset(0, 1),
              //       ),
              //     ],
              //   ),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(
              //         bookTitle,
              //         style: MyTextStyle.textMatn14Bold.copyWith(
              //           fontSize: 18,
              //         ),
              //       ),
              //       const SizedBox(height: 8),
              //       Text(
              //         'برای دانلود کتاب روی دکمه دانلود کلیک کنید',
              //         style: TextStyle(
              //           color: Colors.grey[600],
              //           fontSize: 14,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              const SizedBox(height: 0),

              // PDF Reader
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: fileKey.isNotEmpty
                        ? CustomPdfReader(
                            fileKey: fileKey,
                            fileName: fileName,
                            fileId: fileId,
                            storageService: storageService,
                            showDownloadButton: true,
                            autoDownload: false,
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'فایل کتاب در دسترس نیست',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
