import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poortak/common/error_handling/check_exception.dart';
import 'package:poortak/config/constants.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_storage_test_model.dart';

class SayarehApiProvider {
  Dio dio;
  SayarehApiProvider({required this.dio});

// dynamic callSayarehApi() async {
//     final response = await dio.get(
//       "${Constants.baseUrl}/sayareh",
//       queryParameters: {
//         // "lat" : lat,
//         // "long" : lon,
//       }
//     ).onError((DioException error, stackTrace){
//       return CheckExceptions.response(error.response!);
//     });

//     log(response.toString());

//     return response;
//   }

  Future<SayarehHomeModel> callSayarehApi() async {
    // Simulating API delay
    await Future.delayed(const Duration(seconds: 1));

    // Creating fake data
    final fakeData = SayarehHomeModel(
      ok: true,
      data: Data(
        sayareh: [
          SayarehLessonItem(
            title: "درس اول",
            description: "پورتک به سیاره آی نو می رود",
            image:
                "https://www.namava.ir/mag/wp-content/uploads/2019/06/Amin-Hayai-1-1200x675.jpg",
            isLock: false,
            price: 75000,
          ),
          SayarehLessonItem(
            title: "درس دوم",
            description: "پورتک به سیاره آی نو می رود",
            image:
                "https://www.namava.ir/mag/wp-content/uploads/2019/06/Amin-Hayai-1-1200x675.jpg",
            isLock: false,
            price: 75000,
          ),
          SayarehLessonItem(
            title: "درس سوم",
            description: "پورتک به سیاره آی نو می رود",
            image:
                "https://www.namava.ir/mag/wp-content/uploads/2019/06/Amin-Hayai-1-1200x675.jpg",
            isLock: true,
            price: 75000,
          ),
          SayarehLessonItem(
            title: "درس چهارم",
            description: "پورتک به سیاره آی نو می رود",
            image:
                "https://www.namava.ir/mag/wp-content/uploads/2019/06/Amin-Hayai-1-1200x675.jpg",
            isLock: true,
            price: 75000,
          ),
          SayarehLessonItem(
            title: "درس پنجم",
            description: "پورتک به سیاره آی نو می رود",
            image:
                "https://www.namava.ir/mag/wp-content/uploads/2019/06/Amin-Hayai-1-1200x675.jpg",
            isLock: true,
            price: 75000,
          ),
          SayarehLessonItem(
            title: "درس ششم",
            description: "پورتک به سیاره آی نو می رود",
            image:
                "https://www.namava.ir/mag/wp-content/uploads/2019/06/Amin-Hayai-1-1200x675.jpg",
            isLock: true,
            price: 75000,
          ),
          SayarehLessonItem(
            title: "درس هفتم",
            description: "پورتک به سیاره آی نو می رود",
            image:
                "https://www.namava.ir/mag/wp-content/uploads/2019/06/Amin-Hayai-1-1200x675.jpg",
            isLock: true,
            price: 75000,
          ),
          SayarehLessonItem(
            title: "درس هشتم",
            description: "پورتک به سیاره آی نو می رود",
            image:
                "https://www.namava.ir/mag/wp-content/uploads/2019/06/Amin-Hayai-1-1200x675.jpg",
            isLock: true,
            price: 75000,
          ),
        ],
      ),
    );

    return fakeData;
  }

  Future<SayarehStorageTest> callSayarehStorageApi() async {
    final response = await dio.get(
      "${Constants.baseUrl}/api/v1/storage",
    );

    return SayarehStorageTest.fromJson(response.data);
  }
}
