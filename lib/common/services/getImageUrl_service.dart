import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/locator.dart';

class GetImageUrlService {
  final Map<String, String> _imageUrls = {};

  final StorageService _storageService = locator<StorageService>();
  Future<String> getImageUrl(String thumbnailId) async {
    if (_imageUrls.containsKey(thumbnailId)) {
      return _imageUrls[thumbnailId]!;
    }

    try {
      print("Getting image URL from StorageService");
      final imageUrl =
          await _storageService.callGetDownloadPublicUrl(thumbnailId);
      _imageUrls[thumbnailId] = imageUrl;
      print("Image URL received: $imageUrl");
      return imageUrl;
    } catch (e) {
      print('Error getting image URL: $e');
      return ''; // Return empty string or a placeholder image URL
    }
  }
}
