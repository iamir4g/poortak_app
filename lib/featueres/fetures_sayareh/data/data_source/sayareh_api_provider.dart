import 'package:dio/dio.dart';
import 'package:poortak/config/constants.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';

class SayarehApiProvider {
  Dio dio;
  SayarehApiProvider({required this.dio});

//  dynamic callSayarehApi() async {
//     final response = await dio.get("${Constants.baseUrl}/sayareh");
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
            image: "aa",
            isLock: true,
          ),
          Sayareh(
            title: "درس اول",
            description: "پورتک به سیاره آی نو می رود",
            image: "aa",
            isLock: true,
          ),
        ],
      ),
    );

    return fakeData;
  }
}
