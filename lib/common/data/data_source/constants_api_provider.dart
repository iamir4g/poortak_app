import 'package:dio/dio.dart';
import 'package:poortak/config/constants.dart';

class ConstantsApiProvider {
  final Dio dio;

  ConstantsApiProvider({required this.dio});

  /// api/v1/constants/long-captions/{captionKey}
  Future<Response> callGetLongCaption(String captionKey) async {
    return dio.get("${Constants.baseUrl}constants/long-captions/$captionKey");
  }
}
