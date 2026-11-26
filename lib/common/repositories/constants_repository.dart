import 'package:dio/dio.dart';
import 'package:poortak/common/data/data_source/constants_api_provider.dart';
import 'package:poortak/common/models/long_caption_model.dart';
import 'package:poortak/common/resources/data_state.dart';

class ConstantsRepository {
  final ConstantsApiProvider apiProvider;

  static const int _maxAttempts = 3;
  static const Duration _retryBaseDelay = Duration(seconds: 1);

  ConstantsRepository(this.apiProvider);

  Future<DataState<LongCaptionModel>> getLongCaption(LongCaptionKey key) async {
    var result = await _fetchLongCaption(key);
    for (var attempt = 1;
        attempt < _maxAttempts && result is! DataSuccess<LongCaptionModel>;
        attempt++) {
      await Future.delayed(_retryBaseDelay * attempt);
      result = await _fetchLongCaption(key);
    }
    return result;
  }

  Future<DataState<LongCaptionModel>> _fetchLongCaption(
      LongCaptionKey key) async {
    try {
      final response = await apiProvider.callGetLongCaption(key.value);
      final data = response.data;

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data is Map<String, dynamic> &&
          data['ok'] == true) {
        final parsed = LongCaptionResponse.fromJson(data);
        return DataSuccess(parsed.data);
      }

      if (data is Map<String, dynamic>) {
        return DataFailed(
          data['message']?.toString() ?? "خطا در دریافت متن",
        );
      }

      return const DataFailed("خطا در دریافت متن");
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message']?.toString();
        if (message != null && message.isNotEmpty) {
          return DataFailed(message);
        }
      }
      return DataFailed(e.message ?? "خطا در اتصال به سرور");
    } catch (e) {
      return DataFailed(e.toString());
    }
  }
}
