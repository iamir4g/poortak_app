import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';

class ItemBook extends StatelessWidget {
  final String? title;
  final String? description;
  final String? thumbnail;
  final String? fileKey;
  final String? trialFile;
  final bool purchased;
  final String? price;
  final String? bookId;
  const ItemBook({
    super.key,
    this.title,
    this.description,
    this.thumbnail,
    this.fileKey,
    this.trialFile,
    this.purchased = false,
    this.price,
    this.bookId,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if (bookId != null && bookId!.isNotEmpty) {
            _navigateToPdfReader(context);
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
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 81,
                  height: 81,
                  child: FutureBuilder<String>(
                    future: GetImageUrlService().getImageUrl(thumbnail ?? ""),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return const Center(
                          child: Icon(Icons.error),
                        );
                      }
                      return Image.network(
                        snapshot.data!,
                        width: 81,
                        height: 81,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.error),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              // const SizedBox(width: 8),
              // Icon(
              //   Icons.arrow_forward_ios,
              //   color: Theme.of(context).textTheme.bodySmall?.color,
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPdfReader(BuildContext context) {
    if (bookId == null || bookId!.isEmpty) return;

    // Navigate to PDF reader with book ID
    Navigator.pushNamed(
      context,
      '/pdf_reader_screen',
      arguments: {
        'bookId': bookId!,
      },
    );
  }
}
