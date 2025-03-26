part of 'sayareh_cubit.dart';

@immutable
abstract class SayarehDataStatus {}

class SayarehDataInitial extends SayarehDataStatus {}

class SayarehDataLoading extends SayarehDataStatus {}

class SayarehDataCompleted extends SayarehDataStatus {
  final dynamic data;
  SayarehDataCompleted(this.data);
}

class SayarehDataError extends SayarehDataStatus {
  final String errorMessage;
  SayarehDataError(this.errorMessage);
}
