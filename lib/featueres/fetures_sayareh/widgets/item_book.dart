import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/locator.dart';
import '../screens/pdf_reader_screen.dart';

class ItemBook extends StatelessWidget {
  final String? title;
  final String? description;
  final String? thumbnail;
  final String? fileKey;
  // final String? price;
  const ItemBook({
    super.key,
    this.title,
    this.description,
    this.thumbnail,
    this.fileKey,
    // this.price
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if (fileKey != null && fileKey!.isNotEmpty) {
            _openPdfReader(context);
          }
        },
        child: Container(
          width: 360,
          height: 100,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title ?? 'بدون عنوان',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.titleMedium?.color,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (description != null && description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description!,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              CircleAvatar(
                maxRadius: 30,
                minRadius: 30,
                child: FutureBuilder<String>(
                  future: GetImageUrlService().getImageUrl(thumbnail ?? ""),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return const Icon(Icons.error);
                    }
                    return Image.network(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios, 
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPdfReader(BuildContext context) {
    if (fileKey == null || fileKey!.isEmpty) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text(
                'در حال باز کردن کتاب...',
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
            ],
          ),
        );
      },
    );

    final storageService = locator<StorageService>();

    // Navigate to PDF reader
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfReaderScreen(
          fileKey: fileKey!,
          fileName: '${title ?? 'book'}.pdf',
          fileId: 'book_${fileKey}',
          storageService: storageService,
          bookTitle: title ?? 'کتاب',
        ),
      ),
    ).then((_) {
      // Close loading dialog when returning from PDF reader
      Navigator.of(context).pop();
    });
  }
}
