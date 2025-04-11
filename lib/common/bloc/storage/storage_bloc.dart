// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:poortak/common/services/storage_service.dart';
// import 'storage_event.dart';
// import 'storage_state.dart';

// class StorageBloc extends Bloc<StorageEvent, StorageState> {
//   final StorageService _storageService;

//   StorageBloc({required StorageService storageService})
//       : _storageService = storageService,
//         super(StorageInitial()) {
//     on<GetDownloadUrl>(_onGetDownloadUrl);
//     on<GetMultipleDownloadUrls>(_onGetMultipleDownloadUrls);
//   }

//   Future<String> getDownloadUrl(String key) async {
//     try {
//       emit(StorageLoading());
//       final downloadUrl = await _storageService.callGetDownloadUrl(key);
//       emit(StorageUrlLoaded(downloadUrl));
//       return downloadUrl;
//     } catch (e) {
//       emit(StorageError(e.toString()));
//       rethrow;
//     }
//   }

//   Future<void> _onGetDownloadUrl(
//     GetDownloadUrl event,
//     Emitter<StorageState> emit,
//   ) async {
//     try {
//       emit(StorageLoading());
//       final downloadUrl = await _storageService.callGetDownloadUrl(event.key);
//       emit(StorageUrlLoaded(downloadUrl));
//     } catch (e) {
//       emit(StorageError(e.toString()));
//     }
//   }

//   Future<void> _onGetMultipleDownloadUrls(
//     GetMultipleDownloadUrls event,
//     Emitter<StorageState> emit,
//   ) async {
//     try {
//       emit(StorageLoading());
//       final downloadUrls = await Future.wait(
//         event.keys.map((key) => _storageService.callGetDownloadUrl(key)),
//       );
//       emit(StorageUrlsLoaded(downloadUrls));
//     } catch (e) {
//       emit(StorageError(e.toString()));
//     }
//   }
// }
