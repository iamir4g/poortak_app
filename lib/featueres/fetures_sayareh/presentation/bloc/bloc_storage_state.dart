part of 'bloc_storage_bloc.dart';

abstract class BlocStorageState {}

class BlocStorageInitial extends BlocStorageState {}

class BlocStorageLoading extends BlocStorageState {}

class BlocStorageError extends BlocStorageState {
  final String message;
  BlocStorageError(this.message);
}

class BlocStorageCompleted extends BlocStorageState {
  final SayarehStorageTest data;
  BlocStorageCompleted(this.data);
}
