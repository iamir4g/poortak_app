import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';

class ItemBook extends StatelessWidget {
  final String? title;
  final String? description;
  final String? thumbnail;
  // final String? price;
  const ItemBook({
    super.key,
    this.title,
    this.description,
    this.thumbnail,
    // this.price
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
                  style: const TextStyle(
                    color: Colors.black87,
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
                    style: const TextStyle(
                      color: Colors.grey,
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
          // const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        ],
      ),
    );
  }
}
