import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/locator.dart';

class GetImageUrlService {
  Map<String, String> _imageUrls = {};

  final StorageService _storageService = locator<StorageService>();
  Future<String> getImageUrl(String thumbnailId) async {
    if (_imageUrls.containsKey(thumbnailId)) {
      return _imageUrls[thumbnailId]!;
    }

    try {
      final response = await _storageService.callGetDownloadUrl(thumbnailId);
      _imageUrls[thumbnailId] = response.data;
      return response.data;
    } catch (e) {
      print('Error getting image URL: $e');
      return ''; // Return empty string or a placeholder image URL
    }
  }
}
