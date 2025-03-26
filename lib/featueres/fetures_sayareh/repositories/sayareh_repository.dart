import 'package:dio/dio.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/fetures_sayareh/data/data_source/sayareh_api_provider.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/sayareh_cubit.dart';

class SayarehRepository {
  SayarehApiProvider sayarehApiProvider;

  SayarehRepository(this.sayarehApiProvider);

  Future<DataState<dynamic>> fetchSayarehData() async {
    // Response response = await sayarehApiProvider.callSayarehApi();
    final response = await sayarehApiProvider.callSayarehApi();
    final data = response.data;
    return DataSuccess(data);
    //return SayarehState(sayarehDataStatus: SayarehDataSuccess(response));
  }
}
