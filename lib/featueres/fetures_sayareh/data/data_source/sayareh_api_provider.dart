import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poortak/common/error_handling/check_exception.dart';
import 'package:poortak/config/constants.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_storage_test_model.dart';

class SayarehApiProvider {
  Dio dio;
  SayarehApiProvider({required this.dio});

  // Future<SayarehHomeModel>
  dynamic callGetAllCourses() async {
    final response = await dio.get(
      "${Constants.baseUrl}iknow/courses",
    );

    log("Sayareh Home Response: ${response.data}");
    return response;
  }

  dynamic callGetCourseById(String id) async {
    final response = await dio.get(
      "${Constants.baseUrl}iknow/courses/$id",
    );

    log("Sayareh Course Response: ${response.data}");
    return response;
  }

  dynamic callSayarehStorageApi() async {
    final response = await dio.get(
      "${Constants.baseUrl}storage",
    );

    log("Sayareh Storage Response: ${response.data}");
    return response; //SayarehStorageTest.fromJson(response.data);
  }

  dynamic callGetDownloadUrl(String key) async {
    final response = await dio.get(
      "${Constants.baseUrl}storage/download/$key",
    );

    log("Sayareh Storage Download URL: ${response.data}");
    return response; //SayarehStorageTest.fromJson(response.data);
  }

  dynamic callGetConversation(String id) async {
    final response = await dio.get(
      "${Constants.baseUrl}iknow/courses/$id/conversation",
    );

    log("Sayareh Conversation Response: ${response.data}");
    return response;
  }
}
