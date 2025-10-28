part of 'iknow_access_bloc.dart';

abstract class IknowAccessState {}

class IknowAccessInitial extends IknowAccessState {}

class IknowAccessLoading extends IknowAccessState {}

class IknowAccessError extends IknowAccessState {
  final String message;
  IknowAccessError(this.message);
}

class IknowAccessCompleted extends IknowAccessState {
  final IknowAccess data;
  IknowAccessCompleted(this.data);
}
