import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poortak/common/error_handling/app_exception.dart';
import 'package:poortak/common/error_handling/check_exception.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/fetures_sayareh/data/data_source/sayareh_api_provider.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_storage_test_model.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/sayareh_cubit.dart';

class SayarehRepository {
  SayarehApiProvider sayarehApiProvider;

  SayarehRepository(this.sayarehApiProvider);

  Future<DataState<dynamic>> fetchSayarehData() async {
    // Response response = await sayarehApiProvider.callSayarehApi();
    try {
      final response = await sayarehApiProvider.callSayarehApi();
      final data = response.data;
      return DataSuccess(data);
    } on AppException catch (e) {
      return await CheckExceptions.getError(e);
    }
    //return SayarehState(sayarehDataStatus: SayarehDataSuccess(response));
  }

  Future<DataState<SayarehStorageTest>> fetchSayarehStorage() async {
    try {
      Response response = await sayarehApiProvider.callSayarehStorageApi();
      // final data = response.data;
      if (response.statusCode == 200 || response.statusCode == 201) {
        log("Sayareh Storage Response: ${response.data}");
        final data = SayarehStorageTest.fromJson(response.data);

        return DataSuccess(data);
      } else {
        return DataFailed(response.data['message'] ?? "خطا در دریافت اطلاعات");
      }
    } on AppException catch (e) {
      return await CheckExceptions.getError(e);
    }
  }
}
