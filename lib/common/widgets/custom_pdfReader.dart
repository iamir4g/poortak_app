import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import '../utils/pdfDownloader.dart';
import '../services/storage_service.dart';

class CustomPdfReader extends StatefulWidget {
  final String? fileKey;
  final String? localPath;
  final String fileName;
  final String fileId;
  final bool isEncrypted;
  final bool showDownloadButton;
  final bool autoDownload;
  final bool usePublicUrl;
  final StorageService storageService;

  const CustomPdfReader({
    super.key,
    this.fileKey,
    this.localPath,
    required this.fileName,
    required this.fileId,
    required this.storageService,
    this.isEncrypted = false,
    this.showDownloadButton = true,
    this.autoDownload = false,
    this.usePublicUrl = false,
  });

  @override
  State<CustomPdfReader> createState() => _CustomPdfReaderState();
}

class _CustomPdfReaderState extends State<CustomPdfReader> {
  PdfController? _pdfController;
  String? _currentPdfPath;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  bool _isLoading = true;
  String? _errorMessage;

  // Page navigation
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isPageLoading = false;

  @override
  void initState() {
    super.initState();
    _initializePdf();
  }

  Future<void> _initializePdf() async {
    try {
      // First check if we have a local file for this specific fileKey
      final localPath =
          await PdfDownloader.getLocalPdfPathByFileId(widget.fileId);

      if (localPath != null) {
        print("Found existing local file: $localPath");
        _loadLocalPdf(localPath);
        return;
      }

      // If no local file and we have a fileKey, check if we should auto-download
      if (widget.fileKey != null && widget.autoDownload) {
        // Start downloading immediately
        _downloadPdf();
      } else if (widget.fileKey != null) {
        // Load from URL directly (will be fetched from StorageService)
        _loadUrlPdf();
      } else {
        setState(() {
          _errorMessage = 'No PDF source available';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error initializing PDF: $e';
        _isLoading = false;
      });
    }
  }

  void _loadLocalPdf(String path) async {
    setState(() {
      _currentPdfPath = path;
      _isLoading = false;
    });

    _pdfController = PdfController(
      document: PdfDocument.openFile(path),
    );

    // Get total pages count
    try {
      final document = await _pdfController!.document;
      setState(() {
        _totalPages = document.pagesCount;
      });
      print("Total pages: $_totalPages");

      // Note: PdfController doesn't have addListener, page changes will be handled by navigation methods
    } catch (e) {
      print("Error getting page count: $e");
    }
  }

  void _loadUrlPdf() async {
    setState(() {
      _isLoading = false;
    });

    try {
      if (widget.usePublicUrl) {
        // Use public URL for trial files (DO NOT TOUCH - this is correct)
        await widget.storageService.callGetDownloadPublicUrl(widget.fileKey!);
      } else {
        // Use new API endpoint for purchased book files
        final bookId = widget.fileId.startsWith('book_')
            ? widget.fileId.substring(5)
            : widget.fileId;
        await widget.storageService.callDownloadBookFile(bookId);
      }

      // For now, we'll use a placeholder and let the user download the PDF
      // The actual PDF viewing will happen after download
      setState(() {
        _errorMessage = 'برای مشاهده کتاب، ابتدا آن را دانلود کنید';
        _isLoading = false;
      });

      // Show a snackbar to guide the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('برای مشاهده کتاب، روی دکمه دانلود کلیک کنید'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading PDF: $e';
        _isLoading = false;
      });
    }
  }

  // Page navigation methods
  void _goToNextPage() {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
        _isPageLoading = true;
      });
      _pdfController?.jumpToPage(_currentPage - 1);
      setState(() {
        _isPageLoading = false;
      });
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
        _isPageLoading = true;
      });
      _pdfController?.jumpToPage(_currentPage - 1);
      setState(() {
        _isPageLoading = false;
      });
    }
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= _totalPages) {
      setState(() {
        _currentPage = page;
        _isPageLoading = true;
      });

      try {
        _pdfController?.jumpToPage(page - 1);
        print("Jumped to page: $page");
      } catch (e) {
        print("Error jumping to page: $e");
      }

      // Reset loading state after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isPageLoading = false;
          });
        }
      });
    } else {
      // Show error for invalid page number
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('شماره صفحه باید بین 1 و $_totalPages باشد'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _downloadPdf() async {
    if (widget.fileKey == null) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      await PdfDownloader.downloadAndStorePdf(
        storageService: widget.storageService,
        key: widget.fileKey!,
        fileName: widget.fileName,
        fileId: widget.fileId,
        isEncrypted: widget.isEncrypted,
        usePublicUrl: widget.usePublicUrl,
        onProgress: (progress) {
          setState(() {
            _downloadProgress = progress;
          });
        },
        onDownloadCompleted: (path) {
          setState(() {
            _isDownloading = false;
            _downloadProgress = 1.0;
          });
          _loadLocalPdf(path);

          // Show success message only if not auto-downloading
          if (mounted && !widget.autoDownload) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('کتاب با موفقیت دانلود شد'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        onDownloadError: (error) {
          setState(() {
            _isDownloading = false;
            _errorMessage = error;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطا در دانلود: $error'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      );
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _errorMessage = 'خطا در دانلود: $e';
      });
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            if (widget.fileKey != null && !widget.autoDownload) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _downloadPdf,
                icon: const Icon(Icons.download),
                label: const Text('دانلود کتاب'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (_isDownloading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              value: _downloadProgress,
            ),
            const SizedBox(height: 16),
            Text(
              'در حال بارگذاری کتاب... ${(_downloadProgress * 100).toInt()}%',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'لطفاً صبر کنید',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (_pdfController == null) {
      return const Center(
        child: Text('PDF not loaded'),
      );
    }

    return Column(
      children: [
        // PDF Viewer with custom builders
        Expanded(
          child: Column(
            children: [
              // Page navigation controls
              if (_totalPages > 0)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous page button
                      IconButton(
                        onPressed: _currentPage > 1 ? _goToPreviousPage : null,
                        icon: const Icon(Icons.arrow_back_ios),
                        tooltip: 'صفحه قبل',
                      ),

                      // Page info and navigation
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'صفحه $_currentPage از $_totalPages',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Page input field
                            SizedBox(
                              width: 80,
                              child: TextField(
                                controller: TextEditingController(
                                    text: _currentPage.toString()),
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintText: 'صفحه',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  isDense: true,
                                ),
                                onSubmitted: (value) {
                                  final page = int.tryParse(value);
                                  if (page != null) {
                                    _goToPage(page);
                                  } else {
                                    // Reset to current page if invalid input
                                    setState(() {});
                                  }
                                },
                                onChanged: (value) {
                                  // Update current page display as user types
                                  final page = int.tryParse(value);
                                  if (page != null &&
                                      page >= 1 &&
                                      page <= _totalPages) {
                                    setState(() {
                                      _currentPage = page;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Next page button
                      IconButton(
                        onPressed:
                            _currentPage < _totalPages ? _goToNextPage : null,
                        icon: const Icon(Icons.arrow_forward_ios),
                        tooltip: 'صفحه بعد',
                      ),
                    ],
                  ),
                ),

              // PDF content
              Expanded(
                child: Stack(
                  children: [
                    PdfView(
                      controller: _pdfController!,
                      builders: PdfViewBuilders<DefaultBuilderOptions>(
                        options: const DefaultBuilderOptions(
                          loaderSwitchDuration: Duration(milliseconds: 500),
                        ),
                        documentLoaderBuilder: (_) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        pageLoaderBuilder: (_) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorBuilder: (_, error) => Center(
                          child: Text('Error loading PDF: $error'),
                        ),
                      ),
                    ),

                    // Page loading indicator
                    if (_isPageLoading)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),

                    // Zoom info
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'برای زوم: دو انگشت را روی صفحه بکشید',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Bottom controls - only show if not auto-downloading
        if (widget.showDownloadButton &&
            widget.fileKey != null &&
            _currentPdfPath == null &&
            !widget.autoDownload)
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _downloadPdf,
                    icon: const Icon(Icons.download),
                    label: const Text('دانلود کتاب'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
