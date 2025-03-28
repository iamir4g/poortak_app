import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poortak/common/error_handling/check_exception.dart';
import 'package:poortak/config/constants.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';

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
          Sayareh(
            title: "درس اول",
            description: "پورتک به سیاره آی نو می رود",
            image:
                "https://www.namava.ir/mag/wp-content/uploads/2019/06/Amin-Hayai-1-1200x675.jpg",
            isLock: false,
          ),
          Sayareh(
            title: "درس دوم",
            description: "پورتک به سیاره آی نو می رود",
            image:
                "https://www.namava.ir/mag/wp-content/uploads/2019/06/Amin-Hayai-1-1200x675.jpg",
            isLock: false,
          ),
          Sayareh(
            title: "درس سوم",
            description: "پورتک به سیاره آی نو می رود",
            image:
                "https://www.namava.ir/mag/wp-content/uploads/2019/06/Amin-Hayai-1-1200x675.jpg",
            isLock: true,
          ),
          Sayareh(
            title: "درس چهارم",
            description: "پورتک به سیاره آی نو می رود",
            image:
                "https://www.namava.ir/mag/wp-content/uploads/2019/06/Amin-Hayai-1-1200x675.jpg",
            isLock: true,
          ),
          Sayareh(
            title: "درس پنجم",
            description: "پورتک به سیاره آی نو می رود",
            image:
                "https://www.namava.ir/mag/wp-content/uploads/2019/06/Amin-Hayai-1-1200x675.jpg",
            isLock: true,
          ),
          Sayareh(
            title: "درس ششم",
            description: "پورتک به سیاره آی نو می رود",
            image:
                "https://www.namava.ir/mag/wp-content/uploads/2019/06/Amin-Hayai-1-1200x675.jpg",
            isLock: true,
          ),
          Sayareh(
            title: "درس هفتم",
            description: "پورتک به سیاره آی نو می رود",
            image:
                "https://www.namava.ir/mag/wp-content/uploads/2019/06/Amin-Hayai-1-1200x675.jpg",
            isLock: true,
          ),
          Sayareh(
            title: "درس هشتم",
            description: "پورتک به سیاره آی نو می رود",
            image:
                "https://www.namava.ir/mag/wp-content/uploads/2019/06/Amin-Hayai-1-1200x675.jpg",
            isLock: true,
          ),
        ],
      ),
    );

    return fakeData;
  }
}
