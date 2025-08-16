part of 'sayareh_cubit.dart';

@immutable
abstract class SayarehDataStatus {}

class SayarehDataInitial extends SayarehDataStatus {}

class SayarehDataLoading extends SayarehDataStatus {}

class SayarehDataCompleted extends SayarehDataStatus {
  final dynamic data;
  final dynamic bookListData;
  SayarehDataCompleted(this.data, this.bookListData);
}

class SayarehDataError extends SayarehDataStatus {
  final String errorMessage;
  SayarehDataError(this.errorMessage);
}

class SayarehStorageCompleted extends SayarehDataStatus {
  //final dynamic data;
  final SayarehStorageTest data;
  SayarehStorageCompleted(this.data);
}

class SayarehStorageError extends SayarehDataStatus {
  final String errorMessage;
  SayarehStorageError(this.errorMessage);
}
