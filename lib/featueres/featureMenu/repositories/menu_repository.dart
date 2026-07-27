import 'package:dio/dio.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/featureMenu/data/data_source/menu_api_provider.dart';
import 'package:poortak/featueres/featureMenu/data/models/faq_model.dart';

class MenuRepository {
  final MenuApiProvider apiProvider;

  MenuRepository(this.apiProvider);

  Future<DataState<List<FAQItem>>> getFaq() async {
    try {
      final response = await apiProvider.callGetFaq();
      final data = response.data;

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data is Map<String, dynamic> &&
          data['ok'] == true) {
        final parsed = FaqResponse.fromJson(data);
        return DataSuccess(parsed.data);
      }

      if (data is Map<String, dynamic>) {
        return DataFailed(
          data['message']?.toString() ?? "خطا در دریافت سوالات رایج",
        );
      }

      return const DataFailed("خطا در دریافت سوالات رایج");
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
